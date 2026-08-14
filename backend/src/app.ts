import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';

// Middleware & Service imports
import { requireAuth } from './middleware/auth.js';
import * as aiService from './services/ai.js';
import { pool } from './config/db.js';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

const PORT = parseInt(process.env.PORT || '3000', 10);

app.use(cors());
app.use(express.json({ limit: '15mb' }));

// ----------------------------------------------------
// 1. HEALTHCHECK
// ----------------------------------------------------
app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

// ----------------------------------------------------
// 2. PRODUCT CATALOG & SEARCH ROUTES
// ----------------------------------------------------
app.get('/api/products', async (req, res) => {
  try {
    const { category, healthy, organic } = req.query;
    let queryStr = 'SELECT * FROM products WHERE 1=1';
    const params: any[] = [];

    if (category) {
      params.push(category);
      queryStr += ` AND category_id = $${params.length}`;
    }
    if (healthy === 'true') {
      queryStr += ' AND is_healthy = true';
    }
    if (organic === 'true') {
      queryStr += ' AND is_organic = true';
    }

    const { rows } = await pool.query(queryStr, params);
    res.json(rows);
  } catch (error: any) {
    res.status(500).json({ error: 'Database catalog retrieval failed', details: error.message });
  }
});

app.get('/api/search', async (req, res) => {
  try {
    const { q, mood } = req.query;
    if (!q) {
      return res.status(400).json({ error: 'Search query parameter "q" is required' });
    }

    const params = [`%${q}%`];
    let queryStr = 'SELECT * FROM products WHERE name ILIKE $1';

    if (mood === 'Gym') {
      queryStr += ' AND (protein_g > 5 OR is_healthy = true)';
    } else if (mood === 'Lazy') {
      queryStr += ' AND (category_id = \'snacks\' OR delivery_time_mins <= 8)';
    }

    const { rows } = await pool.query(queryStr, params);
    return res.json({ query: q, results: rows });
  } catch (error: any) {
    return res.status(500).json({ error: 'Product search failed', details: error.message });
  }
});

