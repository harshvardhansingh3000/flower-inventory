// routes/users.js
import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../db.js';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();
const jwtSecret = process.env.JWT_SECRET;

if (!jwtSecret) {
  throw new Error('JWT_SECRET is not defined. Please set it in your .env file.');
}

// Register a new user
router.post('/register', async (req, res) => {
  const { username, password } = req.body;
  const role = 'Staff'; // Default role

  const checkUserSql = 'SELECT * FROM users WHERE username = $1';
  try {
    const result = await pool.query(checkUserSql, [username]);
    if (result.rows.length > 0) {
      return res.status(400).json({ error: 'Username already exists' });
    } else {
      const hash = await bcrypt.hash(password, 10);
      const insertUserSql = 'INSERT INTO users (username, password_hash, role) VALUES ($1, $2, $3)';
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
  try {
    const userQuery = 'SELECT * FROM users WHERE username = $1';
    const userResult = await pool.query(userQuery, [username]);

    if (userResult.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid username or password' });
    }

    const user = userResult.rows[0];

    // Compare passwords
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(400).json({ error: 'Invalid username or password' });
    }

    // Create and sign token with user ID and role
    const token = jwt.sign(
      { id: user.id, role: user.role },
      jwtSecret,
      { expiresIn: '30d' }
    );

    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Middleware to verify tokens
export function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Expecting "Bearer TOKEN"

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  jwt.verify(token, jwtSecret, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}
// Update user role (Admins only)
router.put('/role/:id', verifyToken, async (req, res) => {
  const { role } = req.user;
  if (role !== 'Admin') {
    return res.status(403).json({ error: 'Access denied' });
  }

  const userId = req.params.id;
  const { newRole } = req.body;
  const validRoles = ['Admin', 'Manager', 'Staff'];

  if (!validRoles.includes(newRole)) {
    return res.status(400).json({ error: 'Invalid role' });
  }

  const sql = 'UPDATE users SET role = $1 WHERE id = $2 RETURNING *';
  try {
    const result = await pool.query(sql, [newRole, userId]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'User not found' });
    } else {
      res.json({ message: 'User role updated', user: result.rows[0] });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;