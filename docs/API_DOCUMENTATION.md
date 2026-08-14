# FlashCart AI - REST API Specifications & Contracts

This document contains the OpenAPI-style API specification for the FlashCart AI full-stack backend service. All endpoints require a `Content-Type: application/json` header. Protected endpoints mandate a Bearer token authorization header: `Authorization: Bearer <firebase_auth_jwt_token>`.

---

## 1. Authentication Services

### Register/Sync User Profile
* **Endpoint**: `POST /api/auth/sync`
* **Security**: Protected (Bearer Token)
* **Description**: Exchanges and verifies the Firebase ID Token. Upserts the user record into the PostgreSQL database.
* **Request Payload**:
```json
{
  "firstName": "Arav",
  "lastName": "Sharma",
  "phoneNumber": "+91 98765 43210"
}
```
* **Success Response (200 OK)**:
```json
{
  "status": "success",
  "user": {
    "id": "6c8cf8bf-8b27-4645-8f65-276602324976",
    "firebaseUid": "FBAUTH_UID_9921",
    "email": "arav@example.com",
    "firstName": "Arav",
    "lastName": "Sharma",
    "phone": "+91 98765 43210",
    "walletBalance": 1200.00,
    "streakCount": 5
  }
}
```

---

## 2. User & Address Management

### Get User Profile
* **Endpoint**: `GET /api/users/profile`
* **Security**: Protected
* **Success Response (200 OK)**:
```json
{
  "id": "6c8cf8bf-8b27-4645-8f65-276602324976",
  "email": "arav@example.com",
  "walletBalance": 1200.00,
  "streakCount": 5,
  "familyId": "df818319-38b4-4b47-a892-23c8e4d29321"
}
```

### List User Addresses
* **Endpoint**: `GET /api/users/addresses`
* **Security**: Protected
* **Success Response (200 OK)**:
```json
[
  {
    "id": "ad012891-b0e2-45e3-99ab-62738fa22109",
    "title": "Home",
    "addressLine1": "Symphony Premium Apts, Koramangala 3rd Block",
    "addressLine2": "Apartment 4B, Tower A",
    "landmark": "Near Sony Signal",
    "city": "Bangalore",
    "state": "Karnataka",
    "postalCode": "560034",
    "latitude": 12.9348,
    "longitude": 77.6189,
    "isDefault": true
  }
]
```

### Create Address
* **Endpoint**: `POST /api/users/addresses`
* **Security**: Protected
* **Request Payload**:
```json
{
  "title": "Office",
  "addressLine1": "Indiranagar Double Road, 80 Feet Rd",
  "addressLine2": "Indiranagar 1st Stage",
  "landmark": "Metro Station Pillar 50",
  "city": "Bangalore",
  "state": "Karnataka",
  "postalCode": "560008",
  "latitude": 12.9716,
  "longitude": 77.6412,
  "isDefault": false
}
```
* **Success Response (201 Created)**:
```json
{
  "status": "created",
  "id": "cd0128fa-b0ff-4e78-bcde-62738fa99100"
}
```

---

## 3. Product Catalog & Categories

### List Categories
* **Endpoint**: `GET /api/categories`
* **Security**: Public
* **Success Response (200 OK)**:
```json
[
  { "id": "veggies", "name": "Fresh Vegetables", "icon": "Utensils", "color": "#4ADE80" },
  { "id": "dairy", "name": "Dairy & Milk", "icon": "ShoppingBag", "color": "#60A5FA" }
]
```

### Get All Products
* **Endpoint**: `GET /api/products`
* **Security**: Public
* **Parameters**: `category` (optional), `healthy` (optional, boolean), `organic` (optional, boolean)
* **Success Response (200 OK)**:
```json
[
  {
    "id": "p1",
    "name": "Organic Fresh Bananas",
    "category": "veggies",
    "price": 69.00,
    "unit": "1 bunch of 5-6 pcs",
    "imageUrl": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120",
    "rating": 4.8,
    "reviewsCount": 240,
    "calories": 105,
    "protein": 1.3,
    "isOrganic": true,
    "isHealthy": true,
    "ecoScore": "A",
    "carbonEmission": 0.15,
    "inventory": 45,
    "deliveryTimeMins": 9
  }
]
```

---

## 4. Search & Filtering

### Search Products
* **Endpoint**: `GET /api/search`
* **Security**: Public
* **Parameters**: `q` (query search string), `mood` (optional filter: 'Gym', 'Lazy', 'Festival', 'Party')
* **Success Response (200 OK)**:
```json
{
  "query": "spinach",
  "moodApplied": "Gym",
  "results": [
    {
      "id": "p4",
      "name": "Fresh Spinach Palak",
      "price": 25.00,
      "isHealthy": true,
      "protein": 2.9,
      "deliveryTimeMins": 8
    }
  ]
}
```

---

## 5. Shopping Cart & Wishlist

