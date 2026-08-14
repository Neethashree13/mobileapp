import React, { useState } from 'react';
import { DriverState, Order } from '../types';
import { 
  Navigation, Phone, ShieldAlert, CheckCircle, 
  MapPin, DollarSign, Award, ThumbsUp, Activity, Camera, Bell
} from 'lucide-react';
import NotificationCenterModal from './NotificationCenterModal';

interface RiderAppProps {
  riderState: DriverState;
  setRiderState: React.Dispatch<React.SetStateAction<DriverState>>;
  activeOrder: Order | null;
  onUpdateStatus: (newStatus: DriverState['status']) => void;
}

export default function RiderApp({ riderState, setRiderState, activeOrder, onUpdateStatus }: RiderAppProps) {
  const [isOnline, setIsOnline] = useState(true);
  const [dailyEarnings, setDailyEarnings] = useState(1450);
  const [completedToday, setCompletedToday] = useState(12);
  const [rating, setRating] = useState(4.9);
  const [otpValue, setOtpValue] = useState('');
  const [otpError, setOtpError] = useState('');
  const [otpVerified, setOtpVerified] = useState(false);

  // Module 8 Rider Notifications State
  const [riderNotifModalOpen, setRiderNotifModalOpen] = useState(false);
  const [riderUnreadCount, setRiderUnreadCount] = useState(0);
  const [sosStatus, setSosStatus] = useState<string | null>(null);

  const handleTriggerEmergencySOS = async () => {
    try {
      setSosStatus("Sending SOS Alert...");
      const res = await fetch('/api/notifications/broadcast', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          targetRole: 'ALL',
          title: '🚨 EMERGENCY RIDER SOS ALERT',
          body: `Rider ${riderState.name} (Vehicle: ${riderState.id}) triggered emergency assistance at Koramangala Sector 3!`,
          category: 'SYSTEM',
          isEmergency: true,
          channels: ['IN_APP', 'PUSH', 'SMS']
        })
      });
      if (res.ok) {
        setSosStatus("🚨 SOS Broadcast Sent to Dispatch!");
        setTimeout(() => setSosStatus(null), 4000);
      }
    } catch (err) {
      console.error("SOS broadcast error:", err);
    }
  };

  const handleStatusProgress = () => {
    if (riderState.status === 'assigned') {
      onUpdateStatus('at_store');
    } else if (riderState.status === 'at_store') {
      onUpdateStatus('picked_up');
    } else if (riderState.status === 'picked_up') {
      onUpdateStatus('near_delivery');
    } else if (riderState.status === 'near_delivery') {
      if (otpValue === '4932') {
        onUpdateStatus('delivered');
        setDailyEarnings(prev => prev + 60);
        setCompletedToday(prev => prev + 1);
        setOtpVerified(true);
        setOtpError('');
      } else {
        setOtpError('Invalid Delivery OTP. Enter 4932 to complete.');
      }
    }
  };

  return (
    <div className="bg-[#0c0d0f] rounded-2xl border border-slate-800 text-slate-200 p-5 font-sans h-full overflow-y-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between border-b border-slate-800 pb-4">
        <div className="flex items-center gap-3">
          <div className="relative">
            <img 
              src={riderState.avatar} 
              alt={riderState.name} 
              className="w-12 h-12 rounded-full border border-emerald-500 object-cover"
            />
            <span className={`absolute bottom-0 right-0 w-3.5 h-3.5 rounded-full border-2 border-slate-900 ${isOnline ? 'bg-emerald-500' : 'bg-slate-500'}`}></span>
          </div>
          <div>
            <h3 className="font-semibold text-white text-sm">{riderState.name}</h3>
            <p className="text-xs text-slate-400">Elite Rider ID: #90412</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setRiderNotifModalOpen(true)}
            className="relative p-2 bg-slate-900 border border-slate-800 hover:border-emerald-500/50 rounded-full text-slate-300 hover:text-white transition-all active:scale-95"
            title="Rider Notifications"
          >
            <Bell className="w-4 h-4 text-emerald-400" />
            {riderUnreadCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-rose-500 text-white text-[9px] font-bold px-1 min-w-[16px] h-4 rounded-full flex items-center justify-center border border-slate-950 animate-pulse">
                {riderUnreadCount}
              </span>
            )}
          </button>

          <button 
            onClick={() => setIsOnline(!isOnline)}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold border transition-all ${
              isOnline 
                ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' 
                : 'bg-slate-800/50 text-slate-400 border-slate-700/50'
            }`}
          >
            {isOnline ? '● Go Offline' : '○ Go Online'}
          </button>
        </div>
      </div>

      {/* Metrics Dashboard */}
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-slate-900/40 border border-slate-800/60 p-3 rounded-xl text-center">
          <DollarSign className="w-4 h-4 text-emerald-400 mx-auto mb-1" />
          <p className="text-xs text-slate-400">Today Earnings</p>
          <p className="text-sm font-bold text-white mt-0.5">₹{dailyEarnings}</p>
        </div>
        <div className="bg-slate-900/40 border border-slate-800/60 p-3 rounded-xl text-center">
          <CheckCircle className="w-4 h-4 text-purple-400 mx-auto mb-1" />
          <p className="text-xs text-slate-400">Deliveries</p>
          <p className="text-sm font-bold text-white mt-0.5">{completedToday}</p>
        </div>
        <div className="bg-slate-900/40 border border-slate-800/60 p-3 rounded-xl text-center">
          <ThumbsUp className="w-4 h-4 text-amber-400 mx-auto mb-1" />
          <p className="text-xs text-slate-400">Rider Rating</p>
          <p className="text-sm font-bold text-white mt-0.5">★ {rating}</p>
        </div>
      </div>

      {/* Active Delivery Order */}
      {activeOrder ? (
        <div className="bg-slate-900/60 border border-slate-800 rounded-xl p-4 space-y-4">
          <div className="flex items-center justify-between border-b border-slate-800 pb-3">
            <div>
              <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 bg-emerald-500/10 text-emerald-400 rounded">
                ACTIVE SHIPMENT
              </span>
              <p className="text-xs text-slate-400 mt-1">Order #{activeOrder.id.substring(0, 8)}</p>
            </div>
            <div className="text-right">
              <p className="text-xs text-slate-400">Est. Payout</p>
              <p className="text-sm font-semibold text-emerald-400">₹60.00</p>
            </div>
          </div>

          {/* Location Routing Info */}
          <div className="space-y-3 text-xs">
            <div className="flex gap-3">
              <div className="flex flex-col items-center">
                <div className="w-2.5 h-2.5 rounded-full bg-purple-500"></div>
                <div className="w-0.5 h-8 bg-slate-700"></div>
                <div className="w-2.5 h-2.5 rounded-full bg-emerald-500"></div>
              </div>
              <div className="space-y-3.5">
                <div>
                  <p className="font-semibold text-slate-300">Store: FlashCart Dark Warehouse - Koramangala Sector 3</p>
                  <p className="text-[11px] text-slate-500">Pick up items in shelf A-4, C-1</p>
                </div>
                <div>
                  <p className="font-semibold text-slate-300">Deliver To: {activeOrder.deliveryAddress}</p>
                  <p className="text-[11px] text-slate-500">Leave at flat gate if unavailable</p>
                </div>
              </div>
            </div>
          </div>

          {/* Action Step Control */}
          <div className="border-t border-slate-800 pt-3 space-y-3">
            <div className="flex items-center justify-between text-xs">
              <span className="text-slate-400">Status:</span>
              <span className="font-semibold text-purple-400 uppercase tracking-wider text-[11px]">
                {riderState.status.replace('_', ' ')}
              </span>
            </div>

            {/* OTP input field if near delivery */}
            {riderState.status === 'near_delivery' && !otpVerified && (
              <div className="space-y-2">
                <label className="block text-xs text-slate-400">Enter Delivery OTP (OTP is 4932):</label>
                <input 
                  type="text"
                  maxLength={4}
                  placeholder="4-digit OTP"
                  value={otpValue}
                  onChange={(e) => setOtpValue(e.target.value)}
                  className="w-full text-center tracking-widest bg-slate-950 border border-slate-800 rounded-lg py-2 font-mono text-sm focus:border-purple-500 focus:outline-none"
                />
                {otpError && <p className="text-rose-400 text-[10px] text-center">{otpError}</p>}
              </div>
            )}

            {riderState.status !== 'delivered' ? (
              <button
                onClick={handleStatusProgress}
                className="w-full py-2.5 bg-emerald-500 hover:bg-emerald-600 active:scale-95 text-slate-950 font-bold rounded-lg text-xs flex items-center justify-center gap-1.5 transition-all"
              >
                <Navigation className="w-4 h-4" />
                {riderState.status === 'assigned' && 'Mark Arrived at Store'}
                {riderState.status === 'at_store' && 'Mark Order Picked Up'}
                {riderState.status === 'picked_up' && 'Mark Arrived at Delivery Location'}
                {riderState.status === 'near_delivery' && 'Confirm OTP & Complete Delivery'}
              </button>
            ) : (
              <div className="bg-emerald-500/10 border border-emerald-500/20 p-2.5 rounded-lg text-center text-xs text-emerald-400 font-semibold">
                ✓ Order Delivered successfully! ₹60 added to wallet.
              </div>
            )}
          </div>

          {/* Live Driver Camera Feed Mock */}
          <div className="bg-slate-950 border border-slate-800 rounded-lg p-3">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[10px] text-slate-400 flex items-center gap-1">
                <Camera className="w-3.5 h-3.5 text-emerald-500 animate-pulse" />
                RIDER LIDAR FEED (ACTIVE)
              </span>
              <span className="text-[9px] text-slate-500 font-mono">1080p • 30FPS</span>
            </div>
            <div className="relative aspect-video rounded bg-slate-900 border border-slate-800 flex items-center justify-center overflow-hidden">
              <img 
                src="https://images.unsplash.com/photo-1551829141-85030f108498?w=500&auto=format&fit=crop&q=60" 
                alt="Package Camera" 
                className="w-full h-full object-cover opacity-60"
              />
              <div className="absolute top-2 left-2 bg-slate-950/80 px-1.5 py-0.5 rounded text-[9px] text-emerald-400 font-mono">
                [TEMP: 28°C | DEPOT W-12]
              </div>
              <p className="absolute bottom-2 left-2 text-[10px] text-white bg-slate-950/70 px-2 py-0.5 rounded backdrop-blur">
                Checking payload weight... Balanced.
              </p>
            </div>
          </div>
        </div>
      ) : (
        <div className="text-center py-12 text-slate-500 text-xs">
          <Activity className="w-8 h-8 mx-auto mb-2 text-slate-600 animate-pulse" />
          <p>No active orders assigned currently.</p>
          <p className="text-[10px] mt-1 text-slate-600">Please switch to Customer view and place an order first.</p>
        </div>
      )}

      {/* Safety SOS */}
      <div className="bg-rose-950/20 border border-rose-500/20 p-3 rounded-xl flex items-center justify-between text-xs text-rose-400">
        <div className="flex items-center gap-2">
          <ShieldAlert className="w-4 h-4 animate-bounce" />
          <div>
            <p className="font-semibold text-rose-300">Rider Emergency SOS</p>
            <p className="text-[10px] text-rose-400/80">{sosStatus || "Press to broadcast emergency incident"}</p>
          </div>
        </div>
        <button 
          onClick={handleTriggerEmergencySOS}
          className="px-3 py-1 bg-rose-500/20 hover:bg-rose-500 text-rose-100 font-bold rounded-lg border border-rose-500/30 transition-colors"
        >
          TRIGGER SOS
        </button>
      </div>

      {/* Rider Notification Center Modal */}
      <NotificationCenterModal
        isOpen={riderNotifModalOpen}
        onClose={() => setRiderNotifModalOpen(false)}
        userId={riderState.id || "r1"}
        role="RIDER"
        onUnreadCountChange={setRiderUnreadCount}
      />
    </div>
  );
}
