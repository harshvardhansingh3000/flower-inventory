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
    await auditLog(userId, 'CREATE_RESERVATION', `Created reservation with ID ${result.rows[0].id}`);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all reservations (All users can see all reservations)
router.get('/', verifyToken, async (req, res) => {
  const sql = 'SELECT * FROM reservations';
  try {
    const result = await pool.query(sql);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get a single reservation by ID (All users can access)
router.get('/:id', verifyToken, async (req, res) => {
  const id = req.params.id;
  const sql = 'SELECT * FROM reservations WHERE id = $1';
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
  const { quantity, sell_date, party_name, status } = req.body;
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
    if (role === 'Staff') {
      if (reservation.user_id !== userId) {
        return res.status(403).json({ error: 'Access denied' });
      }
    } else if (role === 'Admin' || role === 'Manager') {
      // Admins and Managers can update any reservation
    } else {
      // Other roles cannot update reservations
      return res.status(403).json({ error: 'Access denied' });
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
    if (status !== undefined) {
      // Allow status update only for Admins and Managers
      if (role === 'Admin' || role === 'Manager') {
        updateFields.push(`status = $${paramIndex++}`);
        params.push(status);
      } else {
        return res.status(403).json({ error: 'Access denied to change status' });
      }
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
    await auditLog(userId, 'UPDATE_RESERVATION', `Updated reservation with ID ${reservationId}`); 

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
    await auditLog(userId, 'DELETE_RESERVATION', `Deleted reservation with ID ${reservationId}`);
    res.json({ message: 'Reservation deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Process a reservation (Admins and Managers only)
router.post('/process/:id', verifyToken, async (req, res) => {
  const reservationId = req.params.id;
  const { role } = req.user;

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

    // Delete the reservation
    const deleteReservationQuery = 'DELETE FROM reservations WHERE id = $1 RETURNING *';
    await pool.query(deleteReservationQuery, [reservationId]);

    await auditLog(
      req.user.id,
      'PROCESS_RESERVATION',
      `Processed reservation ID: ${reservation.id} for flower ID: ${reservation.flower_id}`
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