# FlashCart AI - Environment Variables Reference

This document defines all environment variables required to run the production Node.js Express backend API server and connecting databases.

---

## 1. Core Platform Configuration

### `NODE_ENV`
* **Description**: Describes the software lifecycle environment.
* **Possible Values**: `development` or `production`
* **Where to Obtain**: Set manually on build pipelines or container runtimes.

### `PORT`
* **Description**: Port on which the Express web server listens for API and WebSocket requests.
* **Default Value**: `3000`

---

## 2. PostgreSQL Relational Database Credentials

These parameters configure the PG client pool connected to your persistent storage.

### `PGHOST`
* **Description**: The hostname or IP address of your PostgreSQL database.
* **Example**: `127.0.0.1` (Local development) or `10.23.4.15` (Private cloud database VPC)

### `PGPORT`
* **Description**: Database TCP port connection.
* **Default Value**: `5432`

### `PGDATABASE`
* **Description**: The targeted database catalog name.
* **Example**: `flashcart_db`

### `PGUSER`
* **Description**: The database role credentials authorized to query and modify tables.
* **Example**: `postgres` (development) or `db_runner_prod` (production)

### `PGPASSWORD`
* **Description**: The secret password associated with the database user.

---

## 3. Google Gemini Large Language Model SDK

### `GEMINI_API_KEY`
* **Description**: The API key authorizing server-side calls using the `@google/genai` TypeScript SDK.
* **Where to Obtain**: Google AI Studio (https://aistudio.google.com/)
* **Security Notice**: This is a server-only secret. **Never** expose this key to browser clients, compile it into Flutter mobile assets, or prefix it with `VITE_`.

---

## 4. Firebase Cloud Admin Services

### `FIREBASE_PROJECT_ID`
* **Description**: The unique identifier of your Firebase Console project. Used to verify Auth tokens and dispatch push notifications.
* **Where to Obtain**: Firebase Console Settings panel.
* **Example**: `flashcart-ai-prod`

### `GOOGLE_APPLICATION_CREDENTIALS`
* **Description**: Absolute path to your Firebase Service Account JSON credential key file.
* **Where to Obtain**: Firebase Console -> Project Settings -> Service Accounts -> Generate New Private Key.
