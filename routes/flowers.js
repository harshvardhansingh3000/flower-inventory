// routes/flowers.js
import express from 'express';
import pool from '../db.js';
import { verifyToken } from './users.js'; // Ensure this middleware is exported from users.js

const router = express.Router();

// Search flowers
router.get('/search', async (req, res) => {
  const { name, minQuantity } = req.query;
  let sql = 'SELECT * FROM flowers WHERE 1=1';
  const params = [];
  
  try {
    if (name) {
      sql += ' AND name ILIKE $' + (params.length + 1);
      params.push(`%${name}%`);
    }
    
    // Only add quantity condition if minQuantity is provided
    if (minQuantity !== undefined && minQuantity !== '') {
      const quantity = parseInt(minQuantity);
      if (isNaN(quantity)) {
        return res.status(400).json({ error: 'minQuantity must be a valid number' });
      }
      sql += ' AND quantity >= $' + (params.length + 1);
      params.push(quantity);
    }

    //console.log('SQL:', sql); // Debug log
    //console.log('Params:', params); // Debug log
    
    const result = await pool.query(sql, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get all flowers
router.get('/', async (req, res) => {
  const sql = 'SELECT * FROM flowers';
  try {
    const result = await pool.query(sql);
    res.json(result.rows); 
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get a single flower by ID
router.get('/:id', async (req, res) => {
  const id = req.params.id;
  const sql = 'SELECT * FROM flowers WHERE id = $1';
  try {
    const result = await pool.query(sql, [id]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Flower not found' });
    } else {
      res.json(result.rows[0]);
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add a new flower
router.post('/', verifyToken, async (req, res) => {
  const { role } = req.user;
  if (role !== 'Admin' && role !== 'Manager') {
    return res.status(403).json({ error: 'Access denied' });
  }
  const { name, description, quantity, threshold } = req.body;
  const sql = 'INSERT INTO flowers (name, description, quantity,threshold) VALUES ($1, $2, $3, $4) RETURNING *';
  try {
    const result = await pool.query(sql, [name, description, quantity, threshold]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Check low stock for a specific flower
export const checkLowStock = async (flowerId) => {
  const sql = 'SELECT * FROM flowers WHERE id = $1 AND quantity <= threshold';
  try {
    const result = await pool.query(sql, [flowerId]);
    if (result.rows.length > 0) {
      const flower = result.rows[0];
      // Log the alert
      console.log(`Low stock alert for flower: ${flower.name} (Quantity: ${flower.quantity}, Threshold: ${flower.threshold})`);
      return true;
    }
    return false;
  } catch (err) {
    console.error('Error checking low stock:', err);
    return false;
  }
};

// route to get all flowers with low stock
router.get('/low-stock/all', verifyToken, async (req, res) => {
  try {
    const sql = `
      SELECT 
        id,
        name,
        description,
        quantity,
        threshold,
        (threshold - quantity) as shortage
      FROM flowers 
      WHERE quantity <= threshold
      ORDER BY (threshold - quantity) DESC
    `;
    
    const result = await pool.query(sql);
    
    const lowStockFlowers = result.rows.map(flower => ({
      id: flower.id,
      name: flower.name,
      description: flower.description,
      currentQuantity: flower.quantity,
      threshold: flower.threshold,
      shortage: flower.shortage,
      status: flower.quantity === 0 ? 'Out of Stock' : 'Low Stock'
    }));

    res.json(lowStockFlowers);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update a flower
router.put('/:id', verifyToken, async (req, res) => {
  const { role } = req.user;
  if (role !== 'Admin' && role !== 'Manager') {
    return res.status(403).json({ error: 'Access denied' });
  }
  const id = req.params.id;
  const { name, description, quantity } = req.body;
  const sql = 'UPDATE flowers SET name = $1, description = $2, quantity = $3 WHERE id = $4 RETURNING *';
  try {
    const result = await pool.query(sql, [name, description, quantity, id]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Flower not found' });
    } else {
      await checkLowStock(id);
      res.json(result.rows[0]);
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete a flower
router.delete('/:id', verifyToken, async (req, res) => {
  const { role } = req.user;
  if (role !== 'Admin') {
    return res.status(403).json({ error: 'Access denied' });
  }
  
  const id = req.params.id;
  
  try {
    // Start a transaction
    await pool.query('BEGIN');
    
    // First delete all reservations for this flower
    const deleteReservationsSql = 'DELETE FROM reservations WHERE flower_id = $1';
    await pool.query(deleteReservationsSql, [id]);
    
    // Then delete the flower
    const deleteFlowerSql = 'DELETE FROM flowers WHERE id = $1 RETURNING *';
    const result = await pool.query(deleteFlowerSql, [id]);
    
    if (result.rows.length === 0) {
      await pool.query('ROLLBACK');
      return res.status(404).json({ error: 'Flower not found' });
    }
    
    // Commit the transaction
    await pool.query('COMMIT');
    res.json({ message: 'Flower and associated reservations deleted successfully' });
    
  } catch (err) {
    await pool.query('ROLLBACK');
    res.status(500).json({ error: err.message });
  }
});



export default router;