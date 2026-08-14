# FlashCart AI - High-Performance Quick Commerce Ecosystem

FlashCart AI is a production-grade, state-of-the-art quick commerce ecosystem designed to deliver groceries, household goods, and wellness products in under 10 minutes. It integrates real-time rider tracking, sustainable packaging optimizations, and conversational AI-powered grocery shopping experiences.

---

## 🚀 The Core Philosophy

FlashCart AI bridges the gap between traditional delivery logistics and next-generation artificial intelligence. 
By leveraging the **Google Gemini SDK**, it optimizes shopper cart construction, automates healthy nutrition and meal planning, and tracks pantry inventory from standard snapshots.

---

## 🛠️ The Technology Stack

To ensure optimal speed, native performance, and extreme scalability, the FlashCart AI project implements separate dedicated codebases:

| Application Component | Production Technology Stack | Purpose / Architectural Role |
| :--- | :--- | :--- |
| **Customer App** | **Flutter (Dart) / Riverpod** | High-performance, compile-to-native Android & iOS application for consumers. |
| **Rider App** | **Flutter (Dart) / Google Maps** | Lightweight mobile app for delivery agents with live tracking. |
| **Admin Dashboard** | **React / TypeScript / Tailwind** | Collaborative admin panel to manage categories, products, prices, and track live deliveries. |
| **Backend API Server** | **TypeScript Node.js (Express)** | Core API gateway with Firebase Auth verification, PG client pool, and Gemini SDK hooks. |
| **Real-time Server** | **Socket.IO (WebSockets)** | Bi-directional coordinates streaming and live map markers syncing. |
| **Database** | **PostgreSQL (ACID)** | Normalized relational model. |
| **Push Channel** | **Firebase Admin Cloud Messaging** | Background notifications dispatch. |

### 💡 Sandbox Web Container
During development, the sandbox container served on `port 3000` is an interactive **React/Vite (TypeScript) Single Page Application** modeling all consumer, rider, and administrative features in a unified dashboard. This allows for immediate visual iteration, API testing, and live verification with full cloud backend integration.

---

## 📂 Repository Directory Structure

```
├── /backend                 # Node.js TypeScript Express Production Server
│   ├── package.json         # Backend node packages list
│   ├── tsconfig.json        # TypeScript compile configurations
│   └── /src                 # App, Controllers, Auth middleware, and Config pools
│
├── /mobile                  # Multiplatform Production Flutter App
│   ├── pubspec.yaml         # Dart package manager configuration
│   └── /lib                 # Core libraries, Features (Customer, Rider)
│
├── /docs                    # System Schemas, Handbooks, and REST Contracts
│   ├── README.md            # Root entry-point handbook
│   ├── ARCHITECTURE.md      # Microservice layout, Sequence diagrams, Caching rules
│   ├── API_DOCUMENTATION.md # REST and WebSocket contracts list
│   ├── SETUP.md             # Installation guidelines
│   ├── DATABASE.md          # Relational tables, relations, and connection setups
│   ├── DEPLOYMENT.md        # Cloud Run, PostgreSQL, and App Store publishing
│   ├── ENVIRONMENT_VARIABLES.md # Server environment variables mapping
│   ├── TROUBLESHOOTING.md   # Hotfix diagnostics, handshakes, pool leaks
│   └── SCHEMA.sql           # Database schema initialization
│
├── /src                     # React / Vite Web Sandbox Client App
│   ├── App.tsx              # Main orchestrator linking Customer, Rider, and Admin screens
│   ├── main.tsx             # DOM binder
│   ├── /components          # Interactive visual models (CustomerApp, RiderApp, AdminPanel)
│   └── types.ts             # Shared Typescript schema definitions
│
├── server.ts                # Sandbox unified full-stack server proxying backend REST routes
├── package.json             # Root dependency configuration
└── vite.config.ts           # Vite Bundler configurations
```

---

## 🏃 Quick Start Guide

Ready to spin up the workspace?

### 1. Unified Sandbox & Frontend Server
```bash
# 1. Install workspace node dependencies
npm install

# 2. Start the unified development server (Port 3000)
npm run dev
```

### 2. Native Flutter App
```bash
cd mobile
flutter pub get
flutter run
```

### 3. Dedicated Backend Server
```bash
cd backend
npm install
npm run dev
```

---

## 📖 Comprehensive Handbooks & Manuals

For deep handovers and maintenance procedures, please consult the complete handbook files located inside `/docs`:
* 🏗️ **[System Architecture Guide](./docs/ARCHITECTURE.md)**: Network flows, Caching designs, and Security policies.
* 💾 **[Database Design](./docs/DATABASE.md)**: Relational schema diagrams, keys, tables, and credentials routing.
* 📡 **[REST API Specifications](./docs/API_DOCUMENTATION.md)**: Payload schemas, headers, status codes.
* 🔧 **[Local Workspace Setup](./docs/SETUP.md)**: Step-by-step instructions for packages, local DB, and compilers.
* 📦 **[Cloud Deployment & Mobile Bundling](./docs/DEPLOYMENT.md)**: Google Cloud Run deployment, Apple App Store, Google Play Store guide.
* 🛡️ **[Security & Environment Variables](./docs/ENVIRONMENT_VARIABLES.md)**: Secrets management and configuration mappings.
* 🔍 **[Troubleshooting Guide](./docs/TROUBLESHOOTING.md)**: Diagnostics, connection leak remedies, WebSockets setups.
