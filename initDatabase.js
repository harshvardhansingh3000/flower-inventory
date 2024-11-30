// initDatabase.js
import pool from './db.js';

const initDatabase = async () => {
 try{ // Create the 'users' table
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      username VARCHAR(255) NOT NULL UNIQUE,
      password_hash VARCHAR(255) NOT NULL,
      role VARCHAR(50) NOT NULL CHECK (role IN ('Admin', 'Manager', 'Staff'))
    );
  `);

  // Create the 'flowers' table
  await pool.query(`
    CREATE TABLE IF NOT EXISTS flowers (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      description TEXT,
      quantity INTEGER NOT NULL DEFAULT 0,
      threshold INTEGER NOT NULL DEFAULT 0
    );
  `);

  // Create the 'reservations' table
  await pool.query(`
    CREATE TABLE IF NOT EXISTS reservations (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL REFERENCES users(id),
      flower_id INTEGER NOT NULL REFERENCES flowers(id),
      quantity INTEGER NOT NULL,
      sell_date DATE NOT NULL,
      party_name VARCHAR(255) NOT NULL,
      status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'processed')),
      processed_by INTEGER 
    );
  `);

  // Create the 'audit_logs' table
  await pool.query(`
    CREATE TABLE IF NOT EXISTS audit_logs (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL REFERENCES users(id),
      action VARCHAR(255) NOT NULL,
      details TEXT,
      timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      reservation_id INTEGER
    );
  `);

  console.log('Database tables have been initialized.');
}catch (err){
    console.error('Error initializing database:', err);
    throw err;
}
};

export default initDatabase;