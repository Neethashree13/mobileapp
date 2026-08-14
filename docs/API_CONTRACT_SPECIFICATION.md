# FlashCart AI - Production API Contract Specification (/api/v1)

**Version:** 1.0.0  
**Architect:** Principal Backend Architect  
**Specification Format:** OpenAPI 3.1.0  
**Protocol:** HTTPS REST / JSON  
**Base URL:** `https://api.flashcart.ai/api/v1`

---

## 🏛️ 1. API Architecture & Standards

### 1.1 Core Principles
1. **RESTful Architecture:** Clear resource-oriented URLs with standard HTTP verbs (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`).
2. **Strict Versioning:** Prefixed with `/api/v1`. Breaking changes require a major version bump (`/api/v2`).
3. **Authentication & Authorization:**
   - **Authentication:** Stateless JSON Web Tokens (JWT) issued via HTTP-Only cookies or `Authorization: Bearer <token>`.
   - **Refresh Tokens:** High-entropy refresh token rotated on every issuance with strict user-agent and IP binding.
   - **Role-Based Access Control (RBAC):** Roles enforced across `CUSTOMER`, `RIDER`, `STORE_MANAGER`, and `ADMIN`.
4. **Standard Envelope:** All API responses adhere to a uniform payload wrapper.

### 1.2 Standardized Response Envelopes

#### Success Response Envelope (`200 OK`, `201 Created`)
```json
{
  "success": true,
  "data": {},
  "meta": {
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 120,
      "totalPages": 6
    },
    "timestamp": "2026-07-21T21:12:00Z",
    "requestId": "req_8f92a10b4c"
  }
}
```

#### Error Response Envelope (`400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `429 Rate Limited`)
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request payload provided.",
    "details": [
      {
        "field": "email",
        "issue": "Must be a valid email address format."
      }
    ]
  },
  "meta": {
    "timestamp": "2026-07-21T21:12:00Z",
    "requestId": "req_8f92a10b4c"
  }
}
```

---

## 🌳 2. API Module Tree

```text
/api/v1
├── /auth
│   ├── POST /register
│   ├── POST /login
│   ├── POST /refresh
│   ├── POST /logout
│   ├── POST /send-otp
│   ├── POST /verify-otp
│   ├── POST /forgot-password
│   └── POST /reset-password
├── /users
│   ├── GET/PUT /me/profile
│   ├── GET/PUT /me/settings
│   ├── GET/PUT /me/preferences
│   └── GET/POST/DELETE /me/addresses
├── /products
│   ├── GET /
│   ├── GET /{id}
│   ├── GET /{id}/variants
│   ├── GET /brands
│   ├── GET /categories
│   └── GET /inventory
├── /search
│   ├── GET /
│   ├── POST /voice
│   ├── POST /image
│   └── GET /recommendations
├── /cart
│   ├── GET /
│   ├── POST /items
│   ├── PUT /items/{id}
│   └── DELETE /items/{id}
├── /wishlist
│   ├── GET /
│   ├── POST /items
│   └── DELETE /items/{id}
├── /orders
│   ├── POST /
│   ├── GET /
│   ├── GET /{id}
│   ├── POST /{id}/cancel
│   └── GET /{id}/tracking
├── /payments
│   ├── POST /upi/initiate
│   ├── POST /card/process
│   ├── POST /wallet/pay
│   └── POST /{id}/refund
├── /coupons
│   ├── POST /validate
│   ├── POST /apply
│   └── DELETE /remove
├── /wallet
│   ├── GET /balance
│   ├── GET /transactions
│   └── POST /topup
├── /delivery
│   ├── GET /assignments
│   ├── POST /assignments/{id}/accept
│   ├── GET /orders/{id}/tracking
│   └── POST /orders/{id}/verify-otp
├── /reviews
│   ├── GET /products/{id}
│   └── POST /
├── /notifications
│   ├── GET /
│   ├── PATCH /{id}/read
│   └── POST /push-token
├── /admin
│   ├── GET /dashboard
│   ├── GET/POST/PUT /products
│   ├── GET/PATCH /orders
│   ├── GET/PATCH /users
│   ├── GET/POST /coupons
│   └── GET /analytics
├── /store
│   ├── GET /picking
│   ├── POST /packing/{id}/complete
│   ├── GET/PUT /inventory
│   └── POST /returns
├── /partner
│   ├── GET /orders
│   ├── GET /earnings
│   ├── GET /wallet
│   └── GET /performance
├── /ai
│   ├── POST /assistant
│   ├── GET/POST /recipes
│   ├── GET/PUT /budget-planner
│   ├── POST /pantry-scanner
│   └── GET /analytics
└── /support
    ├── GET/POST /tickets
    ├── GET/POST /tickets/{id}/chat
    └── GET /faq
