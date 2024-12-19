// routes/reservations.js
import express from 'express';
import pool from '../db.js';
import { verifyToken } from './users.js';
import { auditLog } from '../middleware/audit.js';
import { checkLowStock } from './flowers.js';

const router = express.Router();

// Create a new reservation (All users can create)
router.post('/', verifyToken, async (req, res) => {
  const userId = req.user.id;
  const { flower_id, quantity, sell_date, party_name } = req.body;
  const status = 'pending';
  const sql = `
    INSERT INTO reservations (user_id, flower_id, quantity, sell_date, party_name, status)
    VALUES ($1, $2, $3, $4, $5, $6) RETURNING *
  `;
  try {
    const result = await pool.query(sql, [userId, flower_id, quantity, sell_date, party_name, status]);
    await auditLog(userId, 'CREATE_RESERVATION', `Created reservation with ID ${result.rows[0].id}`,result.rows[0].id);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all reservations with filters
router.get('/', verifyToken, async (req, res) => {
  const { role, id: userId } = req.user;

  // Retrieve query parameters
  const { partyName, processedBy, flowerName, month } = req.query;

  let sql = `
    SELECT 
      reservations.*,
      users.username AS user_name,
      processed_by_user.username AS processed_by_name,
      flowers.name AS flower_name
    FROM reservations
    JOIN users ON reservations.user_id = users.id
    LEFT JOIN users AS processed_by_user ON reservations.processed_by = processed_by_user.id
    JOIN flowers ON reservations.flower_id = flowers.id
  `;

  const params = [];
  const conditions = [];

  // Restrict access for Staff
  if (role === 'Staff') {
    conditions.push(`reservations.user_id = $${params.length + 1}`);
    params.push(userId);
  }

  // Apply filters
  if (partyName) {
    conditions.push(`reservations.party_name ILIKE $${params.length + 1}`);
    params.push(`%${partyName}%`);
  }

  if (processedBy) {
    conditions.push(`processed_by_user.username ILIKE $${params.length + 1}`);
    params.push(`%${processedBy}%`);
  }

  if (flowerName) {
    conditions.push(`flowers.name ILIKE $${params.length + 1}`);
    params.push(`%${flowerName}%`);
  }

  if (month) {
    conditions.push(`EXTRACT(MONTH FROM reservations.sell_date) = $${params.length + 1}`);
    params.push(month);
  }

  if (conditions.length > 0) {
    sql += ' WHERE ' + conditions.join(' AND ');
  }

  sql += `
    ORDER BY 
      CASE WHEN reservations.status = 'processed' THEN 2 ELSE 1 END, 
      reservations.id;
  `;

  try {
    const result = await pool.query(sql, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching reservations:', err);
    res.status(500).json({ error: err.message });
  }
});


// Get a single reservation by ID
router.get('/:id', verifyToken, async (req, res) => {
  const id = req.params.id;
  const sql = `
    SELECT 
      reservations.*, 
      users.username AS processed_by_name, 
      flowers.name AS flower_name
    FROM reservations
    LEFT JOIN users ON reservations.processed_by = users.id
    LEFT JOIN flowers ON reservations.flower_id = flowers.id
    WHERE reservations.id = $1
  `;

  try {
    const result = await pool.query(sql, [id]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Reservation not found' });
    } else {
      res.json(result.rows[0]);
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update a reservation
router.put('/:id', verifyToken, async (req, res) => {
  const reservationId = req.params.id;
  const { quantity, sell_date, party_name, flower_id } = req.body;
  const { role, id: userId } = req.user;

  // Fetch existing reservation
  try {
    const resQuery = 'SELECT * FROM reservations WHERE id = $1';
    const resResult = await pool.query(resQuery, [reservationId]);
    if (resResult.rows.length === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    const reservation = resResult.rows[0];

    // Authorization
    if (role !== 'Admin' && role !== 'Manager' && reservation.user_id !== userId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    // Build update query
    let updateFields = [];
    let params = [];
    let paramIndex = 1;

    if (quantity !== undefined) {
      updateFields.push(`quantity = $${paramIndex++}`);
      params.push(quantity);
    }
    if (sell_date !== undefined) {
      updateFields.push(`sell_date = $${paramIndex++}`);
      params.push(sell_date);
    }
    if (party_name !== undefined) {
      updateFields.push(`party_name = $${paramIndex++}`);
      params.push(party_name);
    }
    if (flower_id !== undefined) {
      updateFields.push(`flower_id = $${paramIndex++}`);
      params.push(flower_id);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    const sql = `UPDATE reservations SET ${updateFields.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
    params.push(reservationId);

    const result = await pool.query(sql, params);
    // Delete previous audit log for this reservation
    await pool.query('DELETE FROM audit_logs WHERE details LIKE $1', [`%reservation with ID ${reservationId}%`]);

    // Add new audit log entry
    await auditLog(userId, 'UPDATE_RESERVATION', `Updated reservation with ID ${reservationId}`,reservationId); 

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Delete a reservation
router.delete('/:id', verifyToken, async (req, res) => {
  const reservationId = req.params.id;
  const { role, id: userId } = req.user;

  try {
    // First check if reservation exists
    const checkSql = 'SELECT * FROM reservations WHERE id = $1';
    const reservation = await pool.query(checkSql, [reservationId]);
    
    if (reservation.rows.length === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }

    // Authorization check
    if (role === 'Staff' && reservation.rows[0].user_id !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (role !== 'Admin' && role !== 'Manager' && role !== 'Staff') {
      return res.status(403).json({ error: 'Access denied' });
    }

    const deleteSql = 'DELETE FROM reservations WHERE id = $1 RETURNING *';
    await pool.query(deleteSql, [reservationId]);
    await auditLog(userId, 'DELETE_RESERVATION', `Deleted reservation with ID ${reservationId}`,reservationId);
    res.json({ message: 'Reservation deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete all processed reservations (Admin only)
router.delete('/processed/all', verifyToken, async (req, res) => {
  const { role, id: userId } = req.user;

  if (role !== 'Admin') {
    return res.status(403).json({ error: 'Access denied' });
  }

  try {
    const deleteSql = 'DELETE FROM reservations WHERE status = $1 RETURNING id';
    const result = await pool.query(deleteSql, ['processed']);

    const deletedIds = result.rows.map(row => row.id);

    // Audit log for each deleted reservation
    for (const reservationId of deletedIds) {
      await auditLog(userId, 'DELETE_PROCESSED_RESERVATION', `Deleted processed reservation with ID ${reservationId}`, reservationId);
    }

    res.json({ message: 'All processed reservations deleted successfully', deletedReservationIds: deletedIds });
  } catch (err) {
    console.error('Error deleting processed reservations:', err);
    res.status(500).json({ error: err.message });
  }
});


// Process a reservation (Admins and Managers only)
router.post('/process/:id', verifyToken, async (req, res) => {
  const reservationId = req.params.id;
  const { role,id: userId } = req.user;

  if (role !== 'Admin' && role !== 'Manager') {
    return res.status(403).json({ error: 'Access denied' });
  }

  try {
    // Fetch the reservation
    const resQuery = 'SELECT * FROM reservations WHERE id = $1';
    const resResult = await pool.query(resQuery, [reservationId]);
    if (resResult.rows.length === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    const reservation = resResult.rows[0];

    // Fetch the flower
    const flowerQuery = 'SELECT * FROM flowers WHERE id = $1';
    const flowerResult = await pool.query(flowerQuery, [reservation.flower_id]);
    if (flowerResult.rows.length === 0) {
      return res.status(404).json({ error: 'Flower not found' });
    }
    const flower = flowerResult.rows[0];

    // Check if there is enough stock
    if (flower.quantity < reservation.quantity) {
      return res.status(400).json({ error: 'Not enough stock available' });
    }

    // Start a transaction
    await pool.query('BEGIN');

    // Update the flower quantity
    const updateFlowerQuery = 'UPDATE flowers SET quantity = quantity - $1 WHERE id = $2 RETURNING *';
    await pool.query(updateFlowerQuery, [reservation.quantity, reservation.flower_id]);

    // Update the reservation
    const updateReservationSql = 'UPDATE reservations SET status = $1, processed_by = $2 WHERE id = $3';
    await pool.query(updateReservationSql, ['processed', userId, reservationId]);

    await auditLog(
      req.user.id,
      'PROCESS_RESERVATION',
      `Processed reservation ID: ${reservation.id} for flower ID: ${reservation.flower_id}`,
      reservation.id
    );

    // Commit the transaction
    await pool.query('COMMIT');

    // Check for low stock
    await checkLowStock(reservation.flower_id);

    res.json({ message: 'Reservation processed successfully' });
  } catch (err) {
    await pool.query('ROLLBACK');
    res.status(500).json({ error: err.message });
  }
});

export default router;