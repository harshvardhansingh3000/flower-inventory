// routes/flowers.js
import express from 'express';
import pool from '../db.js';

const router = express.Router();

// Get all flowers
router.get('/', async (req, res) => {
  const sql = 'SELECT * FROM flowers';
  try {
    const result = await pool.query(sql);
    res.json(result.rows); // PostgreSQL returns results in 'rows'
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;