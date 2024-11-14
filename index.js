// index.js
import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';

import flowerRoutes from './routes/flowers.js';
import userRoutes from './routes/users.js';

dotenv.config();

const app = express();
app.use(bodyParser.json());
app.use(cors());

app.use('/api/flowers', flowerRoutes);
app.use('/api/users', userRoutes);

const port = 3000;

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});