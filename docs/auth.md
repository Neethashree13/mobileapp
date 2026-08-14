# Module 1: Authentication Architecture & API Documentation

## Overview
Module 1 implements an enterprise-grade, secure, multi-tenant authentication engine for **FlashCart AI**. It supports multi-factor authentication paths including **Email/Password Credentials**, **Google OAuth Single Sign-On**, **Phone SMS OTP Login**, **Remember Me Extended Lifespan**, **Refresh Token Rotation**, **Role-Based Access Control (RBAC)**, **Redis Session Management**, and **Cryptographic Password Recovery**.

---

## Technical Stack & Architecture
- **Runtime:** Node.js 22 LTS
- **Framework:** Express with TypeScript
- **ORM / Database:** Prisma ORM with PostgreSQL Database (`users`, `user_sessions`, `otp_verifications`, `login_history`, `audit_logs`)
- **Authentication Tokens:** Short-lived JWT Access Tokens (15m) + Rotated Refresh Tokens (7d standard / 30d Remember Me)
- **Hashing:** `bcryptjs` with salt rounds 10
- **Validation:** Zod Schema Validation
- **Session Cache & Revocation:** Redis In-Memory Session & Token Blacklist
- **Security Middlewares:** Helmet HTTP headers, `express-rate-limit` brute-force prevention, CORS origin filtering
- **Logging:** Winston Enterprise Logger + Audit Logging

---

## Authentication Flow & Token Lifecycle

1. **Sign Up / Login:**
   - User authenticates via `/api/auth/register`, `/api/auth/login`, `/api/auth/google`, or `/api/auth/verify-otp`.
   - Credentials are verified using `bcrypt.compare` or verified OAuth/OTP assertions.
   - An **Access Token** (15 minutes validity) and a **Refresh Token** (7 days or 30 days if `rememberMe: true`) are generated.
   - The session is stored in PostgreSQL (`user_sessions`) and cached in Redis.

2. **Access Token Usage & RBAC:**
   - Clients send `Authorization: Bearer <access_token>` in HTTP request headers.
   - `authenticateJWT` checks if the token is blacklisted in Redis.
   - `requireRole('ADMIN')` enforces Role-Based Access Control.

3. **Refresh Token Rotation:**
   - Upon access token expiration, the client posts to `/api/auth/refresh` with `{ refreshToken }`.
   - The server verifies the token signature and active session state in DB/Redis.
   - The old refresh token is immediately invalidated (revoked).
   - A fresh access token and a brand new rotated refresh token are issued.

4. **Logout:**
   - Calling `/api/auth/logout` invalidates the active session and blacklists the current access token in Redis.

---

## API Endpoints Reference

### 1. Register Account
`POST /api/auth/register`
- **Request Body:**
```json
{
  "email": "user@flashcart.ai",
  "password": "SecurePassword123",
  "firstName": "Alex",
  "lastName": "Morgan",
  "phone": "9876543210",
  "role": "USER",
  "rememberMe": true
}
```
- **Response (201 Created):**
```json
{
  "success": true,
  "message": "User account created successfully",
  "user": {
    "id": "u_9a8f7b",
    "email": "user@flashcart.ai",
    "firstName": "Alex",
    "lastName": "Morgan",
    "role": "USER"
  },
  "tokens": {
    "accessToken": "eyJhbGciOi...",
    "refreshToken": "eyJhbGciOi...",
    "tokenType": "Bearer",
    "expiresIn": 900
  }
}
```

### 2. Login (Email / Phone & Password)
`POST /api/auth/login`
- **Request Body:**
```json
{
  "email": "user@flashcart.ai",
  "password": "SecurePassword123",
  "rememberMe": true
}
```

### 3. Google OAuth Login
`POST /api/auth/google`
- **Request Body:**
```json
{
  "firebaseUid": "GOOGLE_UID_991823",
  "email": "alex.google@gmail.com",
  "firstName": "Alex",
  "lastName": "Google",
  "profilePhoto": "https://lh3.googleusercontent.com/..."
}
```

### 4. Send SMS OTP
`POST /api/auth/send-otp`
- **Request Body:**
```json
{
  "phone": "9876543210"
}
```

### 5. Verify SMS OTP
`POST /api/auth/verify-otp`
- **Request Body:**
```json
{
  "phone": "9876543210",
  "otp": "123456"
}
```

### 6. Refresh Token Rotation
`POST /api/auth/refresh`
- **Request Body:**
```json
{
  "refreshToken": "eyJhbGciOi..."
}
```

### 7. Logout
`POST /api/auth/logout`
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**
```json
{
  "refreshToken": "eyJhbGciOi..."
}
```

### 8. Forgot Password
`POST /api/auth/forgot-password`
- **Request Body:**
```json
{
  "email": "user@flashcart.ai"
}
```

### 9. Reset Password
`POST /api/auth/reset-password`
- **Request Body:**
```json
{
  "email": "user@flashcart.ai",
  "otp": "123456",
  "newPassword": "BrandNewPassword123"
}
```

### 10. Get Profile
`GET /api/auth/profile`
- **Headers:** `Authorization: Bearer <access_token>`

### 11. Update Profile
`PUT /api/auth/profile`
- **Headers:** `Authorization: Bearer <access_token>`
- **Request Body:**
```json
{
  "firstName": "Alex",
  "lastName": "Updated",
  "phoneNumber": "9876543210"
}
```

---

## Database Schemas (Prisma ORM)

### Users (`users`)
- `id` (String UUID, Primary Key)
- `email` (String, Unique)
- `phone` (String, Unique)
- `passwordHash` (String)
- `firstName`, `lastName`, `profilePhoto`
- `role` (`USER`, `ADMIN`, `SUPER_ADMIN`, `DELIVERY_PARTNER`)
- `authProvider` (`LOCAL`, `GOOGLE`, `OTP`, `FIREBASE`)
- `isVerified`, `isActive`, `walletBalance`, `streakCount`

### User Sessions (`user_sessions`)
- `id` (String UUID, Primary Key)
- `userId` (Foreign Key -> `users.id`)
- `refreshToken` (String, Unique)
- `isRememberMe` (Boolean)
- `expiresAt` (DateTime)
- `loginTime`, `logoutTime`

### Audit Logs (`audit_logs`)
- `id` (String UUID)
- `userId` (Foreign Key -> `users.id`)
- `action` (String)
- `details` (String)
- `ipAddress` (String)
- `createdAt` (DateTime)
