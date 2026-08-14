import React, { useState, useEffect } from 'react';
import { Product, CartItem, Order, DriverState } from './types';
import { PRODUCTS } from './data/products';
import CustomerApp from './components/CustomerApp';
import RiderApp from './components/RiderApp';
import AdminPanel from './components/AdminPanel';
import PRDTab from './components/PRDTab';
import { 
  Zap, Database, Cpu, Plus, RotateCcw, HelpCircle, 
  Settings, ShoppingBag, ShieldCheck, Play
} from 'lucide-react';

export default function App() {
  // Shared States across views
  const [products, setProducts] = useState<Product[]>(PRODUCTS);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [activeOrder, setActiveOrder] = useState<Order | null>(null);
  
  // Rider Initial State (aligned with dark store GPS coords)
  const [riderState, setRiderState] = useState<DriverState>({
    id: 'r1',
    name: 'Suresh Kumar',
    phone: '+91 98765 43210',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&auto=format&fit=crop&q=60',
    lat: 12.9279,
    lng: 77.6250,
    bearing: 0,
    status: 'assigned',
    rating: 4.95
  });

  const [currentProfile, setCurrentProfile] = useState<'arav' | 'nisha'>('arav');
  const [collaborativeCartActive, setCollaborativeCartActive] = useState<boolean>(true);
  const [walletBalance, setWalletBalance] = useState<number>(1200);
  const [activeScreen, setActiveScreen] = useState<string>('home');

  // Backstage Control Panel Active Tab
  const [backstageTab, setBackstageTab] = useState<'prd' | 'admin' | 'store' | 'rider'>('prd');

  // Connection/AI Indicator status
  const [aiStatus, setAiStatus] = useState<'Live' | 'Simulated'>('Simulated');

  // 1. Fetch initial states on mount from backend DB
  useEffect(() => {
    const fetchInitialStates = async () => {
      try {
        const prodRes = await fetch('/api/products');
        if (prodRes.ok) {
          const prodData = await prodRes.json();
          setProducts(prodData);
        }

        const cartRes = await fetch('/api/cart');
        if (cartRes.ok) {
          const cartData = await cartRes.json();
          setCart(Array.isArray(cartData) ? cartData : (cartData.items || []));
        }

        const walletRes = await fetch('/api/wallet');
        if (walletRes.ok) {
          const walletData = await walletRes.json();
          setWalletBalance(walletData.balance);
        }

        const activeOrderRes = await fetch('/api/orders/active');
        if (activeOrderRes.ok) {
          const orderData = await activeOrderRes.json();
          setActiveOrder(orderData);
          if (orderData && orderData.status !== 'delivered') {
            setActiveScreen('tracking');
          }
        }

        const trackRes = await fetch('/api/deliveries/track');
        if (trackRes.ok) {
          const trackData = await trackRes.json();
          setRiderState(trackData);
        }
      } catch (err) {
        console.error("Error fetching initial DB states:", err);
      }
    };
    fetchInitialStates();
  }, []);

  // 2. Synchronize cart state to backend database on modification
  useEffect(() => {
    const syncCart = async () => {
      try {
        await fetch('/api/cart/sync', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ cart })
        });
      } catch (e) {
        console.error("Error syncing cart to server:", e);
      }
    };
    // Sync only when we have initialized products catalog
    if (products.length > 0) {
      syncCart();
    }
  }, [cart, products.length]);

  const handleUpdateRiderStatus = async (newStatus: DriverState['status']) => {
    try {
      const res = await fetch('/api/deliveries/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus })
      });
      if (res.ok) {
        const updatedRider = await res.json();
        setRiderState(updatedRider);

        // Refresh active order to reflect the new tracking step
        const orderRes = await fetch('/api/orders/active');
        if (orderRes.ok) {
          const orderData = await orderRes.json();
          setActiveOrder(orderData);
        }
      }
    } catch (e) {
      console.error("Error updating rider status:", e);
    }
  };

  const handleRefillWallet = async () => {
    try {
      const res = await fetch('/api/wallet/refill', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: 1000 })
      });
      if (res.ok) {
        const walletData = await res.json();
        setWalletBalance(walletData.balance);
      }
    } catch (e) {
      console.error("Error refilling wallet:", e);
    }
  };

  const handleResetSandbox = async () => {
    try {
      const res = await fetch('/api/sandbox/reset', { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setProducts(PRODUCTS);
        setCart([]);
        setActiveOrder(null);
        setRiderState({
          id: 'r1',
          name: 'Suresh Kumar',
          phone: '+91 98765 43210',
          avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&auto=format&fit=crop&q=60',
          lat: 12.9279,
          lng: 77.6250,
          bearing: 0,
          status: 'assigned',
          rating: 4.95
        });
        setWalletBalance(data.balance);
        setActiveScreen('home');
      }
    } catch (e) {
      console.error("Error resetting sandbox:", e);
    }
  };

  useEffect(() => {
    // Detect if we have real server-side Gemini active
    const checkAI = async () => {
      try {
        const testRes = await fetch('/api/gemini/assistant', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ prompt: 'ping' })
        });
        if (testRes.ok) {
          setAiStatus('Live');
        }
      } catch (e) {
        setAiStatus('Simulated');
      }
    };
    checkAI();
  }, []);

  return (
    <div className="min-h-screen bg-[#07080a] text-slate-100 flex flex-col font-sans select-none antialiased selection:bg-emerald-500 selection:text-slate-950">
      
      {/* Top Professional Control Hub */}
      <header className="bg-[#0b0c0f] border-b border-slate-900 px-6 py-4 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 z-10 shrink-0">
        <div>
          <div className="flex items-center gap-2">
            <div className="bg-emerald-500/10 p-1.5 rounded-lg border border-emerald-500/20">
              <Zap className="w-5 h-5 text-emerald-400" />
            </div>
            <h1 className="text-xl font-bold tracking-tight text-white flex items-center gap-2 font-sans">
              FlashCart AI <span className="text-[10px] font-mono tracking-widest uppercase bg-emerald-500/20 text-emerald-400 px-2 py-0.5 rounded border border-emerald-500/10">v1.0.0</span>
            </h1>
          </div>
          <p className="text-xs text-slate-400 mt-1">
            Next-Gen Quick Commerce Multi-Role Sandbox • Inspired by Blinkit & Zepto
          </p>
        </div>

        {/* Diagnostic Telemetries & Controls */}
        <div className="flex flex-wrap items-center gap-3">
          {/* Connection Status badge */}
          <div className="flex items-center gap-1.5 bg-slate-900 border border-slate-800 rounded-lg px-3 py-1.5 text-xs">
            <Cpu className="w-4 h-4 text-purple-400" />
            <span className="text-slate-400">Gemini:</span>
            <span className={`font-semibold ${aiStatus === 'Live' ? 'text-emerald-400' : 'text-amber-400'}`}>
              {aiStatus === 'Live' ? '● Live SDK connected' : '○ Local Simulation Fallback'}
            </span>
          </div>

          <button 
            onClick={handleRefillWallet}
            className="px-3 py-1.5 bg-slate-900 hover:bg-slate-800 text-white rounded-lg border border-slate-800 hover:border-slate-700 text-xs font-semibold flex items-center gap-1.5 transition-all active:scale-95"
          >
            <Plus className="w-3.5 h-3.5 text-emerald-400" /> Add ₹1000 Wallet Funds
          </button>

          <button 
            onClick={handleResetSandbox}
            className="px-3 py-1.5 bg-slate-900 hover:bg-slate-800 text-slate-300 rounded-lg border border-slate-800 hover:border-slate-700 text-xs font-semibold flex items-center gap-1.5 transition-all active:scale-95"
            title="Reset sandbox simulation states"
          >
            <RotateCcw className="w-3.5 h-3.5 text-rose-400" /> Reset All States
          </button>
        </div>
      </header>

      {/* Main Sandbox Split Panel */}
      <main className="flex-1 w-full max-w-7xl mx-auto px-4 py-6 grid lg:grid-cols-12 gap-8 items-start min-h-0">
        
        {/* LEFT COLUMN: Customer iPhone Simulator (4 cols) */}
        <div className="lg:col-span-5 flex justify-center sticky top-6 z-10">
          <CustomerApp 
            products={products}
            cart={cart}
            setCart={setCart}
            activeOrder={activeOrder}
            setActiveOrder={setActiveOrder}
            riderState={riderState}
            setRiderState={setRiderState}
            currentProfile={currentProfile}
            setCurrentProfile={setCurrentProfile}
            collaborativeCartActive={collaborativeCartActive}
            setCollaborativeCartActive={setCollaborativeCartActive}
            walletBalance={walletBalance}
            setWalletBalance={setWalletBalance}
            activeScreen={activeScreen}
            setActiveScreen={setActiveScreen}
          />
        </div>

        {/* RIGHT COLUMN: Operational Backstage Console (7 cols) */}
        <div className="lg:col-span-7 flex flex-col h-[780px] bg-[#090a0d] border border-slate-900 rounded-[32px] overflow-hidden shadow-xl">
          
          {/* Backstage Tabs Header */}
          <div className="bg-[#0f1115] border-b border-slate-900 px-6 py-4 flex justify-between items-center shrink-0">
            <div className="flex items-center gap-1">
              <Database className="w-4 h-4 text-emerald-400" />
              <h3 className="text-xs font-bold text-slate-300 uppercase tracking-wider">Operational Backstage Console</h3>
            </div>

            {/* Simulated Live Order Alert */}
            {activeOrder && (
              <span className="px-2 py-0.5 bg-purple-500/10 text-purple-400 text-[10px] font-bold rounded animate-pulse">
                Active Order Picked Up By Rider
              </span>
            )}
          </div>

          {/* Navigation Tab Bar */}
          <div className="bg-[#0c0d10] border-b border-slate-900/60 flex text-xs shrink-0">
            {[
              { id: 'prd', label: '📝 PRD & TECH SPECS' },
              { id: 'admin', label: '📊 OPERATIONAL ADMIN' },
              { id: 'store', label: '🏪 MERCHANT STORE' },
              { id: 'rider', label: '🛵 DELIVERY PARTNER' }
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setBackstageTab(tab.id as any)}
                className={`flex-1 py-3 font-semibold border-b-2 text-center transition-all ${
                  backstageTab === tab.id 
                    ? 'border-emerald-500 text-emerald-400 bg-[#0f1115]' 
                    : 'border-transparent text-slate-500 hover:text-slate-300'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* Active Tab Panel Content */}
          <div className="flex-1 min-h-0 bg-[#07080a]">
            {backstageTab === 'prd' && <PRDTab />}
            {backstageTab === 'admin' && (
              <AdminPanel 
                products={products}
                setProducts={setProducts}
                activeTab="admin"
              />
            )}
            {backstageTab === 'store' && (
              <AdminPanel 
                products={products}
                setProducts={setProducts}
                activeTab="store"
              />
            )}
            {backstageTab === 'rider' && (
              <RiderApp 
                riderState={riderState}
                setRiderState={setRiderState}
                activeOrder={activeOrder}
                onUpdateStatus={handleUpdateRiderStatus}
              />
            )}
          </div>
        </div>
      </main>

      {/* Footer System Credits */}
      <footer className="bg-[#07080a] border-t border-slate-900 py-3 text-center text-[11px] text-slate-600 shrink-0 select-none">
        FlashCart AI Multi-Role Sandbox Simulator • Developed using Google GenAI SDK • Clean Architecture
      </footer>
    </div>
  );
}
