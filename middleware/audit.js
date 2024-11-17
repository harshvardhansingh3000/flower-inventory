import pool from '../db.js';

export const auditLog = async (userId, action, details) => {
  const sql = 'INSERT INTO audit_logs (user_id, action, details) VALUES ($1, $2, $3)';
  try {
    await pool.query(sql, [userId, action, details]);
  } catch (err) {
    console.error('Audit log error:', err);
  }
};