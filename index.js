// index.js
import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';

import flowerRoutes from './routes/flowers.js';
import userRoutes from './routes/users.js';
import reservationRoutes from './routes/reservations.js';
import initAdmin from './initAdmin.js';
import auditRoutes from './routes/audit.js';
import initDatabase from './initDatabase.js';


dotenv.config();

const app = express();
app.use(bodyParser.json());
app.use(cors());

app.use('/api/flowers', flowerRoutes);
app.use('/api/users', userRoutes);
app.use('/api/reservations', reservationRoutes);
app.use('/api/audit', auditRoutes);

const port = process.env.PORT || 3000; // Use environment port or default to 3000

const startServer = async () => {
  try {
    // Initialize the database tables
    await initDatabase();

    // Initialize the admin user
    await initAdmin();

    // Start the server
    app.listen(port, () => {
      console.log(`Server is running on port ${port}`);
    });
  } catch (err) {
    console.error('Error starting server:', err);
    process.exit(1);
  }
};

startServer();
