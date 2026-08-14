import React, { useState, useEffect } from 'react';
import { 
  TrendingUp, AlertTriangle, Users, Package, ShoppingBag, 
  Map, DollarSign, RefreshCw, Send, Check, Activity, BarChart2
} from 'lucide-react';

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  unit: string;
  image: string;
  rating: number;
  inventory: number;
  carbonEmission: number;
  ecoScore: string;
}

export default function App() {
  const [products, setProducts] = useState<Product[]>([]);
  const [activeTab, setActiveTab] = useState<'operations' | 'pricing'>('operations');
  const [loading, setLoading] = useState(true);
  const [replenishSearch, setReplenishSearch] = useState('');
  const [priceAdjustmentId, setPriceAdjustmentId] = useState<string>('');
  const [customPrice, setCustomPrice] = useState<number>(0);
  
  const [complaints, setComplaints] = useState([
    { id: '1', customer: 'Aravind K.', orderId: '#FC-8491A', issue: 'Missing bananas from breakfast pack', status: 'Pending' },
    { id: '2', customer: 'Nisha Sharma', orderId: '#FC-9012C', issue: 'Sourdough bread slightly crushed', status: 'Resolved' },
    { id: '3', customer: 'Rahul Roy', orderId: '#FC-7391B', issue: 'OTP didn\'t trigger for 3 minutes', status: 'Pending' }
  ]);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const res = await fetch('/api/products');
      if (res.ok) {
        const data = await res.json();
        setProducts(data);
        if (data.length > 0) {
          setPriceAdjustmentId(data[0].id);
          setCustomPrice(data[0].price);
        }
      }
    } catch (e) {
      console.error('Error fetching catalog in admin dashboard:', e);
    } finally {
      setLoading(false);
    }
  };

  const resolveComplaint = (id: string) => {
    setComplaints(prev => prev.map(c => c.id === id ? { ...c, status: 'Resolved' } : c));
  };

  const handleRestock = async (id: string) => {
    try {
      const prod = products.find(p => p.id === id);
      if (!prod) return;
      const nextInventory = prod.inventory + 50;
      
      const res = await fetch('/api/products/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id, inventory: nextInventory })
      });
      if (res.ok) {
        setProducts(prev => prev.map(p => p.id === id ? { ...p, inventory: nextInventory } : p));
      }
    } catch (e) {
      console.error('Error restock product:', e);
    }
  };

  const handleAdjustPrice = async () => {
    if (!priceAdjustmentId) return;
    try {
      const res = await fetch('/api/products/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: priceAdjustmentId, price: customPrice })
      });
      if (res.ok) {
        setProducts(prev => prev.map(p => p.id === priceAdjustmentId ? { ...p, price: customPrice } : p));
        alert('Dynamic price adjusted successfully on public API catalog!');
      }
    } catch (e) {
      console.error('Error pricing update:', e);
    }
  };

  const selectedProduct = products.find(p => p.id === priceAdjustmentId) || products[0];

  return (
    <div className="min-h-screen bg-[#07080a] text-slate-100 flex flex-col font-sans">
      {/* Header */}
      <header className="border-b border-slate-850 bg-slate-900/60 backdrop-blur px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-tr from-purple-600 to-indigo-600 rounded-xl flex items-center justify-center shadow-lg shadow-purple-500/20">
            <Activity className="w-5 h-5 text-white animate-pulse" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-white tracking-tight">FlashCart AI Operations</h1>
            <p className="text-[11px] text-slate-400">HQ Center • Bangalore Central Division</p>
          </div>
        </div>
        
        <div className="flex gap-2 bg-slate-950 p-1 rounded-xl border border-slate-800">
          <button 
            onClick={() => setActiveTab('operations')}
            className={`px-4 py-1.5 rounded-lg text-xs font-semibold transition-all ${activeTab === 'operations' ? 'bg-purple-600 text-white' : 'text-slate-400 hover:text-white'}`}
          >
            Central Logistics
          </button>
          <button 
            onClick={() => setActiveTab('pricing')}
            className={`px-4 py-1.5 rounded-lg text-xs font-semibold transition-all ${activeTab === 'pricing' ? 'bg-purple-600 text-white' : 'text-slate-400 hover:text-white'}`}
          >
            Dynamic Pricing
          </button>
        </div>
      </header>

      {/* Main Body */}
      <main className="flex-1 p-6 max-w-7xl w-full mx-auto space-y-6">
        
        {loading ? (
          <div className="h-60 flex items-center justify-center flex-col gap-2">
            <RefreshCw className="w-8 h-8 text-purple-500 animate-spin" />
            <p className="text-xs text-slate-400">Loading catalog pipeline from backend PostgreSQL database...</p>
          </div>
        ) : activeTab === 'operations' ? (
          <div className="space-y-6">
            
            {/* Core KPI cards */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="bg-slate-900/40 border border-slate-850 p-4 rounded-2xl">
                <div className="flex justify-between items-start">
                  <span className="text-xs text-slate-400 block font-medium">Daily Revenue</span>
                  <div className="p-1.5 bg-emerald-500/10 text-emerald-400 rounded-lg"><DollarSign className="w-4 h-4" /></div>
                </div>
                <span className="text-2xl font-bold text-white block mt-2">₹42,850</span>
                <span className="text-[10px] text-emerald-400 block mt-1">↑ 18.2% vs yesterday</span>
              </div>

              <div className="bg-slate-900/40 border border-slate-850 p-4 rounded-2xl">
                <div className="flex justify-between items-start">
                  <span className="text-xs text-slate-400 block font-medium">Active Fleet</span>
                  <div className="p-1.5 bg-blue-500/10 text-blue-400 rounded-lg"><Users className="w-4 h-4" /></div>
                </div>
                <span className="text-2xl font-bold text-white block mt-2">45 / 50</span>
                <span className="text-[10px] text-blue-400 block mt-1">90% Rider utilization</span>
              </div>

              <div className="bg-slate-900/40 border border-slate-850 p-4 rounded-2xl">
                <div className="flex justify-between items-start">
                  <span className="text-xs text-slate-400 block font-medium">Delivery Speed</span>
                  <div className="p-1.5 bg-amber-500/10 text-amber-400 rounded-lg"><TrendingUp className="w-4 h-4" /></div>
                </div>
                <span className="text-2xl font-bold text-white block mt-2">9.4 Mins</span>
                <span className="text-[10px] text-purple-400 block mt-1">Target matched successfully</span>
              </div>

              <div className="bg-slate-900/40 border border-slate-850 p-4 rounded-2xl">
                <div className="flex justify-between items-start">
                  <span className="text-xs text-slate-400 block font-medium">AI Conversions</span>
                  <div className="p-1.5 bg-purple-500/10 text-purple-400 rounded-lg"><ShoppingBag className="w-4 h-4" /></div>
                </div>
                <span className="text-2xl font-bold text-white block mt-2">74.2%</span>
                <span className="text-[10px] text-purple-400 block mt-1">Generative cart-builder conversions</span>
              </div>
            </div>

            {/* Live Chart & Heatmaps */}
            <div className="bg-slate-900/40 border border-slate-850 p-5 rounded-2xl space-y-4">
              <div className="flex justify-between items-center">
                <div className="flex items-center gap-1.5">
                  <BarChart2 className="w-5 h-5 text-purple-500" />
                  <h3 className="text-sm font-bold text-white">Live Demand & Predictive Logistics Forecasting</h3>
                </div>
                <span className="text-[10px] text-slate-400 font-mono">Hub ID: #BLR-DARK-KOR</span>
              </div>
              
              <div className="h-32 flex items-end gap-1.5 border-b border-l border-slate-800 pl-2 pb-2">
                {[40, 55, 75, 95, 120, 110, 85, 95, 130, 140, 90, 60].map((val, idx) => (
                  <div key={idx} className="flex-1 flex flex-col justify-end items-center h-full group relative">
                    <div className="absolute bottom-full mb-1 opacity-0 group-hover:opacity-100 bg-slate-950 border border-slate-850 text-[9px] px-2 py-0.5 rounded text-purple-400 z-10 transition-all pointer-events-none whitespace-nowrap">
                      Hour {idx + 8}: {val} orders
                    </div>
                    <div 
                      style={{ height: `${val}%` }} 
                      className="w-full bg-gradient-to-t from-purple-600 to-indigo-500 rounded-t hover:from-emerald-500 hover:to-emerald-400 transition-all duration-300 cursor-pointer"
                    ></div>
                    <span className="text-[8px] text-slate-500 mt-2 font-mono">{idx + 8}h</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Heatmaps and Dispute Panel */}
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-slate-900/40 border border-slate-850 p-5 rounded-2xl">
                <h3 className="text-sm font-bold text-white mb-4 flex items-center gap-2">
                  <Map className="w-4 h-4 text-emerald-400" />
                  Live Delivery Zone Status
                </h3>
                <div className="space-y-3 text-xs">
                  <div className="flex justify-between items-center border-b border-slate-850 pb-2.5">
                    <span className="text-slate-300">Sector-4 Blocks A/B (Fitness Hub)</span>
                    <span className="px-2 py-0.5 bg-rose-500/15 text-rose-400 font-bold rounded text-[9px] tracking-wide">CRITICAL PEAK</span>
                  </div>
                  <div className="flex justify-between items-center border-b border-slate-850 pb-2.5">
                    <span className="text-slate-300">Sony Signal Crossing (Transit Route)</span>
                    <span className="px-2 py-0.5 bg-amber-500/15 text-amber-400 font-bold rounded text-[9px] tracking-wide">HIGH TRAFFIC</span>
                  </div>
                  <div className="flex justify-between items-center border-b border-slate-850 pb-2.5">
                    <span className="text-slate-300">Forum Junction Circle (Depot East)</span>
                    <span className="px-2 py-0.5 bg-emerald-500/15 text-emerald-400 font-bold rounded text-[9px] tracking-wide">LOW TRAFFIC</span>
                  </div>
                </div>
              </div>

              <div className="bg-slate-900/40 border border-slate-850 p-5 rounded-2xl">
                <h3 className="text-sm font-bold text-white mb-4 flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 text-rose-400" />
                  Dispute Resolution Panel
                </h3>
                <div className="space-y-2.5">
                  {complaints.map(c => (
                    <div key={c.id} className="bg-slate-950 border border-slate-850 rounded-xl p-3 flex items-center justify-between gap-3 text-xs">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-bold text-white">{c.customer}</span>
                          <span className="text-[10px] text-slate-500 font-mono">{c.orderId}</span>
                        </div>
                        <p className="text-slate-400 text-[10px] mt-0.5">{c.issue}</p>
                      </div>
                      {c.status === 'Pending' ? (
                        <button 
                          onClick={() => resolveComplaint(c.id)}
                          className="px-2.5 py-1 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-lg text-[10px] transition-colors whitespace-nowrap"
                        >
                          RESOLVE
                        </button>
                      ) : (
                        <span className="text-emerald-400 font-bold text-[10px] flex items-center gap-1">
                          <Check className="w-3 h-3" /> RESOLVED
                        </span>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            </div>

          </div>
        ) : (
          <div className="grid md:grid-cols-2 gap-6">
            
            {/* Stock Manager */}
            <div className="bg-slate-900/40 border border-slate-850 p-5 rounded-2xl space-y-4">
              <div className="flex justify-between items-center">
                <h3 className="text-sm font-bold text-white flex items-center gap-2">
                  <Package className="w-4 h-4 text-purple-500" />
                  Dark Store Stock Replenishment
                </h3>
                <input 
                  type="text" 
                  placeholder="Filter stock..."
                  value={replenishSearch}
                  onChange={(e) => setReplenishSearch(e.target.value)}
                  className="bg-slate-950 border border-slate-850 rounded-xl px-3 py-1 text-xs focus:outline-none"
                />
              </div>

              <div className="space-y-2 max-h-96 overflow-y-auto pr-1">
                {products
                  .filter(p => p.name.toLowerCase().includes(replenishSearch.toLowerCase()))
                  .map(p => (
                    <div key={p.id} className="bg-slate-950 border border-slate-850/80 p-3 rounded-xl flex justify-between items-center gap-2">
                      <div>
                        <p className="text-xs font-semibold text-slate-200">{p.name}</p>
                        <p className={`text-[10px] mt-0.5 ${p.inventory < 20 ? 'text-rose-400 font-semibold' : 'text-slate-500'}`}>
                          Inventory count: {p.inventory} {p.inventory < 20 && '• REORDER REQUIRED'}
                        </p>
                      </div>
                      <button 
                        onClick={() => handleRestock(p.id)}
                        className="px-3 py-1 bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-extrabold rounded-lg text-[10px] transition-colors"
                      >
                        RESTOCK +50
                      </button>
                    </div>
                  ))}
              </div>
            </div>

            {/* Pricing Adjuster */}
            <div className="bg-slate-900/40 border border-slate-850 p-5 rounded-2xl flex flex-col justify-between">
              <div className="space-y-4">
                <h3 className="text-sm font-bold text-white flex items-center gap-2">
                  <TrendingUp className="w-4 h-4 text-purple-500" />
                  AI-Powered Dynamic Pricing Adjustments
                </h3>

                <div className="space-y-3 text-xs">
                  <div>
                    <label className="block text-slate-400 mb-1">Select Catalog Target:</label>
                    <select 
                      value={priceAdjustmentId}
                      onChange={(e) => {
                        setPriceAdjustmentId(e.target.value);
                        const p = products.find(prod => prod.id === e.target.value);
                        if (p) setCustomPrice(p.price);
                      }}
                      className="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white focus:outline-none"
                    >
                      {products.map(p => (
                        <option key={p.id} value={p.id}>{p.name} (Current: ₹{p.price})</option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-slate-400 mb-1">Live Relational Price (Paise/INR):</label>
                    <div className="flex gap-2">
                      <input 
                        type="number"
                        value={customPrice}
                        onChange={(e) => setCustomPrice(Number(e.target.value))}
                        className="bg-slate-950 border border-slate-800 rounded-xl p-2 text-white w-28 focus:outline-none"
                      />
                      <button 
                        onClick={handleAdjustPrice}
                        className="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl transition-all"
                      >
                        Commit Live Bids
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {selectedProduct && (
                <div className="bg-slate-950 border border-purple-500/20 rounded-xl p-4 mt-6">
                  <span className="text-[9px] font-extrabold text-purple-400 tracking-wider block">PREDICTIVE RECOMMENDATION</span>
                  <p className="text-xs font-bold text-white mt-1">{selectedProduct.name}</p>
                  <p className="text-[11px] text-slate-400 mt-2">
                    {selectedProduct.id === 'p1' || selectedProduct.id === 'p6' ? (
                      <span className="text-rose-400">⚡ Dynamic warning: High local demand. Push price to protect dark depot fulfillment rates.</span>
                    ) : (
                      <span className="text-emerald-400">✓ Market supply is stable. Normal price structures recommended to preserve customer margins.</span>
                    )}
                  </p>
                </div>
              )}
            </div>

          </div>
        )}

      </main>
    </div>
  );
}
