import React from 'react';

export default function PRDTab() {
  return (
    <div id="prd-documentation" className="p-6 text-slate-100 overflow-y-auto max-h-[85vh] space-y-8 font-sans">
      <div className="border-b border-emerald-500/20 pb-4">
        <span className="px-2 py-1 text-xs font-semibold bg-emerald-500/10 text-emerald-400 rounded-full border border-emerald-500/20">
          DELIVERABLES 1, 2, 3, 4, 5, 6, 14 & 17
        </span>
        <h2 className="text-2xl font-bold tracking-tight text-white mt-2">Product Requirements & System Architecture</h2>
        <p className="text-xs text-slate-400 mt-1">Comprehensive system outline, database tables, API signatures, security protocols, and roadmap.</p>
      </div>

      {/* Product Requirements Document */}
      <section className="space-y-4">
        <h3 className="text-lg font-semibold text-emerald-400 border-l-2 border-emerald-500 pl-2">1. Product Requirements Document (PRD)</h3>
        <div className="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-4 text-sm text-slate-300">
          <p>
            <strong>FlashCart AI</strong> is a next-generation quick-commerce platform that goes beyond rapid delivery to incorporate deep personalization, sustainability metrics, AI budget planning, and interactive cooking logic.
          </p>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-slate-950/40 p-4 rounded-lg border border-slate-800">
              <h4 className="font-semibold text-white mb-2">User Personas</h4>
              <ul className="list-disc pl-4 space-y-2 text-xs">
                <li><strong>Arav (28, Fit Pro):</strong> Uses AI Health Mode to auto-sync grocery lists with his calorie goals. Highly sensitive to organic labeling.</li>
                <li><strong>Nisha (34, Mother of 2):</strong> Operates Shared Wallet & Family Shopping Mode to let children add snacks with limits while managing monthly pantry replenishments.</li>
              </ul>
            </div>
            <div className="bg-slate-950/40 p-4 rounded-lg border border-slate-800">
              <h4 className="font-semibold text-white mb-2">Customer Journey</h4>
              <ol className="list-decimal pl-4 space-y-2 text-xs">
                <li>User expresses dynamic intent ("breakfast for 5 people under ₹800").</li>
                <li>AI maps items directly from the hyper-local store stock.</li>
                <li>Order checked out with group split payment or family shared allowance.</li>
                <li>Store dispatches item; Rider tracks route in 120fps with a live video packing feed.</li>
              </ol>
            </div>
          </div>
        </div>
      </section>

      {/* Database Schema */}
      <section className="space-y-4">
        <h3 className="text-lg font-semibold text-emerald-400 border-l-2 border-emerald-500 pl-2">2. Database Schema & ERD</h3>
        <div className="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3 text-sm text-slate-300">
          <p className="text-xs text-slate-400">Proposed Relational PostgreSQL Schema mapping relational quick commerce structures:</p>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-slate-300 border-collapse">
              <thead>
                <tr className="border-b border-slate-800 text-slate-400">
                  <th className="py-2 pr-4 font-semibold">Table</th>
                  <th className="py-2 pr-4 font-semibold">Primary Key</th>
                  <th className="py-2 pr-4 font-semibold">Columns / Relations</th>
                  <th className="py-2 font-semibold">Description</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/40">
                <tr>
                  <td className="py-2 font-mono text-emerald-400">users</td>
                  <td className="py-2 font-mono">id (UUID)</td>
                  <td className="py-2 font-mono text-slate-400">email, phone, name, family_id (FK), created_at</td>
                  <td className="py-2">User profiles and auth associations.</td>
                </tr>
                <tr>
                  <td className="py-2 font-mono text-emerald-400">products</td>
                  <td className="py-2 font-mono">id (VARCHAR)</td>
                  <td className="py-2 font-mono text-slate-400">name, category, price, calories, eco_score, stock</td>
                  <td className="py-2">Local inventory, nutritional values, environmental rating.</td>
                </tr>
                <tr>
                  <td className="py-2 font-mono text-emerald-400">family_carts</td>
                  <td className="py-2 font-mono">id (UUID)</td>
                  <td className="py-2 font-mono text-slate-400">member_id (FK), product_id (FK), quantity, added_by</td>
                  <td className="py-2">Real-time collaborative shopping cart state.</td>
                </tr>
                <tr>
                  <td className="py-2 font-mono text-emerald-400">orders</td>
                  <td className="py-2 font-mono">id (UUID)</td>
                  <td className="py-2 font-mono text-slate-400">user_id (FK), store_id (FK), total, status, tracking_step</td>
                  <td className="py-2">Master transaction records and shipment states.</td>
                </tr>
                <tr>
                  <td className="py-2 font-mono text-emerald-400">riders</td>
                  <td className="py-2 font-mono">id (UUID)</td>
                  <td className="py-2 font-mono text-slate-400">name, phone, lat, lng, bearing, status, rating</td>
                  <td className="py-2">Active delivery riders tracking GPS signals.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* Backend Architecture */}
      <section className="space-y-4">
        <h3 className="text-lg font-semibold text-emerald-400 border-l-2 border-emerald-500 pl-2">3. Scalable Backend Architecture (10M+ Users)</h3>
        <div className="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-4 text-sm text-slate-300">
          <p>
            FlashCart AI utilizes a microservice architecture built for maximum horizontal scalability:
          </p>
          <div className="grid md:grid-cols-3 gap-4 text-xs">
            <div className="bg-slate-950/40 p-3 rounded border border-slate-800">
              <h5 className="font-semibold text-white mb-1">Caching Layer (Redis)</h5>
              <p className="text-slate-400">Caches geo-spatial rider logs (Redis Geospatial Index) and hyper-local inventory states to maintain latency under 50ms.</p>
            </div>
            <div className="bg-slate-950/40 p-3 rounded border border-slate-800">
              <h5 className="font-semibold text-white mb-1">Messaging (RabbitMQ/Kafka)</h5>
              <p className="text-slate-400">Decouples order placement from warehouse inventory updates and dispatch signals to survive extreme spikes like Diwali.</p>
            </div>
            <div className="bg-slate-950/40 p-3 rounded border border-slate-800">
              <h5 className="font-semibold text-white mb-1">Search & AI Matching</h5>
              <p className="text-slate-400">ElasticSearch maps misspelled user search prompts. Gemini API processes meal optimization maps dynamically.</p>
            </div>
          </div>
        </div>
      </section>

      {/* API specifications */}
      <section className="space-y-4">
        <h3 className="text-lg font-semibold text-emerald-400 border-l-2 border-emerald-500 pl-2">4. REST & GraphQL Specifications</h3>
        <div className="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-4 text-xs text-slate-300 font-mono">
          <div>
            <h5 className="font-semibold text-emerald-400 mb-1">POST /api/gemini/assistant</h5>
            <p className="text-slate-400 text-[11px] mb-2">Request Body:</p>
            <pre className="bg-slate-950/50 p-2 rounded border border-slate-800 text-[10px] overflow-x-auto text-emerald-300">
{`{
  "prompt": "I want a high-protein breakfast for 3 under ₹500",
  "currentCart": []
}`}
            </pre>
            <p className="text-slate-400 text-[11px] my-2">Response Body:</p>
            <pre className="bg-slate-950/50 p-2 rounded border border-slate-800 text-[10px] overflow-x-auto text-emerald-300">
{`{
  "explanation": "Mapped 12 eggs, milk and 2 whole wheat bread packets.",
  "items": [
    { "productId": "p6", "quantity": 2 },
    { "productId": "p9", "quantity": 2 }
  ],
  "totalPrice": 280
}`}
            </pre>
          </div>

          <div className="border-t border-slate-800 pt-3">
            <h5 className="font-semibold text-emerald-400 mb-1">GraphQL Query: GetStoreInventory</h5>
            <pre className="bg-slate-950/50 p-2 rounded border border-slate-800 text-[10px] overflow-x-auto text-purple-300">
{`query GetNearbyStoreInventory($storeId: ID!, $lat: Float!, $lng: Float!) {
  store(id: $storeId) {
    name
    distance(from: { lat: $lat, lng: $lng })
    products(inStock: true) {
      id
      name
      price
      inventory
    }
  }
}`}
            </pre>
          </div>
        </div>
      </section>

      {/* Phased Roadmap */}
      <section className="space-y-4">
        <h3 className="text-lg font-semibold text-emerald-400 border-l-2 border-emerald-500 pl-2">5. Phased Roadmap from MVP to 10M+ Enterprise</h3>
        <div className="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3 text-sm text-slate-300">
          <div className="space-y-3 text-xs">
            <div className="flex gap-2">
              <span className="font-bold text-emerald-400">Phase 1 (Months 1-3):</span>
              <p>Launch localized customer quick-commerce apps, real-time map sync, and Gemini-based shopping assistant (MVP).</p>
            </div>
            <div className="flex gap-2">
              <span className="font-bold text-emerald-400">Phase 2 (Months 4-6):</span>
              <p>Deploy multi-user Family Shopping Mode, automatic recurring pantry replenishments, and OCR-based kitchen scans.</p>
            </div>
            <div className="flex gap-2">
              <span className="font-bold text-emerald-400">Phase 3 (Months 7-12):</span>
              <p>Incorporate predictive replenishment pipelines, custom carbon score offsetting, and autonomous drone delivery handshakes.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
