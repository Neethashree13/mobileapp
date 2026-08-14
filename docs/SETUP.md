# FlashCart AI - Production Setup Guide

This document describes step-by-step instructions for installing dependencies, configuring databases, and running the development environments for all components of the FlashCart AI ecosystem.

---

## 1. System Requirements

Before starting, ensure your local development machine has the following software installed:
* **Node.js**: v18.0.0 or higher (LTS recommended)
* **Flutter SDK**: v3.16.0 or higher (Stable channel)
* **Dart SDK**: Sourced automatically with Flutter
* **PostgreSQL**: v14.0 or higher
* **Firebase CLI**: For managing security rules and push channels

---

## 2. Shared Workspace Structure

The project is structured as a monorepo for clean isolation between components:
* `/backend`: Production Node.js TypeScript API service
* `/mobile`: Native multiplatform Flutter application
* `/docs`: Normalized database SQL schemas and REST contracts
* `/src` & `/server.ts`: Live interactive web sandbox container running in AI Studio

---

## 3. Database Setup (PostgreSQL)

1. **Install PostgreSQL**: Ensure your Postgres service is active on your host system (default port: `5432`).
2. **Create Database**: Open your terminal or a graphical tool like pgAdmin / DBeaver and run:
   ```sql
   CREATE DATABASE flashcart_db;
   ```
3. **Execute Production Schema**: Connect to the newly created database and run the schema file located in the workspace:
   ```bash
   psql -h localhost -U postgres -d flashcart_db -f ./docs/SCHEMA.sql
   ```
4. **Seed Initial Catalog Data**: (See database documentation `/docs/DATABASE.md` for seed queries).

---

## 4. Backend Service Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install npm dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
   *Fill in your PostgreSQL credentials, Firebase Project ID, and Google Gemini API Key.*
4. Start development server using TSX (Hot-reloading TypeScript):
   ```bash
   npm run dev
   ```
5. Verify health:
   ```bash
   curl http://localhost:3000/api/health
   ```

---

## 5. Mobile Application Setup (Flutter)

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```
2. Fetch Flutter packages and compile native bindings:
   ```bash
   flutter pub get
   ```
3. Verify Flutter environment state:
   ```bash
   flutter doctor
   ```
4. Run code generators (Riverpod annotations):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. **Run the application**:
   * **Android Emulator / Device**:
     ```bash
     flutter run -d android
     ```
   * **iOS Simulator / Device**:
     ```bash
     flutter run -d ios
     ```

---

## 6. Live Sandbox Web Dashboard Setup (Vite)

To run the interactive sandbox web app dashboard locally:
1. Install root dependencies:
   ```bash
   npm install
   ```
2. Run development script:
   ```bash
   npm run dev
   ```
3. Open in browser: `http://localhost:3000`
