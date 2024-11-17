// index.js
import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';

import flowerRoutes from './routes/flowers.js';
import userRoutes from './routes/users.js';
import reservationRoutes from './routes/reservations.js';
import initAdmin from './initAdmin.js';

dotenv.config();

const app = express();
app.use(bodyParser.json());
app.use(cors());

app.use('/api/flowers', flowerRoutes);
app.use('/api/users', userRoutes);
app.use('/api/reservations', reservationRoutes);

const port = process.env.PORT || 3000; // Use environment port or default to 3000

initAdmin().then(() => {
  app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });
});
