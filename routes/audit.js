// routes/audit.js

import express from 'express';
import pool from '../db.js';
import { verifyToken } from './users.js';

const router = express.Router();

// Get all audit logs
router.get('/', verifyToken, async (req, res) => {
  const { role } = req.user;


  const sql = `
    SELECT audit_logs.*, users.username
    FROM audit_logs
    JOIN users ON audit_logs.user_id = users.id
    ORDER BY audit_logs.timestamp DESC
  `;

  try {
    const result = await pool.query(sql);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching audit logs:', err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
