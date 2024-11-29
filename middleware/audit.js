import pool from '../db.js';

export const auditLog = async (userId, action, details,reservationId = null) => {
  const sql = 'INSERT INTO audit_logs (user_id, action, details, reservation_id) VALUES ($1, $2, $3, $4)';
  try {
    await pool.query(sql, [userId, action, details,reservationId]);
  } catch (err) {
    console.error('Audit log error:', err);
  }
};