```

---

## 📋 3. Detailed Endpoint Catalog & Schemas

### 3.1 AUTHENTICATION MODULE

#### 1. `POST /api/v1/auth/register`
- **Desc:** Register new customer or delivery partner account.
- **Auth:** Public
- **Rate Limit:** 5 req/min per IP
- **Request Body:**
```json
{
  "email": "user@flashcart.ai",
  "phone": "+919876543210",
  "password": "SecurePassword123!",
  "firstName": "Rahul",
  "lastName": "Sharma",
  "role": "CUSTOMER"
}
```
- **Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr-8f92a10b",
      "email": "user@flashcart.ai",
      "phone": "+919876543210",
      "role": "CUSTOMER",
      "referralCode": "RAHUL100"
    },
    "tokens": {
      "accessToken": "eyJhbGciOi...",
      "refreshToken": "d8f1e92a...",
      "tokenType": "Bearer",
      "expiresInSeconds": 3600
    }
  }
}
```

#### 2. `POST /api/v1/auth/login`
- **Desc:** Authenticate via password or OTP.
- **Auth:** Public
- **Rate Limit:** 10 req/min
- **Request Body:**
```json
{
  "loginIdentifier": "user@flashcart.ai",
  "password": "SecurePassword123!"
}
```

#### 3. `POST /api/v1/auth/refresh`
- **Desc:** Rotate expired access token using valid refresh token.
- **Request Body:**
```json
{
  "refreshToken": "d8f1e92a..."
}
```

#### 4. `POST /api/v1/auth/send-otp`
- **Request Body:** `{ "phone": "+919876543210", "purpose": "LOGIN" }`

#### 5. `POST /api/v1/auth/verify-otp`
- **Request Body:** `{ "phone": "+919876543210", "otp": "584920" }`

---

### 3.2 USERS MODULE

#### `GET /api/v1/users/me/profile`
- **Auth:** Required (`CUSTOMER`, `RIDER`, `STORE_MANAGER`, `ADMIN`)
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "id": "usr-8f92a10b",
    "email": "user@flashcart.ai",
    "phone": "+919876543210",
    "firstName": "Rahul",
    "lastName": "Sharma",
    "avatarUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
    "dietaryPreferences": ["Organic", "High Protein"],
    "referralCode": "RAHUL100"
  }
}
```

#### `GET /api/v1/users/me/addresses`
- **Response `200 OK`:** Returns list of user's saved addresses.

---

### 3.3 PRODUCTS & CATALOG MODULE

#### `GET /api/v1/products`
- **Auth:** Public
- **Query Params:** `page=1`, `limit=20`, `categoryId=cat-1`, `search=mango`, `sortBy=price`, `sortOrder=asc`
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": [
    {
      "id": "prod-101",
      "name": "Organic Alphonso Mangoes",
      "price": 499,
      "unit": "1 kg",
      "rating": 4.8,
      "deliveryTimeMins": 10,
      "ecoScore": "A",
      "imageUrl": "https://images.unsplash.com/photo-1553279768-865429fa0078"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

---

### 3.4 CART MODULE

#### `GET /api/v1/cart`
- **Auth:** Required (`CUSTOMER`)
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "id": "cart-901",
    "userId": "usr-8f92a10b",
    "items": [
      {
        "id": "item-1",
        "productId": "prod-101",
        "quantity": 2,
        "unitPrice": 499,
        "totalPrice": 998
      }
    ],
    "subtotal": 998,
    "deliveryFee": 0,
    "discountAmount": 50,
    "taxAmount": 25,
    "totalAmount": 973
  }
}
```

---

### 3.5 ORDERS & CHECKOUT MODULE

