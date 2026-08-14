# FlashCart AI - Troubleshooting & Diagnostics Guide

This document lists common issues, root causes, and clear remediation instructions for developers and administrators of the FlashCart AI ecosystem.

---

## 1. Socket.IO WebSocket Connection Failures

### Symptom:
The Rider map pointer does not update in real-time, or the client log shows:
`WebSocket connection failed: Error during WebSocket handshake`

### Root Causes & Fixes:
1. **Reverse Proxy Configuration**:
   * *Cause*: Your load balancer (e.g., Nginx or GCP Cloud Load Balancing) is not configured to forward the standard HTTP upgrade headers.
   * *Fix*: Ensure the headers `Upgrade: websocket` and `Connection: upgrade` are forwarded by your proxy:
     ```nginx
     proxy_set_header Upgrade $http_upgrade;
     proxy_set_header Connection "Upgrade";
     ```
2. **CORS Policy Restrictions**:
   * *Cause*: The server's Socket.IO initialization rejects connections from client origins.
   * *Fix*: Ensure `backend/src/app.ts` permits the correct origins:
     ```typescript
     const io = new Server(server, {
       cors: { origin: "https://your-domain.com", methods: ["GET", "POST"] }
     });
     ```

---

## 2. Gemini Assistant API Errors

### Symptom:
The smart ingredient-parsing assistant crashes with standard model error codes or refuses to answer.

### Root Causes & Fixes:
1. **Missing `GEMINI_API_KEY` Variable**:
   * *Cause*: The variable is not defined in the backend `.env` file, or has been loaded with a leading whitespace.
   * *Fix*: Check the loaded server configuration variables. Ensure the key is loaded without double quotes inside the host terminal.
2. **Unsupported SDK Call**:
   * *Cause*: Calling the old `@google/generative-ai` legacy SDK which has been deprecated.
   * *Fix*: Verify the code is importing the modern `@google/genai` TypeScript SDK:
     ```typescript
     import { GoogleGenAI } from '@google/genai';
     const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
     ```

---

## 3. PostgreSQL Database Connection Pools Exhausted

### Symptom:
The backend server slows down and eventually outputs:
`FATAL: remaining connection slots are reserved for non-replication superuser connections`

### Root Causes & Fixes:
1. **Leaked Database Clients**:
   * *Cause*: Instantiating a new database client instance on every REST request instead of utilizing a single global Pool.
   * *Fix*: Ensure all queries use the exported unified pool from `/backend/src/config/db.ts`:
     ```typescript
     import { dbPool } from './config/db';
     const result = await dbPool.query('SELECT * FROM products');
     ```
2. **Over-allocated Connection Limits**:
   * *Cause*: Express server pool limits exceed what PostgreSQL allows (default is 100 max connections).
   * *Fix*: Set a realistic pool size (`max: 20`) in your PG pool configuration.