### Fetch Cart
* **Endpoint**: `GET /api/cart`
* **Security**: Protected
* **Success Response (200 OK)**:
```json
{
  "userId": "6c8cf8bf-8b27-4645-8f65-276602324976",
  "items": [
    {
      "productId": "p1",
      "name": "Organic Fresh Bananas",
      "price": 69.00,
      "quantity": 2,
      "addedBy": "Arav"
    }
  ],
  "subtotal": 138.00
}
```

### Sync Cart Items (Bulk or Incremental)
* **Endpoint**: `POST /api/cart/sync`
* **Security**: Protected
* **Request Payload**:
```json
{
  "items": [
    { "productId": "p1", "quantity": 3 },
    { "productId": "p6", "quantity": 1 }
  ]
}
```
* **Success Response (200 OK)**:
```json
{ "status": "synced", "itemsCount": 2 }
```

### Fetch Wishlist
* **Endpoint**: `GET /api/wishlist`
* **Security**: Protected
* **Success Response (200 OK)**:
```json
["p1", "p12"]
```

### Toggle Wishlist Item
* **Endpoint**: `POST /api/wishlist/toggle`
* **Security**: Protected
* **Request Payload**:
```json
{ "productId": "p1" }
```
* **Success Response (200 OK)**:
```json
{ "productId": "p1", "isFavorited": true }
```

---

## 6. Checkout, Coupons, & Payments

### Validate Coupon Code
* **Endpoint**: `POST /api/coupons/validate`
* **Security**: Protected
* **Request Payload**:
```json
{
  "code": "FLASH50",
  "orderValue": 450.00
}
```
* **Success Response (200 OK)**:
```json
{
  "isValid": true,
  "code": "FLASH50",
  "discountAmount": 50.00,
  "newTotal": 400.00
}
```

### Place Order
* **Endpoint**: `POST /api/orders`
* **Security**: Protected
* **Request Payload**:
```json
{
  "items": [
    { "productId": "p1", "quantity": 2, "addedBy": "Arav" }
  ],
  "addressId": "ad012891-b0e2-45e3-99ab-62738fa22109",
  "paymentMethod": "Shared Wallet (Family)",
  "couponCode": "FLASH50"
}
```
* **Success Response (201 Created)**:
```json
{
  "status": "placed",
  "orderId": "FC-99AF2C1",
  "totalAmount": 93.00,
  "walletBalanceRemaining": 1107.00,
  "estimatedDeliveryTime": "9 Mins"
}
```

### Get Order Details
* **Endpoint**: `GET /api/orders/:orderId`
* **Security**: Protected
* **Success Response (200 OK)**:
```json
{
  "id": "FC-99AF2C1",
  "status": "placed",
  "subtotal": 138.00,
  "deliveryFee": 0.00,
  "carbonOffsetFee": 5.00,
  "discount": 50.00,
  "total": 93.00,
  "estimatedDeliveryTime": "9 Mins",
  "createdAt": "14:10:22",
  "items": [
    { "productId": "p1", "name": "Organic Fresh Bananas", "price": 69.00, "quantity": 2 }
  ]
}
```

---

## 7. Delivery & Real-time Tracking

### Get Delivery Status & Rider Location
* **Endpoint**: `GET /api/deliveries/:orderId/track`
* **Security**: Protected
* **Success Response (200 OK)**:
```json
{
  "orderId": "FC-99AF2C1",
  "status": "assigned",
  "rider": {
    "name": "Suresh Kumar",
    "phone": "+91 98765 43210",
    "avatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120",
    "latitude": 12.9279,
    "longitude": 77.6250,
    "bearing": 45,
    "rating": 4.95
  }
}
```

---

## 8. Push Notifications (FCM)

### Register FCM Push Token
* **Endpoint**: `POST /api/notifications/register-token`
* **Security**: Protected
* **Request Payload**:
```json
{
  "token": "fcm_push_token_999a221fbc...",
  "deviceType": "android"
}
```
* **Success Response (200 OK)**:
```json
{ "status": "token_registered" }
```

---

## 9. AI Smart Engines (Gemini)

### AI Shopping Assistant
* **Endpoint**: `POST /api/gemini/assistant`
* **Security**: Protected
* **Request Payload**: Same as current setup (takes `prompt` and optional `currentCart`)
* **Success Response (200 OK)**: Same as current schema (returns `explanation`, `items`, and `totalPrice`)

### Smart Meal Planner
* **Endpoint**: `POST /api/gemini/meal-generator`
* **Security**: Protected
* **Request Payload**: Same as current setup (takes `diet`, `cuisine`, `calories`, `budget`)
* **Success Response (200 OK)**: Returns mapped meals (breakfast, lunch, dinner) and ingredients linked to catalog products.

### Recipe Builder
* **Endpoint**: `POST /api/gemini/recipe-helper`
* **Security**: Protected
* **Request Payload**: Takes `recipeName`
* **Success Response (200 OK)**: Returns recipe steps, prep/cook time, and corresponding available catalog products to buy.

### Pantry Scanner Camera
* **Endpoint**: `POST /api/gemini/pantry-scanner`
* **Security**: Protected
* **Request Payload**: Takes `imageBase64` or `imagePresetIndex`
* **Success Response (200 OK)**: Returns detected items, replenishment list, and recipes to cook.
