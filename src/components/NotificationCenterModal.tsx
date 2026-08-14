import React, { useState, useEffect } from 'react';
import { 
  Bell, CheckCheck, Trash2, X, Sliders, Shield, ShoppingBag, Wallet, 
  Tag, Truck, AlertTriangle, Send, CheckCircle2, RefreshCw
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface NotificationItem {
  id: string;
  userId: string;
  role: string;
  title: string;
  body: string;
  category: string;
  channel: string;
  read: boolean;
  metadata?: any;
  createdAt: string;
}

interface NotificationPreferences {
  emailEnabled: boolean;
  smsEnabled: boolean;
  pushEnabled: boolean;
  inAppEnabled: boolean;
  categories: Record<string, boolean>;
}

interface NotificationCenterModalProps {
  isOpen: boolean;
  onClose: () => void;
  userId?: string;
  role?: string;
  onUnreadCountChange?: (count: number) => void;
}

export default function NotificationCenterModal({
  isOpen,
  onClose,
  userId = "u1",
  role = "CUSTOMER",
  onUnreadCountChange
}: NotificationCenterModalProps) {
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const [activeCategory, setActiveCategory] = useState<string>("ALL");
  const [loading, setLoading] = useState(false);
  const [showPreferences, setShowPreferences] = useState(false);
  const [preferences, setPreferences] = useState<NotificationPreferences>({
    emailEnabled: true,
    smsEnabled: true,
    pushEnabled: true,
    inAppEnabled: true,
    categories: { ORDER: true, WALLET: true, PROMO: true, SYSTEM: true, DELIVERY: true }
  });
  const [prefLoading, setPrefLoading] = useState(false);
  const [testSending, setTestSending] = useState(false);

  // Fetch notifications
  const fetchNotifications = async () => {
    try {
      setLoading(true);
      const res = await fetch(`/api/notifications?userId=${userId}&role=${role}`);
      if (res.ok) {
        const data = await res.json();
        setNotifications(Array.isArray(data) ? data : []);
        const unreadCount = data.filter((n: any) => !n.read).length;
        if (onUnreadCountChange) onUnreadCountChange(unreadCount);
      }
    } catch (err) {
      console.error("Error loading notifications:", err);
    } finally {
      setLoading(false);
    }
  };

  // Fetch preferences
  const fetchPreferences = async () => {
    try {
      const res = await fetch(`/api/notifications/preferences?userId=${userId}&role=${role}`);
      if (res.ok) {
        const data = await res.json();
        if (data && data.categories) {
          setPreferences({
            emailEnabled: Boolean(data.emailEnabled),
            smsEnabled: Boolean(data.smsEnabled),
            pushEnabled: Boolean(data.pushEnabled),
            inAppEnabled: Boolean(data.inAppEnabled),
            categories: data.categories
          });
        }
      }
    } catch (err) {
      console.error("Error loading preferences:", err);
    }
  };

  useEffect(() => {
    if (isOpen) {
      fetchNotifications();
      fetchPreferences();
    }
  }, [isOpen]);

  // Mark single as read
  const handleMarkAsRead = async (id: string) => {
    try {
      const res = await fetch(`/api/notifications/${id}/read`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId })
      });
      if (res.ok) {
        setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: true } : n));
        const newUnread = notifications.filter(n => n.id !== id && !n.read).length;
        if (onUnreadCountChange) onUnreadCountChange(newUnread);
      }
    } catch (err) {
      console.error("Error marking read:", err);
    }
  };

  // Mark all as read
  const handleMarkAllRead = async () => {
    try {
      const res = await fetch('/api/notifications/read-all', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, role })
      });
      if (res.ok) {
        setNotifications(prev => prev.map(n => ({ ...n, read: true })));
        if (onUnreadCountChange) onUnreadCountChange(0);
      }
    } catch (err) {
      console.error("Error marking all read:", err);
    }
  };

  // Delete notification
  const handleDeleteNotification = async (id: string) => {
    try {
      const res = await fetch(`/api/notifications/${id}?userId=${userId}`, {
        method: 'DELETE'
      });
      if (res.ok) {
        const filtered = notifications.filter(n => n.id !== id);
        setNotifications(filtered);
        const unreadCount = filtered.filter(n => !n.read).length;
        if (onUnreadCountChange) onUnreadCountChange(unreadCount);
      }
    } catch (err) {
      console.error("Error deleting notification:", err);
    }
  };

  // Save Preferences
  const handleSavePreferences = async () => {
    try {
      setPrefLoading(true);
      const res = await fetch('/api/notifications/preferences', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId,
          role,
          ...preferences
        })
      });
      if (res.ok) {
        setShowPreferences(false);
      }
    } catch (err) {
      console.error("Error saving preferences:", err);
    } finally {
      setPrefLoading(false);
    }
  };

  // Trigger test notification
  const handleTriggerTestNotification = async () => {
    try {
      setTestSending(true);
      const res = await fetch('/api/notifications/test', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId,
          role,
          title: "Real-Time Express Test 🚀",
          body: `Test multi-channel notification sent at ${new Date().toLocaleTimeString()}!`,
          category: "ORDER",
          channels: ["IN_APP", "PUSH", "EMAIL", "SMS"]
        })
      });
      if (res.ok) {
        await fetchNotifications();
      }
    } catch (err) {
      console.error("Error sending test notification:", err);
    } finally {
      setTestSending(false);
    }
  };

  const filteredNotifications = notifications.filter(n => {
    if (activeCategory === "ALL") return true;
    return n.category === activeCategory;
  });

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'ORDER': return <ShoppingBag className="w-4 h-4 text-emerald-400" />;
      case 'WALLET': return <Wallet className="w-4 h-4 text-emerald-400" />;
      case 'PROMO': return <Tag className="w-4 h-4 text-amber-400" />;
      case 'DELIVERY': return <Truck className="w-4 h-4 text-blue-400" />;
      case 'INVENTORY': return <AlertTriangle className="w-4 h-4 text-rose-400" />;
      default: return <Bell className="w-4 h-4 text-purple-400" />;
    }
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.95 }}
          className="bg-[#0f1117] border border-slate-800 rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl flex flex-col max-h-[85vh] text-slate-100"
        >
          {/* Header */}
          <div className="p-4 border-b border-slate-800 flex justify-between items-center bg-[#131622]">
            <div className="flex items-center gap-2">
              <div className="p-2 bg-emerald-500/10 rounded-lg text-emerald-400 border border-emerald-500/20">
                <Bell className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-base text-white">Notifications Center</h3>
                <p className="text-xs text-slate-400">Real-Time In-App, Push & SMS Gateway</p>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                onClick={() => setShowPreferences(!showPreferences)}
                className={`p-2 rounded-lg text-xs font-medium border transition-all ${
                  showPreferences 
                    ? 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30' 
                    : 'bg-slate-800/80 text-slate-300 border-slate-700 hover:bg-slate-700'
                }`}
                title="Notification Settings"
              >
                <Sliders className="w-4 h-4" />
              </button>
              <button
                onClick={onClose}
                className="p-2 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-400 hover:text-white transition-all"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Preferences Subpanel */}
          {showPreferences ? (
            <div className="p-5 flex-1 overflow-y-auto space-y-5 bg-[#0b0c10]">
              <div className="flex justify-between items-center pb-2 border-b border-slate-800">
                <h4 className="text-xs font-bold uppercase tracking-wider text-emerald-400 flex items-center gap-1.5">
                  <Sliders className="w-4 h-4" /> Channel Preferences
                </h4>
                <button
                  onClick={handleSavePreferences}
                  disabled={prefLoading}
                  className="px-3 py-1 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs rounded-lg transition-all"
                >
                  {prefLoading ? 'Saving...' : 'Save Settings'}
                </button>
              </div>

              {/* Master Channels */}
              <div className="space-y-3">
                <p className="text-xs font-semibold text-slate-400">Active Delivery Channels</p>
                <div className="grid grid-cols-2 gap-2.5">
                  {[
                    { key: 'inAppEnabled', label: 'In-App Alerts' },
                    { key: 'pushEnabled', label: 'Push (FCM)' },
                    { key: 'emailEnabled', label: 'Email Notices' },
                    { key: 'smsEnabled', label: 'SMS Gateway' }
                  ].map(ch => (
                    <label key={ch.key} className="flex items-center justify-between p-3 bg-slate-900/80 border border-slate-800 rounded-xl cursor-pointer hover:border-slate-700">
                      <span className="text-xs font-medium text-slate-200">{ch.label}</span>
                      <input
                        type="checkbox"
                        checked={(preferences as any)[ch.key]}
                        onChange={e => setPreferences(prev => ({ ...prev, [ch.key]: e.target.checked }))}
                        className="w-4 h-4 accent-emerald-500 rounded cursor-pointer"
                      />
                    </label>
                  ))}
                </div>
              </div>

              {/* Categories */}
              <div className="space-y-3">
                <p className="text-xs font-semibold text-slate-400">Topic Filters</p>
                <div className="space-y-2">
                  {['ORDER', 'WALLET', 'PROMO', 'DELIVERY', 'SYSTEM'].map(cat => (
                    <label key={cat} className="flex items-center justify-between p-2.5 bg-slate-900/60 border border-slate-800 rounded-lg cursor-pointer">
                      <span className="text-xs font-medium text-slate-300">{cat} Updates</span>
                      <input
                        type="checkbox"
                        checked={Boolean(preferences.categories[cat])}
                        onChange={e => setPreferences(prev => ({
                          ...prev,
                          categories: { ...prev.categories, [cat]: e.target.checked }
                        }))}
                        className="w-4 h-4 accent-emerald-500 rounded cursor-pointer"
                      />
                    </label>
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <>
              {/* Category Filter Tabs */}
              <div className="px-4 py-2.5 bg-[#0d0e14] border-b border-slate-800 flex items-center justify-between gap-2 overflow-x-auto text-xs shrink-0">
                <div className="flex items-center gap-1.5 overflow-x-auto">
                  {['ALL', 'ORDER', 'DELIVERY', 'WALLET', 'PROMO', 'SYSTEM'].map(cat => (
                    <button
                      key={cat}
                      onClick={() => setActiveCategory(cat)}
                      className={`px-3 py-1 rounded-full font-semibold whitespace-nowrap transition-all ${
                        activeCategory === cat 
                          ? 'bg-emerald-500 text-slate-950 shadow-sm' 
                          : 'bg-slate-800/60 text-slate-400 hover:text-white hover:bg-slate-800'
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>

                <div className="flex items-center gap-2 shrink-0">
                  <button
                    onClick={handleMarkAllRead}
                    className="text-[11px] font-semibold text-emerald-400 hover:text-emerald-300 flex items-center gap-1"
                    title="Mark all as read"
                  >
                    <CheckCheck className="w-3.5 h-3.5" /> Read All
                  </button>
                  <button
                    onClick={handleTriggerTestNotification}
                    disabled={testSending}
                    className="p-1.5 bg-slate-800 hover:bg-slate-700 text-purple-400 rounded-md transition-all"
                    title="Send Test Notification"
                  >
                    <Send className={`w-3.5 h-3.5 ${testSending ? 'animate-spin' : ''}`} />
                  </button>
                </div>
              </div>

              {/* Notification List */}
              <div className="flex-1 overflow-y-auto p-4 space-y-2.5 min-h-[300px]">
                {loading ? (
                  <div className="py-12 text-center text-slate-500 flex flex-col items-center gap-2">
                    <RefreshCw className="w-5 h-5 animate-spin text-emerald-400" />
                    <span className="text-xs">Fetching real-time notifications...</span>
                  </div>
                ) : filteredNotifications.length === 0 ? (
                  <div className="py-12 text-center text-slate-500 flex flex-col items-center gap-2">
                    <Bell className="w-8 h-8 opacity-30 text-slate-400" />
                    <p className="text-xs font-semibold text-slate-400">No notifications in {activeCategory}</p>
                    <p className="text-[11px] text-slate-600">You're all caught up!</p>
                  </div>
                ) : (
                  filteredNotifications.map(item => (
                    <div
                      key={item.id}
                      className={`p-3.5 rounded-xl border transition-all flex items-start justify-between gap-3 ${
                        item.read 
                          ? 'bg-slate-900/40 border-slate-800/80 text-slate-400' 
                          : 'bg-slate-900/90 border-emerald-500/30 text-white shadow-md'
                      }`}
                    >
                      <div className="flex gap-3 items-start flex-1">
                        <div className="p-2 bg-slate-800 rounded-lg shrink-0 mt-0.5">
                          {getCategoryIcon(item.category)}
                        </div>
                        <div className="space-y-1 flex-1">
                          <div className="flex items-center gap-2">
                            <h4 className="text-xs font-bold leading-tight text-white">{item.title}</h4>
                            {!item.read && (
                              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse shrink-0" />
                            )}
                          </div>
                          <p className="text-xs text-slate-300 leading-relaxed">{item.body}</p>
                          <div className="flex items-center gap-3 text-[10px] text-slate-500 pt-1">
                            <span>{new Date(item.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                            <span>•</span>
                            <span className="uppercase tracking-wider font-semibold text-slate-400">{item.channel}</span>
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center gap-1 shrink-0">
                        {!item.read && (
                          <button
                            onClick={() => handleMarkAsRead(item.id)}
                            className="p-1.5 text-slate-400 hover:text-emerald-400 rounded-md hover:bg-slate-800 transition-all"
                            title="Mark read"
                          >
                            <CheckCircle2 className="w-4 h-4" />
                          </button>
                        )}
                        <button
                          onClick={() => handleDeleteNotification(item.id)}
                          className="p-1.5 text-slate-500 hover:text-rose-400 rounded-md hover:bg-slate-800 transition-all"
                          title="Delete"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </>
          )}

          {/* Footer */}
          <div className="p-3 bg-[#0d0e14] border-t border-slate-800 text-center text-[10px] text-slate-500">
            FlashCart AI Real-Time Socket.IO & Multi-Channel Dispatch Active
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
}