// ----------------------------------------------------
// 3. SECURE BASKET / CART ROUTES
// ----------------------------------------------------
app.get('/api/cart', requireAuth, async (req: any, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT c.quantity, c.added_by as "addedBy", p.* 
       FROM cart_items c 
       JOIN products p ON c.product_id = p.id 
       JOIN users u ON c.user_id = u.id 
       WHERE u.firebase_uid = $1`,
      [req.user.uid]
    );
    res.json({ items: rows });
  } catch (error: any) {
    res.status(500).json({ error: 'Failed to retrieve cart items', details: error.message });
  }
});

app.post('/api/cart/sync', requireAuth, async (req: any, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    // Resolve internal user id from Firebase UID
    const userRes = await client.query('SELECT id FROM users WHERE firebase_uid = $1', [req.user.uid]);
    if (userRes.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'User profile not synchronized' });
    }
    const userId = userRes.rows[0].id;

    // Delete existing cart items
    await client.query('DELETE FROM cart_items WHERE user_id = $1', [userId]);

    // Insert new sync cart list
    const { items = [] } = req.body;
    for (const item of items) {
      await client.query(
        'INSERT INTO cart_items (user_id, product_id, quantity, added_by) VALUES ($1, $2, $3, $4)',
        [userId, item.productId, item.quantity, item.addedBy || 'Self']
      );
    }

    await client.query('COMMIT');
    return res.json({ status: 'synced', itemsCount: items.length });
  } catch (error: any) {
    await client.query('ROLLBACK');
    return res.status(500).json({ error: 'Failed to sync cart', details: error.message });
  } finally {
    client.release();
  }
});

// ----------------------------------------------------
// 4. ORDER TRANSACTIONS & PLACEMENT
// ----------------------------------------------------
app.post('/api/orders', requireAuth, async (req: any, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { items, paymentMethod, totalAmount } = req.body;

    const userRes = await client.query('SELECT id, wallet_balance FROM users WHERE firebase_uid = $1', [req.user.uid]);
    if (userRes.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'User profile not verified' });
    }

    const user = userRes.rows[0];
    if (paymentMethod === 'Shared Wallet (Family)' && user.wallet_balance < totalAmount) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Insufficient funds in wallet' });
    }

    // Deduct Balance if Shared Wallet
    if (paymentMethod === 'Shared Wallet (Family)') {
      await client.query('UPDATE users SET wallet_balance = wallet_balance - $1 WHERE id = $2', [totalAmount, user.id]);
    }

    const orderId = 'FC-' + Math.random().toString(36).substring(2, 9).toUpperCase();

    // Insert Order
    await client.query(
      `INSERT INTO orders (id, user_id, status, subtotal, delivery_fee, discount, total, delivery_address_text, payment_method, payment_status)
       VALUES ($1, $2, 'placed', $3, 0.00, 0.00, $4, 'Symphony Premium Apts, Koramangala, Bangalore', $5, 'completed')`,
      [orderId, user.id, totalAmount, totalAmount, paymentMethod]
    );

    // Save order items snapshots
    for (const item of items) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, product_name_snapshot, price_snapshot, quantity, added_by_member)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [orderId, item.productId, item.name, item.price, item.quantity, item.addedBy]
      );
    }

    // Provision Delivery & Rider Track entry
    await client.query(
      `INSERT INTO deliveries (order_id, rider_name, rider_phone, current_latitude, current_longitude, status)
       VALUES ($1, 'Suresh Kumar', '+91 98765 43210', 12.9279, 77.6250, 'assigned')`,
      [orderId]
    );

    await client.query('COMMIT');
    return res.status(201).json({
      status: 'placed',
      orderId,
      totalAmount,
      walletBalanceRemaining: paymentMethod === 'Shared Wallet (Family)' ? user.wallet_balance - totalAmount : user.wallet_balance,
      estimatedDeliveryTime: '9 Mins',
    });
  } catch (error: any) {
    await client.query('ROLLBACK');
    return res.status(500).json({ error: 'Order placement transaction failed', details: error.message });
  } finally {
    client.release();
  }
});

// ----------------------------------------------------
// 5. SECURE AI ADVANCED SERVICE ROLES (GEMINI)
// ----------------------------------------------------
app.post('/api/gemini/assistant', requireAuth, async (req, res) => {
  try {
    const { prompt, currentCart = [] } = req.body;
    const aiResult = await aiService.runShoppingAssistant(prompt, currentCart);
    res.json(aiResult);
  } catch (error: any) {
    res.status(500).json({ error: 'AI Assistant failed', details: error.message });
  }
});

app.post('/api/gemini/meal-generator', requireAuth, async (req, res) => {
  try {
    const { diet, cuisine, calories, budget } = req.body;
    const plan = await aiService.runMealPlanner(diet, cuisine, calories, budget);
    res.json(plan);
  } catch (error: any) {
    res.status(500).json({ error: 'AI Meal Generator failed', details: error.message });
  }
});

app.post('/api/gemini/recipe-helper', requireAuth, async (req, res) => {
  try {
    const { recipeName } = req.body;
    const recipe = await aiService.runRecipeBuilder(recipeName);
    res.json(recipe);
  } catch (error: any) {
    res.status(500).json({ error: 'AI Recipe Builder failed', details: error.message });
  }
});

app.post('/api/gemini/pantry-scanner', requireAuth, async (req, res) => {
  try {
    const { imageBase64 } = req.body;
    if (!imageBase64) {
      return res.status(400).json({ error: 'imageBase64 photo string is required' });
    }
    const scanResult = await aiService.runPantryScanner(imageBase64);
    return res.json(scanResult);
  } catch (error: any) {
    return res.status(500).json({ error: 'AI Pantry Scanner failed', details: error.message });
  }
});

// ----------------------------------------------------
// 6. SOCKET.IO CHANNELS - COORDINATE SYNC & ORDERS
// ----------------------------------------------------
io.on('connection', (socket) => {
  console.log(`Active real-time tracking node connected: ${socket.id}`);

  // Rider updates order delivery coordinates
  socket.on('rider:push_coordinates', (data: { orderId: string; lat: number; lng: number; bearing: number; status: string }) => {
    // Broadcast immediately to listening customers subscribing to this specific order ID
    io.emit(`order:track:${data.orderId}`, {
      lat: data.lat,
      lng: data.lng,
      bearing: data.bearing,
      status: data.status,
    });
  });

  socket.on('disconnect', () => {
    console.log(`Tracking client disconnected: ${socket.id}`);
  });
});

httpServer.listen(PORT, '0.0.0.0', () => {
  console.log(`FlashCart AI Back-end microservices listening on port ${PORT}`);
});
