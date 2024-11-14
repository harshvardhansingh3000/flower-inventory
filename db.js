// db.js
import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

// Create a new pool instance
const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // Heroku provides this
  ssl: {
    rejectUnauthorized: false, // Needed for Heroku SSL connections
  },
});

// Test the connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error acquiring client:', err.stack);
  } else {
    console.log('Connected to PostgreSQL database');
    release();
  }
});

export default pool;