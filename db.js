// db.js
import pkg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pkg;

const isProduction = process.env.NODE_ENV === 'production';

const connectionString = process.env.DATABASE_URL;

const ssl = isProduction
  ? { rejectUnauthorized: false } // For Heroku
  : false; // For local development

const pool = new Pool({
  connectionString,
  ssl: isProduction ? { rejectUnauthorized: false } : undefined,
});

// Optional: Test the connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error acquiring client:', err.stack);
  } else {
    console.log('Connected to PostgreSQL database');
    release();
  }
});

export default pool;