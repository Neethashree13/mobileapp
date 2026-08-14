# FlashCart AI - API Specifications

To ensure absolute clarity, we maintain full OpenAPI-compliant specifications for the complete FlashCart backend in the dedicated documentation file.

Please refer directly to the comprehensive document:
👉 **[API REST Specifications & Contracts](./API_DOCUMENTATION.md)**

## Summary of Core API Modules

1. **Authentication Services**: `POST /api/auth/sync` for synchronizing Firebase Auth tokens into database profiles.
2. **User Profiles**: `GET /api/users/profile` and `GET /api/users/addresses` for personal lists.
3. **Product Catalog**: `GET /api/products` and `GET /api/categories` for querying grocery and wellness segments.
4. **Smart AI Services (Gemini)**:
   - `POST /api/gemini/assistant` (Shopping List conversational chat agent)
   - `POST /api/gemini/meal-generator` (Structured meal planning)
   - `POST /api/gemini/recipe-helper` (Step-by-step recipe builder)
   - `POST /api/gemini/pantry-scanner` (Camera-based pantry item detection)
5. **Real-time Delivery**: `/api/deliveries/:orderId/track` REST check accompanied by full **WebSockets (Socket.IO)** coordinate stream channel: `rider_location_update`.
