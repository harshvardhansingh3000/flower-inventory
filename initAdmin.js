// initAdmin.js
import bcrypt from 'bcrypt';
import pool from './db.js';
import dotenv from 'dotenv';

dotenv.config();

const initAdmin = async () => {
  const adminUsername = process.env.ADMIN_USERNAME || 'admin';
  const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';

  const checkAdminSql = 'SELECT * FROM users WHERE role = $1';
  try {
    const result = await pool.query(checkAdminSql, ['Admin']);
    if (result.rows.length === 0) {
      const hash = await bcrypt.hash(adminPassword, 10);
      const insertAdminSql = 'INSERT INTO users (username, password_hash, role) VALUES ($1, $2, $3)';
      await pool.query(insertAdminSql, [adminUsername, hash, 'Admin']);
      console.log('Admin account created successfully');
    } else {
      console.log('Admin account already exists');
    }
  } catch (err) {
    console.error('Error initializing admin account:', err.message);
  } 
};

export default initAdmin;