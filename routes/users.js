// routes/users.js
import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../db.js';

const router = express.Router();
const jwtSecret = process.env.JWT_SECRET;

if (!jwtSecret) {
  throw new Error('JWT_SECRET is not defined. Please set it in your .env file.');
}

// Register a new user
router.post('/register', async (req, res) => {
  const { username, password, role } = req.body;
  const checkUserSql = 'SELECT * FROM users WHERE username = $1';
  try {
    const result = await pool.query(checkUserSql, [username]);
    if (result.rows.length > 0) {
      return res.status(400).json({ error: 'Username already exists' });
    } else {
      const hash = await bcrypt.hash(password, 10);
      const insertUserSql = 'INSERT INTO users (username, password, role) VALUES ($1, $2, $3)';
      await pool.query(insertUserSql, [username, hash, role]);
      res.status(201).json({ message: 'User registered successfully' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// User login
router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  const sql = 'SELECT * FROM users WHERE username = $1';
  try {
    const result = await pool.query(sql, [username]);
    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid username or password' });
    } else {
      const user = result.rows[0];
      const match = await bcrypt.compare(password, user.password);
      if (match) {
        const token = jwt.sign({ id: user.id, role: user.role }, jwtSecret, { expiresIn: '1h' });
        res.json({ message: 'Login successful', token });
      } else {
        res.status(400).json({ error: 'Invalid username or password' });
      }
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Middleware to verify tokens
export function verifyToken(req, res, next) {
  const bearerHeader = req.headers['authorization'];

  if (typeof bearerHeader !== 'undefined') {
    const token = bearerHeader.split(' ')[1];

    jwt.verify(token, jwtSecret, (err, authData) => {
      if (err) return res.status(403).json({ error: 'Forbidden' });

      req.user = authData;
      next();
    });
  } else {
    res.status(403).json({ error: 'Forbidden' });
  }
}

// Protected route example
router.get('/profile', verifyToken, async (req, res) => {
  const sql = 'SELECT id, username, role FROM users WHERE id = $1';
  try {
    const result = await pool.query(sql, [req.user.id]);
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;