#### `POST /api/v1/orders`
- **Auth:** Required (`CUSTOMER`)
- **Request Body:**
```json
{
  "addressId": "addr-12",
  "paymentMethod": "UPI",
  "appliedCouponCode": "FLASH50"
}
```
- **Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "orderId": "ord-49201",
    "orderNumber": "FC-902814",
    "status": "PLACED",
    "totalAmount": 973,
    "estimatedDeliveryMinutes": 10,
    "paymentDetails": {
      "method": "UPI",
      "status": "PENDING",
      "upiIntentUrl": "upi://pay?pa=flashcart@bank&am=973&tn=FC-902814"
    }
  }
}
```

---

### 3.6 DELIVERY PARTNER MODULE

#### `GET /api/v1/delivery/assignments`
- **Auth:** Required (`RIDER`)
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": [
    {
      "assignmentId": "asgn-001",
      "orderNumber": "FC-902814",
      "pickupStore": "FlashCart DarkStore Indiranagar",
      "pickupGeo": { "lat": 12.9716, "lng": 77.5946 },
      "deliveryAddress": "42, 100ft Road Indiranagar",
      "deliveryGeo": { "lat": 12.9750, "lng": 77.6000 },
      "earningsInr": 45,
      "estimatedDistanceKm": 1.8
    }
  ]
}
```

#### `POST /api/v1/delivery/orders/{id}/verify-otp`
- **Request Body:** `{ "otp": "9421" }`
- **Response `200 OK`:** `{ "success": true, "status": "DELIVERED" }`

---

### 3.7 AI & SMART SHOPPING MODULE

#### `POST /api/v1/ai/assistant`
- **Auth:** Required (`CUSTOMER`)
- **Request Body:**
```json
{
  "prompt": "I want to cook high-protein butter chicken under 30 mins for 4 people.",
  "includePantryCheck": true
}
```
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "recipeTitle": "Quick High-Protein Butter Chicken",
    "prepTimeMinutes": 25,
    "caloriesPerServing": 420,
    "missingIngredients": [
      { "productId": "prod-chicken-500g", "name": "Fresh Chicken Breast 500g", "price": 220 },
      { "productId": "prod-butter-100g", "name": "Organic Butter 100g", "price": 60 }
    ],
    "totalAddCount": 2,
    "totalBundlePrice": 280
  }
}
```

---

## 🛑 4. Comprehensive Error Catalog

| Error Code | HTTP Status | Description |
| :--- | :--- | :--- |
| `INVALID_CREDENTIALS` | `401 Unauthorized` | Invalid email/phone or password provided. |
| `TOKEN_EXPIRED` | `401 Unauthorized` | Access token or refresh token has expired. |
| `INSUFFICIENT_PERMISSIONS` | `403 Forbidden` | User role does not have authorization for resource. |
| `OUT_OF_STOCK` | `422 Unprocessable` | Item in cart exceeds available dark store inventory. |
| `COUPON_EXPIRED` | `400 Bad Request` | Applied coupon code has expired or reached usage limit. |
| `PAYMENT_FAILED` | `402 Payment Required` | UPI/Card transaction rejected by payment gateway. |
| `RATE_LIMIT_EXCEEDED` | `429 Too Many Requests` | Exceeded API rate limit threshold. |

---

## 🔄 5. Key Lifecycle API Flows

### 5.1 Order Lifecycle Flow
1. **Cart Creation:** `GET /api/v1/cart` -> `POST /api/v1/cart/items`
2. **Coupon Application:** `POST /api/v1/coupons/apply`
3. **Checkout & Order Creation:** `POST /api/v1/orders` (Status: `PLACED`)
4. **Store Fulfillment:** `GET /api/v1/store/picking` -> `POST /api/v1/store/packing/{id}/complete` (Status: `PACKED`)
5. **Rider Acceptance:** `POST /api/v1/delivery/assignments/{id}/accept` (Status: `OUT_FOR_DELIVERY`)
6. **Customer Live Tracking:** `GET /api/v1/orders/{id}/tracking`
7. **Delivery Verification:** `POST /api/v1/delivery/orders/{id}/verify-otp` (Status: `DELIVERED`)

---

## 📄 6. OpenAPI 3.1 Declaration File Location
The machine-readable OpenAPI 3.1 JSON definition file is accessible at `/docs/openapi_v1.json`.
