import React, { useState, useEffect, useRef } from 'react';
import { Product, Category, CartItem, MealPlan, BudgetPlan, PantryItem, DriverState, Order, FamilyMember } from '../types';
import { CATEGORIES } from '../data/products';
import { 
  Sparkles, Utensils, Camera, Brain, ShoppingBag, User, Search, MapPin, 
  TrendingUp, X, Plus, Minus, Trash2, Smartphone, Activity, Zap, 
  RotateCcw, Dumbbell, Smile, Flame, Music, Coins, ChevronRight, 
  ArrowRight, SlidersHorizontal, Heart, Clock, Check, HelpCircle, Eye, Bookmark,
  Package, FileText, Printer, RefreshCw, AlertCircle, CheckCircle2, XCircle, Calendar, Gift, Truck, Info, Receipt,
  Wallet, CreditCard, ArrowDownLeft, ArrowUpRight, ShieldCheck, Bell
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import NotificationCenterModal from './NotificationCenterModal';

interface CustomerAppProps {
  products: Product[];
  cart: CartItem[];
  setCart: React.Dispatch<React.SetStateAction<CartItem[]>>;
  activeOrder: Order | null;
  setActiveOrder: React.Dispatch<React.SetStateAction<Order | null>>;
  riderState: DriverState;
  setRiderState: React.Dispatch<React.SetStateAction<DriverState>>;
  currentProfile: 'arav' | 'nisha';
  setCurrentProfile: React.Dispatch<React.SetStateAction<'arav' | 'nisha'>>;
  collaborativeCartActive: boolean;
  setCollaborativeCartActive: React.Dispatch<React.SetStateAction<boolean>>;
  walletBalance: number;
  setWalletBalance: React.Dispatch<React.SetStateAction<number>>;
  activeScreen: string;
  setActiveScreen: (screen: string) => void;
}

export default function CustomerApp({
  products,
  cart,
  setCart,
  activeOrder,
  setActiveOrder,
  riderState,
  setRiderState,
  currentProfile,
  setCurrentProfile,
  collaborativeCartActive,
  setCollaborativeCartActive,
  walletBalance,
  setWalletBalance,
  activeScreen,
  setActiveScreen
}: CustomerAppProps) {

  // Search and Filters
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedMood, setSelectedMood] = useState<string | null>(null);

  // AI Assistant State
  const [assistantPrompt, setAssistantPrompt] = useState('');
  const [assistantLoading, setAssistantLoading] = useState(false);
  const [assistantExplanation, setAssistantExplanation] = useState('');
  
  // Pantry Scanner State
  const [pantryPreset, setPantryPreset] = useState<number>(0);
  const [scanningLoading, setScanningLoading] = useState(false);
  const [scannedResult, setScannedResult] = useState<any | null>(null);
  const [customPhotoBase64, setCustomPhotoBase64] = useState<string | null>(null);

  // Smart Meal Planner state
  const [diet, setDiet] = useState('Veg');
  const [cuisine, setCuisine] = useState('Indian');
  const [calories, setCalories] = useState(2000);
  const [budget, setBudget] = useState(800);
  const [mealPlannerResult, setMealPlannerResult] = useState<MealPlan | null>(null);
  const [mealPlannerLoading, setMealPlannerLoading] = useState(false);

  // AI Recipe state
  const [recipeSearch, setRecipeSearch] = useState('Paneer Butter Masala');
  const [recipeResult, setRecipeResult] = useState<any | null>(null);
  const [recipeLoading, setRecipeLoading] = useState(false);

  // Gamification Wheel / Streak State
  const [streakCount, setStreakCount] = useState(5);
  const [spinCompleted, setSpinCompleted] = useState(false);
  const [spinWinnerMsg, setSpinWinnerMsg] = useState('');
  const [spinning, setSpinning] = useState(false);

  // Wishlist State
  const [wishlist, setWishlist] = useState<string[]>([]);

  // Coupon State
  const [couponCodeInput, setCouponCodeInput] = useState('');
  const [appliedCoupon, setAppliedCoupon] = useState<string | null>(null);
  const [couponDiscount, setCouponDiscount] = useState(0);
  const [couponMessage, setCouponMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [couponLoading, setCouponLoading] = useState(false);

  // Available Coupons List State
  const [availableCoupons, setAvailableCoupons] = useState<any[]>([]);

  // Emergency Modal
  const [emergencyModalOpen, setEmergencyModalOpen] = useState(false);

  // Order Management System State
  const [ordersHistory, setOrdersHistory] = useState<any[]>([]);
  const [ordersFilter, setOrdersFilter] = useState<'All' | 'Active' | 'Delivered' | 'Cancelled'>('All');
  const [selectedOrderDetails, setSelectedOrderDetails] = useState<any | null>(null);
  const [invoiceModalOrder, setInvoiceModalOrder] = useState<any | null>(null);
  const [invoiceData, setInvoiceData] = useState<any | null>(null);
  const [timelineModalOrder, setTimelineModalOrder] = useState<any | null>(null);
  const [timelineData, setTimelineData] = useState<any[] | null>(null);
  const [cancellingOrderId, setCancellingOrderId] = useState<string | null>(null);
  const [cancelReasonInput, setCancelReasonInput] = useState('');
  const [isGiftOrder, setIsGiftOrder] = useState(false);
  const [giftMessageInput, setGiftMessageInput] = useState('');
  const [scheduledDeliveryTime, setScheduledDeliveryTime] = useState('');
  const [orderNotesInput, setOrderNotesInput] = useState('');

  // Fetch Orders History
  const fetchOrdersHistory = async () => {
    try {
      const res = await fetch('/api/orders');
      if (res.ok) {
        const data = await res.json();
        setOrdersHistory(Array.isArray(data) ? data : []);
      }
    } catch (e) {
      console.error("Error fetching orders history:", e);
    }
  };

  // Payments & Wallet State (Module 6)
  const [walletLedger, setWalletLedger] = useState<any[]>([]);
  const [rewardPoints, setRewardPoints] = useState<number>(350);
  const [paymentHistory, setPaymentHistory] = useState<any[]>([]);
  const [topupModalOpen, setTopupModalOpen] = useState(false);
  const [topupAmountInput, setTopupAmountInput] = useState<number>(1000);
  const [topupMethodInput, setTopupMethodInput] = useState<string>('UPI (GPay)');
  const [withdrawModalOpen, setWithdrawModalOpen] = useState(false);
  const [withdrawAmountInput, setWithdrawAmountInput] = useState<number>(500);
  const [withdrawUpiInput, setWithdrawUpiInput] = useState<string>('arav@okicici');
  const [rewardModalOpen, setRewardModalOpen] = useState(false);
  const [redeemPointsInput, setRedeemPointsInput] = useState<number>(100);
  const [selectedPaymentMethod, setSelectedPaymentMethod] = useState<string>('Shared Wallet (Family)');
  const [giftCardCodeInput, setGiftCardCodeInput] = useState<string>('');

  // Fetch Wallet & Ledger Data
  const fetchWalletData = async () => {
    try {
      const res = await fetch('/api/wallet');
      if (res.ok) {
        const data = await res.json();
        setWalletBalance(data.balance);
        setRewardPoints(data.rewardPoints || 350);
        setWalletLedger(data.ledger || []);
      }
    } catch (e) {
      console.error("Error fetching wallet data:", e);
    }
  };

  // Fetch Payment Transactions History
  const fetchPaymentHistory = async () => {
    try {
      const res = await fetch('/api/payments/history');
      if (res.ok) {
        const data = await res.json();
        setPaymentHistory(Array.isArray(data) ? data : []);
      }
    } catch (e) {
      console.error("Error fetching payment history:", e);
    }
  };

  // Module 8 Notification State
  const [notificationModalOpen, setNotificationModalOpen] = useState(false);
  const [unreadNotificationCount, setUnreadNotificationCount] = useState<number>(0);

  // Fetch Unread Notifications Count
  const fetchUnreadNotificationCount = async () => {
    try {
      const res = await fetch('/api/notifications/unread?userId=u1&role=CUSTOMER');
      if (res.ok) {
        const data = await res.json();
        setUnreadNotificationCount(data.unreadCount || 0);
      }
    } catch (e) {
      console.error("Error fetching unread notifications count:", e);
    }
  };
  const handleTopupSubmit = async () => {
    try {
      const res = await fetch('/api/wallet/topup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          amount: topupAmountInput,
          paymentMethod: topupMethodInput
        })
      });

      if (res.ok) {
        const data = await res.json();
        setWalletBalance(data.newBalance);
        setTopupModalOpen(false);
        await fetchWalletData();
        await fetchPaymentHistory();
        alert(`Successfully topped up ₹${topupAmountInput} into your FlashCart wallet!`);
      } else {
        const err = await res.json();
        alert(err.error || "Top-up failed");
      }
    } catch (e) {
      console.error("Topup error:", e);
    }
  };

  const handleWithdrawSubmit = async () => {
    try {
      const res = await fetch('/api/wallet/withdraw', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          amount: withdrawAmountInput,
          upiId: withdrawUpiInput
        })
      });

      if (res.ok) {
        const data = await res.json();
        setWalletBalance(data.newBalance);
        setWithdrawModalOpen(false);
        await fetchWalletData();
        alert(`Successfully withdrew ₹${withdrawAmountInput} to ${withdrawUpiInput}!`);
      } else {
        const err = await res.json();
        alert(err.error || "Withdrawal failed");
      }
    } catch (e) {
      console.error("Withdrawal error:", e);
    }
  };

  const handleRedeemPointsSubmit = async () => {
    try {
      const res = await fetch('/api/wallet/reward', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          points: redeemPointsInput
        })
      });

      if (res.ok) {
        const data = await res.json();
        setWalletBalance(data.newBalance);
        setRewardPoints(data.remainingPoints);
        setRewardModalOpen(false);
        await fetchWalletData();
        alert(`Successfully converted ${redeemPointsInput} loyalty points into ₹${redeemPointsInput / 10} wallet cash!`);
      } else {
        const err = await res.json();
        alert(err.error || "Redemption failed");
      }
    } catch (e) {
      console.error("Redemption error:", e);
    }
  };

  useEffect(() => {
    fetchOrdersHistory();
    fetchWalletData();
    fetchPaymentHistory();
    fetchUnreadNotificationCount();
    const interval = setInterval(() => {
      fetchOrdersHistory();
      fetchWalletData();
      fetchPaymentHistory();
      fetchUnreadNotificationCount();
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  // Cancel Order
  const handleCancelOrder = async (orderId: string, reason?: string) => {
    try {
      const res = await fetch(`/api/orders/${orderId}/cancel`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason: reason || 'Cancelled by customer' })
      });
      if (res.ok) {
        setCancellingOrderId(null);
        setCancelReasonInput('');
        await fetchOrdersHistory();
        if (activeOrder && activeOrder.id === orderId) {
          setActiveOrder(null);
        }
        const pRes = await fetch('/api/user/profile');
        if (pRes.ok) {
          const pData = await pRes.json();
          if (pData.walletBalance !== undefined) setWalletBalance(pData.walletBalance);
        }
      } else {
        const err = await res.json();
        alert(err.error || "Could not cancel order");
      }
    } catch (e) {
      console.error("Error cancelling order:", e);
    }
  };

  // Repeat Order
  const handleRepeatOrder = async (orderId: string) => {
    try {
      const res = await fetch(`/api/orders/${orderId}/repeat`, {
        method: 'POST'
      });
      if (res.ok) {
        const data = await res.json();
        const cRes = await fetch('/api/cart');
        if (cRes.ok) {
          const cData = await cRes.json();
          setCart(Array.isArray(cData) ? cData : (cData.cart || []));
        }
        alert(`Successfully re-added ${data.itemsAdded || 'items'} to your cart!`);
        setActiveScreen('cart');
      } else {
        const err = await res.json();
        alert(err.error || "Could not repeat order");
      }
    } catch (e) {
      console.error("Error repeating order:", e);
    }
  };

  // View Invoice
  const handleFetchInvoice = async (orderId: string) => {
    try {
      const res = await fetch(`/api/orders/${orderId}/invoice`);
      if (res.ok) {
        const inv = await res.json();
        setInvoiceData(inv);
        setInvoiceModalOrder(ordersHistory.find(o => o.id === orderId) || activeOrder);
      }
    } catch (e) {
      console.error("Error fetching invoice:", e);
    }
  };

  // View Timeline
  const handleFetchTimeline = async (orderId: string) => {
    try {
      const res = await fetch(`/api/orders/${orderId}/timeline`);
      if (res.ok) {
        const timeline = await res.json();
        setTimelineData(timeline);
        setTimelineModalOrder(ordersHistory.find(o => o.id === orderId) || activeOrder);
      }
    } catch (e) {
      console.error("Error fetching timeline:", e);
    }
  };

  // Shared state references
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Fetch Wishlist and Available Coupons on mount
  useEffect(() => {
    const fetchWishlistAndCoupons = async () => {
      try {
        const wRes = await fetch('/api/wishlist');
        if (wRes.ok) {
          const wData = await wRes.json();
          setWishlist(Array.isArray(wData) ? wData : (wData.wishlist || []));
        }

        const cRes = await fetch('/api/coupons');
        if (cRes.ok) {
          const cData = await cRes.json();
          setAvailableCoupons(Array.isArray(cData) ? cData : []);
        }
      } catch (err) {
        console.error("Error fetching wishlist or coupons:", err);
      }
    };
    fetchWishlistAndCoupons();
  }, []);

  const handleToggleWishlist = async (productId: string) => {
    try {
      const res = await fetch('/api/wishlist/toggle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ productId })
      });
      if (res.ok) {
        const data = await res.json();
        setWishlist(Array.isArray(data) ? data : (data.wishlist || []));
      }
    } catch (e) {
      console.error("Error toggling wishlist:", e);
    }
  };

  // Filter Products based on category & search & mood
  const getFilteredProducts = () => {
    let list = [...products];

    if (selectedCategory) {
      list = list.filter(p => p.category === selectedCategory);
    }

    if (searchQuery) {
      list = list.filter(p => p.name.toLowerCase().includes(searchQuery.toLowerCase()));
    }

    if (selectedMood) {
      if (selectedMood === 'Gym') {
        list = list.filter(p => p.protein > 5 || p.isHealthy);
      } else if (selectedMood === 'Lazy') {
        list = list.filter(p => p.category === 'snacks' || p.category === 'dairy' || p.deliveryTimeMins <= 8);
      } else if (selectedMood === 'Festival') {
        list = list.filter(p => p.isOrganic || p.badge === 'Premium');
      } else if (selectedMood === 'Party') {
        list = list.filter(p => p.category === 'snacks' || p.category === 'beverages');
      }
    }

    return list;
  };

  // Quick Cart Modification
  const handleAddToCart = (product: Product, addedByMember?: string) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id);
      if (existing) {
        return prev.map(item => item.product.id === product.id ? { ...item, quantity: item.quantity + 1, isSavedForLater: false } : item);
      }
      return [...prev, { product, quantity: 1, addedBy: addedByMember || (currentProfile === 'arav' ? 'Arav' : 'Nisha'), isSavedForLater: false }];
    });
  };

  const handleRemoveFromCart = (product: Product) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id);
      if (!existing) return prev;
      if (existing.quantity === 1) {
        return prev.filter(item => item.product.id !== product.id);
      }
      return prev.map(item => item.product.id === product.id ? { ...item, quantity: item.quantity - 1 } : item);
    });
  };

  const handleToggleSaveForLater = async (product: Product) => {
    const targetItem = cart.find(i => i.product.id === product.id);
    if (!targetItem) return;
    const newSavedStatus = !targetItem.isSavedForLater;

    setCart(prev => prev.map(item => item.product.id === product.id ? { ...item, isSavedForLater: newSavedStatus } : item));

    try {
      await fetch('/api/cart/save-for-later', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ productId: product.id, isSavedForLater: newSavedStatus })
      });
    } catch (e) {
      console.error("Error toggling save for later:", e);
    }
  };

  const handleApplyCoupon = async (codeToApply?: string) => {
    const targetCode = (codeToApply || couponCodeInput).trim().toUpperCase();
    if (!targetCode) return;
    setCouponLoading(true);
    setCouponMessage(null);

    try {
      const res = await fetch('/api/coupons/apply', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code: targetCode, subtotal: cartSubtotal })
      });

      const data = await res.json();
      if (res.ok && data.status === 'success') {
        setAppliedCoupon(targetCode);
        setCouponDiscount(data.discountAmount);
        setCouponMessage({ type: 'success', text: `Coupon ${targetCode} applied! Saved ₹${data.discountAmount}` });
        setCouponCodeInput(targetCode);
      } else {
        setCouponMessage({ type: 'error', text: data.message || data.reason || 'Invalid coupon code' });
      }
    } catch (e) {
      console.error("Error applying coupon:", e);
      setCouponMessage({ type: 'error', text: 'Error connecting to coupon engine' });
    } finally {
      setCouponLoading(false);
    }
  };

  const handleRemoveCoupon = async () => {
    setAppliedCoupon(null);
    setCouponDiscount(0);
    setCouponCodeInput('');
    setCouponMessage(null);
    try {
      await fetch('/api/coupons/remove', { method: 'DELETE' });
    } catch (e) {
      console.error("Error removing coupon:", e);
    }
  };

  const clearCart = () => setCart([]);

  // Split calculations
  const activeCartItems = cart.filter(item => !item.isSavedForLater);
  const savedForLaterItems = cart.filter(item => item.isSavedForLater);

  const cartSubtotal = activeCartItems.reduce((sum, item) => sum + (item.product.price * item.quantity), 0);
  const ecoSavingsKg = activeCartItems.reduce((sum, item) => sum + (item.quantity * (1.5 - item.product.carbonEmission)), 0);
  const healthAverage = activeCartItems.length ? Math.round(activeCartItems.reduce((sum, item) => sum + (item.product.isHealthy ? 95 : 35), 0) / activeCartItems.length) : 100;
  
  const deliveryFee = cartSubtotal > 199 || cartSubtotal === 0 ? 0 : 25;
  const carbonOffsetFee = activeCartItems.length > 0 ? 5 : 0;
  const cartTotal = Math.max(0, cartSubtotal + deliveryFee + carbonOffsetFee - couponDiscount);


  // AI ASSISTANT RUN
  const runAIAssistant = async (promptText: string) => {
    setAssistantLoading(true);
    try {
      const response = await fetch('/api/gemini/assistant', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: promptText, currentCart: cart })
      });
      const data = await response.json();
      setAssistantExplanation(data.explanation);

      if (data.items && Array.isArray(data.items)) {
        // Map product IDs to real products
        const newCartItems: CartItem[] = [];
        data.items.forEach((aiItem: any) => {
          const match = products.find(p => p.id === aiItem.productId);
          if (match) {
            newCartItems.push({
              product: match,
              quantity: aiItem.quantity,
              addedBy: currentProfile === 'arav' ? 'Arav (AI)' : 'Nisha (AI)'
            });
          }
        });
        if (newCartItems.length > 0) {
          setCart(newCartItems);
        }
      }
    } catch (e) {
      console.error(e);
    } finally {
      setAssistantLoading(false);
    }
  };

  // PANTRY SCANNER
  const runPantryScanner = async (presetIdx: number, base64?: string) => {
    setScanningLoading(true);
    try {
      const response = await fetch('/api/gemini/pantry-scanner', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ imagePresetIndex: presetIdx, imageBase64: base64 })
      });
      const data = await response.json();
      setScannedResult(data);
    } catch (e) {
      console.error(e);
    } finally {
      setScanningLoading(false);
    }
  };

  // MEAL PLANNER
  const runMealPlanner = async () => {
    setMealPlannerLoading(true);
    try {
      const response = await fetch('/api/gemini/meal-generator', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ diet, cuisine, calories, budget })
      });
      const data = await response.json();
      setMealPlannerResult(data);
    } catch (e) {
      console.error(e);
    } finally {
      setMealPlannerLoading(false);
    }
  };

  // RECIPE MODE
  const runRecipeMode = async (rName: string) => {
    setRecipeLoading(true);
    try {
      const response = await fetch('/api/gemini/recipe-helper', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ recipeName: rName })
      });
      const data = await response.json();
      setRecipeResult(data);
    } catch (e) {
      console.error(e);
    } finally {
      setRecipeLoading(false);
    }
  };

  // Place Order Transaction
  const handlePlaceOrder = async () => {
    if (cart.length === 0) return;
    
    // Check wallet balance if wallet payment selected
    if ((selectedPaymentMethod === 'Shared Wallet (Family)' || selectedPaymentMethod === 'FlashCart Wallet') && walletBalance < cartTotal) {
      alert("Insufficient Balance in FlashCart wallet! Restock wallet in the Wallet Hub.");
      setActiveScreen('wallet');
      return;
    }

    try {
      let paymentTxId = undefined;

      // Execute Payment State Machine for non-wallet or wallet payments
      if (selectedPaymentMethod !== 'Shared Wallet (Family)' && selectedPaymentMethod !== 'Cash On Delivery') {
        const createRes = await fetch('/api/payments/create', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            amount: cartTotal,
            paymentMethod: selectedPaymentMethod,
            provider: selectedPaymentMethod.includes('UPI') ? 'UPI' :
                      selectedPaymentMethod.includes('Card') ? 'STRIPE' : 'RAZORPAY',
            giftCardCode: selectedPaymentMethod === 'FlashCart Gift Card' ? giftCardCodeInput : undefined
          })
        });

        if (createRes.ok) {
          const createData = await createRes.json();
          paymentTxId = createData.transactionId || createData.payment?.id;

          // Verify Payment Intent
          const verifyRes = await fetch('/api/payments/verify', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              paymentId: createData.payment?.id,
              signature: `sig_mock_${Date.now()}`
            })
          });

          if (!verifyRes.ok) {
            alert("Payment gateway verification failed. Please try again.");
            return;
          }
        }
      }

      const res = await fetch('/api/orders', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          items: cart,
          subtotal: cartSubtotal,
          deliveryFee,
          discount: couponDiscount,
          total: cartTotal,
          paymentMethod: selectedPaymentMethod,
          paymentTransactionId: paymentTxId,
          notes: orderNotesInput,
          isGift: isGiftOrder,
          giftMessage: giftMessageInput,
          scheduledTime: scheduledDeliveryTime
        })
      });

      if (res.ok) {
        const data = await res.json();
        if (data.walletBalance !== undefined) {
          setWalletBalance(data.walletBalance);
        }
        setActiveOrder(data.order);
        setRiderState(prev => ({
          ...prev,
          status: 'assigned',
          lat: 12.9279,
          lng: 77.6250
        }));
        setOrderNotesInput('');
        setIsGiftOrder(false);
        setGiftMessageInput('');
        setScheduledDeliveryTime('');
        await fetchOrdersHistory();
        await fetchWalletData();
        await fetchPaymentHistory();
        setActiveScreen('tracking');
      } else {
        const err = await res.json();
        alert(err.error || "Failed to place order");
      }
    } catch (e) {
      console.error("Error placing order:", e);
      alert("Unable to process purchase transaction");
    }
  };

  // Custom Image Upload Handler
  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        const base64String = reader.result as string;
        setCustomPhotoBase64(base64String);
        runPantryScanner(0, base64String);
      };
      reader.readAsDataURL(file);
    }
  };

  // Spin Wheel Gamification
  const handleSpinWheel = () => {
    if (spinning) return;
    setSpinning(true);
    setTimeout(() => {
      setSpinning(false);
      setSpinCompleted(true);
      const prizes = ["₹50 Wallet Cashback", "Free Organic Banana Bunch", "Eco-Score Multiplier", "Double Streak Boost"];
      const randomPrize = prizes[Math.floor(Math.random() * prizes.length)];
      setSpinWinnerMsg(`Congratulations! You won: ${randomPrize}`);
      if (randomPrize.includes("Wallet")) {
        setWalletBalance(prev => prev + 50);
      }
    }, 2500);
  };

  // One-tap Emergency Order
  const triggerEmergencyOrder = (type: 'Medicine' | 'Milk' | 'Baby') => {
    clearCart();
    let selectedProds: Product[] = [];
    if (type === 'Medicine') {
      selectedProds = products.filter(p => p.category === 'medicine');
    } else if (type === 'Milk') {
      selectedProds = products.filter(p => p.id === 'p7');
    } else if (type === 'Baby') {
      selectedProds = products.filter(p => p.category === 'baby');
    }

    selectedProds.forEach(p => {
      handleAddToCart(p, "Emergency System");
    });

    setEmergencyModalOpen(false);
    setTimeout(() => {
      setActiveScreen('cart');
    }, 200);
  };

  // Active Map Delivery Tracking logic
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (activeOrder && riderState.status !== 'delivered') {
      interval = setInterval(() => {
        setRiderState(prev => {
          // Dark warehouse is roughly (12.9279, 77.6250)
          // Customer home is (12.9348, 77.6189)
          // Linearly interpolate coordinates based on rider status progress
          let targetLat = 12.9348;
          let targetLng = 77.6189;

          if (prev.status === 'assigned') {
            // headed to store
            targetLat = 12.9279;
            targetLng = 77.6250;
          } else if (prev.status === 'at_store') {
            targetLat = 12.9282;
            targetLng = 77.6245;
          } else if (prev.status === 'picked_up') {
            targetLat = 12.9310;
            targetLng = 77.6220;
          } else if (prev.status === 'near_delivery') {
            targetLat = 12.9340;
            targetLng = 77.6195;
          }

          // Move rider 5% closer to target each tick to simulate continuous GPS signal
          const deltaLat = (targetLat - prev.lat) * 0.15;
          const deltaLng = (targetLng - prev.lng) * 0.15;

          return {
            ...prev,
            lat: prev.lat + deltaLat,
            lng: prev.lng + deltaLng,
            bearing: Math.atan2(deltaLng, deltaLat) * (180 / Math.PI)
          };
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [activeOrder, riderState.status]);

  return (
    <div className="w-full max-w-[420px] h-[780px] bg-slate-950 rounded-[48px] border-[12px] border-slate-900 shadow-2xl relative overflow-hidden flex flex-col font-sans">
      
      {/* iPhone Dynamic Island */}
      <div className="absolute top-2 left-1/2 -translate-x-1/2 w-32 h-6 bg-black rounded-full z-50 flex items-center justify-between px-3.5">
        <div className="w-2.5 h-2.5 rounded-full bg-slate-900"></div>
        <div className="flex gap-1">
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping"></span>
          <span className="text-[9px] text-emerald-400 font-mono">9m</span>
        </div>
      </div>

      {/* StatusBar */}
      <div className="bg-[#0b0c0e] h-10 pt-2 px-6 flex items-center justify-between text-[11px] text-slate-400 font-medium select-none">
        <span>09:41</span>
        <div className="flex items-center gap-1.5">
          <Activity className="w-3.5 h-3.5 text-emerald-500" />
          <span className="text-[10px] text-emerald-400 font-semibold uppercase font-mono">5G+ Ultra</span>
        </div>
      </div>

      {/* Header Context Bar */}
      <div className="bg-[#0f1115] border-b border-slate-900 px-4 py-2 flex items-center justify-between z-10">
        <div className="flex items-center gap-2">
          <MapPin className="w-4 h-4 text-emerald-400" />
          <div className="text-left">
            <p className="text-[10px] text-slate-500 uppercase tracking-wider font-bold">Delivering To</p>
            <p className="text-xs font-semibold text-white truncate max-w-[150px]">Symphony Premium Apts...</p>
          </div>
        </div>

        {/* Profile Mode & Wallet Badge */}
        <div className="flex items-center gap-2">
          {/* Module 8 Notification Center Bell */}
          <button 
            onClick={() => setNotificationModalOpen(true)}
            className="relative bg-slate-900 border border-slate-800 hover:border-emerald-500/50 rounded-full p-1.5 text-slate-300 hover:text-white transition-all active:scale-95 flex items-center justify-center"
            title="Notification Center"
          >
            <Bell className="w-4 h-4 text-emerald-400" />
            {unreadNotificationCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-rose-500 text-white text-[9px] font-bold px-1 min-w-[16px] h-4 rounded-full flex items-center justify-center border border-slate-950 animate-pulse">
                {unreadNotificationCount}
              </span>
            )}
          </button>

          <button 
            onClick={() => setActiveScreen('wallet')}
            className="bg-slate-900 border border-slate-800 hover:border-emerald-500/50 rounded-full px-2.5 py-1 flex items-center gap-1 transition-all active:scale-95"
            title="Open Wallet & Payment Hub"
          >
            <Coins className="w-3.5 h-3.5 text-amber-400 animate-bounce" />
            <span className="text-xs font-bold text-white">₹{Math.round(walletBalance)}</span>
          </button>

          <button 
            onClick={() => setCurrentProfile(currentProfile === 'arav' ? 'nisha' : 'arav')}
            className="w-7 h-7 rounded-full bg-slate-800 overflow-hidden border border-emerald-400 transition-transform active:scale-95"
            title="Switch User Mode"
          >
            <img 
              src={currentProfile === 'arav' ? "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=60" : "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=60"} 
              alt="Avatar"
              className="w-full h-full object-cover"
            />
          </button>
        </div>
      </div>

      {/* Main Screen Container */}
      <div className="flex-1 overflow-y-auto pb-20 text-slate-100 bg-[#0c0d0f] scrollbar-thin">
        
        {/* WELCOME BANNER (Only on Home screen) */}
        {activeScreen === 'home' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-lg font-bold text-white tracking-tight">
                  Bonjour, {currentProfile === 'arav' ? 'Arav' : 'Nisha'} 👋
                </h1>
                <p className="text-[11px] text-slate-400">
                  {currentProfile === 'arav' ? '💪 Gym & Keto optimizer active' : '🏡 Family shopping room shared'}
                </p>
              </div>

              {/* Shopping Streak */}
              <div className="flex items-center gap-1 bg-amber-500/10 border border-amber-500/20 px-2.5 py-1 rounded-full">
                <Flame className="w-3.5 h-3.5 text-amber-500 animate-pulse" />
                <span className="text-[10px] font-bold text-amber-400">{streakCount} Day Streak</span>
              </div>
            </div>

            {/* Quick Search */}
            <div className="relative">
              <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
              <input 
                type="text"
                placeholder="Search Paneer, Bananas, Cold brew..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-[#121418] border border-slate-800/80 rounded-2xl pl-10 pr-4 py-2.5 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500"
              />
            </div>

            {/* MOOD & CONTEXT AI CARDS */}
            <div className="space-y-2">
              <p className="text-[11px] text-slate-500 font-bold uppercase tracking-wider">Shop by Mood / Target Diet</p>
              <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none">
                {[
                  { name: 'Gym', label: 'High Protein', icon: Dumbbell, color: 'border-cyan-500/20 bg-cyan-500/5 text-cyan-400' },
                  { name: 'Lazy', label: 'Instant Cook', icon: Zap, color: 'border-amber-500/20 bg-amber-500/5 text-amber-400' },
                  { name: 'Festival', label: 'Organics', icon: Sparkles, color: 'border-yellow-500/20 bg-yellow-500/5 text-yellow-400' },
                  { name: 'Party', label: 'Snacks/Drinks', icon: Music, color: 'border-pink-500/20 bg-pink-500/5 text-pink-400' }
                ].map((mood) => {
                  const IconComponent = mood.icon;
                  return (
                    <button
                      key={mood.name}
                      onClick={() => setSelectedMood(selectedMood === mood.name ? null : mood.name)}
                      className={`flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold border transition-all shrink-0 ${
                        selectedMood === mood.name 
                          ? 'bg-emerald-500 text-slate-950 border-emerald-400 scale-95' 
                          : mood.color
                      }`}
                    >
                      <IconComponent className="w-3.5 h-3.5" />
                      <div>
                        <p className="text-[10px] leading-tight font-bold">{mood.name}</p>
                        <p className="text-[8px] opacity-80 font-normal">{mood.label}</p>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* CORE EXPERIENCES SELECTOR */}
            <div className="grid grid-cols-2 gap-2.5">
              <button 
                onClick={() => setActiveScreen('assistant')}
                className="bg-gradient-to-br from-emerald-500/10 to-teal-500/5 border border-emerald-500/20 p-3.5 rounded-2xl text-left relative overflow-hidden group active:scale-95 transition-all"
              >
                <div className="absolute right-2 top-2 bg-emerald-500/20 p-1.5 rounded-lg">
                  <Brain className="w-5 h-5 text-emerald-400" />
                </div>
                <h3 className="text-xs font-bold text-white mb-0.5">AI Shopping Assistant</h3>
                <p className="text-[9px] text-slate-400 max-w-[110px]">Type "Breakfast for 5" to build dynamic cart</p>
              </button>

              <button 
                onClick={() => setActiveScreen('planner')}
                className="bg-gradient-to-br from-purple-500/10 to-indigo-500/5 border border-purple-500/20 p-3.5 rounded-2xl text-left relative overflow-hidden group active:scale-95 transition-all"
              >
                <div className="absolute right-2 top-2 bg-purple-500/20 p-1.5 rounded-lg">
                  <Utensils className="w-5 h-5 text-purple-400" />
                </div>
                <h3 className="text-xs font-bold text-white mb-0.5">Smart Meal Planner</h3>
                <p className="text-[9px] text-slate-400 max-w-[110px]">Autogenerate meals mapped to products</p>
              </button>

              <button 
                onClick={() => setActiveScreen('scanner')}
                className="bg-gradient-to-br from-blue-500/10 to-sky-500/5 border border-blue-500/20 p-3.5 rounded-2xl text-left relative overflow-hidden group active:scale-95 transition-all"
              >
                <div className="absolute right-2 top-2 bg-blue-500/20 p-1.5 rounded-lg">
                  <Camera className="w-5 h-5 text-blue-400" />
                </div>
                <h3 className="text-xs font-bold text-white mb-0.5">Fridge Vision Scanner</h3>
                <p className="text-[9px] text-slate-400 max-w-[110px]">Snap pantry photo to detect low stocks</p>
              </button>

              <button 
                onClick={() => setActiveScreen('recipes')}
                className="bg-gradient-to-br from-amber-500/10 to-orange-500/5 border border-amber-500/20 p-3.5 rounded-2xl text-left relative overflow-hidden group active:scale-95 transition-all"
              >
                <div className="absolute right-2 top-2 bg-amber-500/20 p-1.5 rounded-lg">
                  <Sparkles className="w-5 h-5 text-amber-400" />
                </div>
                <h3 className="text-xs font-bold text-white mb-0.5">AI Recipe Cart-Builder</h3>
                <p className="text-[9px] text-slate-400 max-w-[110px]">Add complete recipe ingredients instantly</p>
              </button>
            </div>

            {/* ONE-TAP EMERGENCY LAUNCHER */}
            <div className="bg-gradient-to-r from-rose-950/40 to-rose-900/10 border border-rose-500/20 p-3 rounded-2xl flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="bg-rose-500/20 p-1.5 rounded-lg">
                  <Zap className="w-4 h-4 text-rose-400" />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white">Emergency Shopping</h4>
                  <p className="text-[9px] text-slate-400">One-tap order baby, milk, or medicine refills</p>
                </div>
              </div>
              <button 
                onClick={() => setEmergencyModalOpen(true)}
                className="px-3 py-1 bg-rose-500 text-slate-950 font-bold rounded-lg text-[10px] active:scale-95 transition-transform"
              >
                LAUNCH
              </button>
            </div>

            {/* CATEGORIES SCROLLER */}
            <div className="space-y-2">
              <div className="flex justify-between items-center">
                <span className="text-[11px] text-slate-500 font-bold uppercase tracking-wider">Explore Departments</span>
                {selectedCategory && (
                  <button onClick={() => setSelectedCategory(null)} className="text-[10px] text-emerald-400 font-semibold">
                    Clear Filter
                  </button>
                )}
              </div>
              <div className="grid grid-cols-4 gap-2">
                {CATEGORIES.map(cat => (
                  <button
                    key={cat.id}
                    onClick={() => setSelectedCategory(selectedCategory === cat.id ? null : cat.id)}
                    className={`p-2.5 rounded-xl border text-center transition-all ${
                      selectedCategory === cat.id 
                        ? 'border-emerald-500 bg-emerald-500/10' 
                        : 'border-slate-800 bg-slate-900/30 hover:border-slate-700'
                    }`}
                  >
                    <span className="text-[9px] text-slate-300 font-bold line-clamp-1">{cat.name}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* PRODUCT CATALOG GRID */}
            <div className="space-y-3">
              <span className="text-[11px] text-slate-500 font-bold uppercase tracking-wider">
                {selectedCategory ? `${CATEGORIES.find(c => c.id === selectedCategory)?.name}` : 'Recommended Items'}
              </span>
              <div className="grid grid-cols-2 gap-3">
                {getFilteredProducts().map(prod => (
                  <div key={prod.id} className="bg-slate-900/40 border border-slate-800 rounded-2xl p-3 flex flex-col justify-between space-y-2 relative overflow-hidden group hover:border-slate-700">
                    {/* Badge if present */}
                    {prod.badge && (
                      <span className="absolute top-2 left-2 bg-purple-500 text-slate-950 font-bold text-[8px] px-1.5 py-0.5 rounded-md z-10">
                        {prod.badge}
                      </span>
                    )}

                    {/* Image and Time */}
                    <div className="relative aspect-square rounded-xl overflow-hidden bg-slate-950">
                      <img 
                        src={prod.image} 
                        alt={prod.name} 
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                        referrerPolicy="no-referrer"
                      />
                      <button 
                        onClick={(e) => { e.stopPropagation(); handleToggleWishlist(prod.id); }}
                        className="absolute top-1.5 right-1.5 p-1 rounded-full bg-slate-950/70 hover:bg-slate-900 transition-colors z-10"
                        title="Toggle Wishlist"
                      >
                        <Heart className={`w-3.5 h-3.5 ${wishlist.includes(prod.id) ? 'fill-rose-500 text-rose-500' : 'text-slate-400'}`} />
                      </button>
                      <span className="absolute bottom-1 right-1 bg-slate-950/80 px-1.5 py-0.5 rounded text-[8px] text-emerald-400 font-mono font-bold flex items-center gap-0.5">
                        <Clock className="w-2.5 h-2.5" /> {prod.deliveryTimeMins} MINS
                      </span>
                    </div>

                    {/* Product Name & unit */}
                    <div>
                      <h4 className="text-[11px] font-bold text-white line-clamp-1">{prod.name}</h4>
                      <p className="text-[9px] text-slate-500">{prod.unit}</p>
                    </div>

                    {/* Eco Score badge & carbon */}
                    <div className="flex items-center gap-1">
                      <span className="px-1 py-0.2 bg-emerald-500/10 text-emerald-400 text-[8px] font-bold rounded">
                        Eco: {prod.ecoScore}
                      </span>
                      <span className="text-[8px] text-slate-400">
                        {prod.carbonEmission}kg CO2
                      </span>
                    </div>

                    {/* Price and Cart controls */}
                    <div className="flex items-center justify-between pt-1 border-t border-slate-800/40">
                      <div>
                        <span className="text-xs font-bold text-white">₹{prod.price}</span>
                        {prod.originalPrice && (
                          <span className="text-[9px] text-slate-500 line-through ml-1">₹{prod.originalPrice}</span>
                        )}
                      </div>

                      {cart.find(c => c.product.id === prod.id) ? (
                        <div className="flex items-center gap-2 bg-emerald-500 text-slate-950 rounded-lg px-1.5 py-0.5">
                          <button onClick={() => handleRemoveFromCart(prod)} className="p-0.5 hover:bg-emerald-600 rounded">
                            <Minus className="w-3 h-3" />
                          </button>
                          <span className="text-xs font-bold">{cart.find(c => c.product.id === prod.id)?.quantity}</span>
                          <button onClick={() => handleAddToCart(prod)} className="p-0.5 hover:bg-emerald-600 rounded">
                            <Plus className="w-3 h-3" />
                          </button>
                        </div>
                      ) : (
                        <button 
                          onClick={() => handleAddToCart(prod)}
                          className="px-2 py-1.5 bg-slate-850 hover:bg-emerald-500 hover:text-slate-950 font-bold rounded-lg text-[10px] transition-all"
                        >
                          ADD
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* GAMIFICATION CONTAINER */}
            <div className="bg-[#121418] border border-slate-850 rounded-2xl p-4 space-y-3 mt-4">
              <div className="flex justify-between items-center">
                <div className="flex items-center gap-1.5">
                  <Coins className="w-4 h-4 text-amber-400" />
                  <span className="text-xs font-bold text-white">Daily Mystery Wheel</span>
                </div>
                <span className="text-[9px] text-slate-500">1 spin available today</span>
              </div>

              {!spinCompleted ? (
                <div className="text-center py-2 space-y-2">
                  <div className={`w-14 h-14 rounded-full border-4 border-dashed border-amber-400 mx-auto flex items-center justify-center font-bold text-slate-400 text-xs ${spinning ? 'animate-spin border-purple-400 text-purple-400' : ''}`}>
                    {spinning ? '🎡' : 'SPIN'}
                  </div>
                  <button 
                    onClick={handleSpinWheel}
                    disabled={spinning}
                    className="px-4 py-1.5 bg-gradient-to-r from-amber-400 to-amber-500 text-slate-950 font-bold rounded-xl text-[10px] active:scale-95 transition-transform disabled:opacity-50"
                  >
                    {spinning ? 'SPINNING...' : 'TAP TO SPIN WHEEL'}
                  </button>
                </div>
              ) : (
                <div className="bg-amber-500/10 border border-amber-500/20 p-2.5 rounded-xl text-center text-xs text-amber-400 font-semibold">
                  {spinWinnerMsg}
                </div>
              )}
            </div>
          </div>
        )}

        {/* ==========================================
            AI ASSISTANT SCREEN
            ========================================== */}
        {activeScreen === 'assistant' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                <X className="w-4 h-4" />
              </button>
              <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                <Brain className="w-4 h-4 text-emerald-400" /> AI Cart Planner Assistant
              </h2>
            </div>

            <div className="bg-[#121418] border border-slate-850 rounded-2xl p-4 space-y-3.5">
              <p className="text-[11px] text-slate-400">
                Write what you need below. The LLM will automatically select appropriate matching products from our stock, calibrate nutrition targets, and build your entire shopping cart.
              </p>

              {/* Suggestions */}
              <div className="flex flex-wrap gap-1.5">
                {[
                  "Breakfast for 5 under ₹800",
                  "Low carb organic dinner set",
                  "Paneer Butter Masala recipe pack"
                ].map(s => (
                  <button 
                    key={s} 
                    onClick={() => { setAssistantPrompt(s); runAIAssistant(s); }}
                    className="text-[10px] px-2.5 py-1 bg-slate-950 hover:bg-slate-900 border border-slate-850 rounded-lg text-emerald-400"
                  >
                    {s}
                  </button>
                ))}
              </div>

              <div className="space-y-2">
                <textarea
                  rows={3}
                  value={assistantPrompt}
                  onChange={(e) => setAssistantPrompt(e.target.value)}
                  placeholder="e.g. I want to build a protein rich snack box under ₹600 for weekend gaming..."
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl p-3 text-xs text-white placeholder-slate-600 focus:outline-none focus:border-emerald-500"
                />

                <button
                  onClick={() => runAIAssistant(assistantPrompt)}
                  disabled={assistantLoading || !assistantPrompt}
                  className="w-full py-2.5 bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 text-slate-950 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 transition-all"
                >
                  {assistantLoading ? (
                    <span>PLANNING CART STATE...</span>
                  ) : (
                    <>
                      <Sparkles className="w-3.5 h-3.5" /> Build Automated Shopping Cart
                    </>
                  )}
                </button>
              </div>
            </div>

            {/* AI Response Output */}
            {assistantExplanation && (
              <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-3">
                <p className="text-[10px] uppercase font-bold tracking-wider text-emerald-400">AI Reasoning Feed</p>
                <p className="text-xs text-slate-300 leading-relaxed">{assistantExplanation}</p>
                <div className="border-t border-slate-800/60 pt-3 flex justify-between items-center text-xs">
                  <span className="text-slate-500">Status:</span>
                  <span className="text-emerald-400 font-bold">✓ Cart built successfully! Go check Cart below.</span>
                </div>
              </div>
            )}
          </div>
        )}

        {/* ==========================================
            PANTRY / FRIDGE SCANNER SCREEN
            ========================================== */}
        {activeScreen === 'scanner' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                <X className="w-4 h-4" />
              </button>
              <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                <Camera className="w-4 h-4 text-blue-400" /> Fridge Camera AI Scanner
              </h2>
            </div>

            <div className="bg-[#121418] border border-slate-850 rounded-2xl p-4 space-y-3.5">
              <p className="text-[11px] text-slate-400">
                Sync your smart fridge camera or pick one of our preloaded mock photos to scan stock. The Computer Vision AI identifies quantities and highlights low/empty categories automatically!
              </p>

              <div className="grid grid-cols-2 gap-2 text-center">
                <button 
                  onClick={() => { setPantryPreset(0); runPantryScanner(0); }}
                  className={`p-2.5 border rounded-xl text-xs font-semibold ${pantryPreset === 0 ? 'border-blue-500 bg-blue-500/10' : 'border-slate-800 bg-slate-950'}`}
                >
                  🥛 Preset: Low Eggs & Milk
                </button>
                <button 
                  onClick={() => { setPantryPreset(1); runPantryScanner(1); }}
                  className={`p-2.5 border rounded-xl text-xs font-semibold ${pantryPreset === 1 ? 'border-blue-500 bg-blue-500/10' : 'border-slate-800 bg-slate-950'}`}
                >
                  🥬 Preset: Low Veggies
                </button>
              </div>

              {/* Real Upload button */}
              <div className="pt-2 border-t border-slate-850/60 text-center">
                <button 
                  onClick={() => fileInputRef.current?.click()}
                  className="px-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs font-semibold text-blue-400 hover:border-slate-700 transition-colors"
                >
                  📷 Upload Real Fridge Photo
                </button>
                <input 
                  type="file" 
                  ref={fileInputRef} 
                  onChange={handlePhotoUpload} 
                  accept="image/*" 
                  className="hidden" 
                />
              </div>
            </div>

            {/* Results Display */}
            {scanningLoading ? (
              <div className="text-center py-8 text-xs text-slate-400">
                <Activity className="w-6 h-6 animate-spin text-blue-400 mx-auto mb-2" />
                Processing vision analysis. Detecting expiration levels...
              </div>
            ) : (
              scannedResult && (
                <div className="space-y-3 animate-fade-in">
                  <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-3">
                    <p className="text-[10px] uppercase font-bold tracking-wider text-blue-400">AI Stock Level Detection</p>
                    
                    <div className="space-y-2">
                      {scannedResult.detectedItems.map((item: any) => (
                        <div key={item.productId} className="flex justify-between items-center text-xs border-b border-slate-800/40 pb-1.5">
                          <span className="text-slate-300 font-medium">{item.name}</span>
                          <span className={`px-2 py-0.5 rounded font-bold text-[9px] ${
                            item.status === 'Full' ? 'bg-emerald-500/15 text-emerald-400' :
                            item.status === 'Low' ? 'bg-amber-500/15 text-amber-400' : 'bg-rose-500/15 text-rose-400 animate-pulse'
                          }`}>
                            {item.status}
                          </span>
                        </div>
                      ))}
                    </div>

                    <div className="pt-2 border-t border-slate-800/60">
                      <p className="text-[10px] text-slate-500 uppercase font-bold mb-1">Recipe Suggestion</p>
                      <p className="text-xs text-slate-300 leading-relaxed">{scannedResult.recipeSuggestion}</p>
                    </div>
                  </div>

                  {/* Replenish button */}
                  <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-3">
                    <p className="text-[10px] uppercase font-bold tracking-wider text-emerald-400">Recommended Replenishment Items</p>
                    
                    <button 
                      onClick={() => {
                        scannedResult.suggestedAdditions.forEach((aiItem: any) => {
                          const match = products.find(p => p.id === aiItem.productId);
                          if (match) {
                            handleAddToCart(match, "Auto Replenish");
                          }
                        });
                        alert("Replenished missing stock! All low items added to your cart.");
                      }}
                      className="w-full py-2 bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 transition-all"
                    >
                      ✓ One-click Replenish Missing Stock
                    </button>
                  </div>
                </div>
              )
            )}
          </div>
        )}

        {/* ==========================================
            MEAL PLANNER SCREEN
            ========================================== */}
        {activeScreen === 'planner' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                <X className="w-4 h-4" />
              </button>
              <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                <Utensils className="w-4 h-4 text-purple-400" /> Smart Meal Planner AI
              </h2>
            </div>

            <div className="bg-[#121418] border border-slate-850 rounded-2xl p-4 space-y-3">
              <p className="text-[11px] text-slate-400">
                Configure your diet target parameters below. The nutritionist LLM builds customized breakfast, lunch and dinner meals using real products from our database.
              </p>

              <div className="grid grid-cols-2 gap-2 text-xs">
                <div>
                  <label className="block text-slate-500 text-[9px] uppercase font-bold mb-1">Diet Preference</label>
                  <select 
                    value={diet} 
                    onChange={(e) => setDiet(e.target.value)}
                    className="w-full bg-slate-950 border border-slate-800 rounded p-1 text-white"
                  >
                    <option value="Veg">Vegetarian</option>
                    <option value="Non-Veg">High Protein (Eggs)</option>
                    <option value="Keto">Low Carb (Keto)</option>
                    <option value="Organic">100% Certified Organic</option>
                  </select>
                </div>

                <div>
                  <label className="block text-slate-500 text-[9px] uppercase font-bold mb-1">Max Budget limit</label>
                  <select 
                    value={budget} 
                    onChange={(e) => setBudget(Number(e.target.value))}
                    className="w-full bg-slate-950 border border-slate-800 rounded p-1 text-white"
                  >
                    <option value={400}>Under ₹400</option>
                    <option value={800}>Under ₹800</option>
                    <option value={1500}>Under ₹1500</option>
                  </select>
                </div>
              </div>

              <button
                onClick={runMealPlanner}
                disabled={mealPlannerLoading}
                className="w-full py-2 bg-purple-500 hover:bg-purple-600 disabled:opacity-50 text-slate-950 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 transition-all"
              >
                {mealPlannerLoading ? 'CALIBRATING DIET MATRIX...' : 'Generate 1-Day Custom Meal Plan'}
              </button>
            </div>

            {/* Result */}
            {mealPlannerResult && (
              <div className="space-y-3">
                {['breakfast', 'lunch', 'dinner'].map((mealKey) => {
                  const meal = (mealPlannerResult as any)[mealKey];
                  return (
                    <div key={mealKey} className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-2">
                      <div className="flex justify-between items-center">
                        <span className="text-[10px] uppercase font-bold tracking-wider text-purple-400">
                          {mealKey}
                        </span>
                        <span className="text-[10px] text-slate-500">Balanced Nutrition</span>
                      </div>
                      <h4 className="text-xs font-bold text-white">{meal.name}</h4>
                      <p className="text-[11px] text-slate-300 leading-relaxed">{meal.explanation}</p>
                      
                      {/* Ingredient item button */}
                      <div className="pt-2">
                        <button 
                          onClick={() => {
                            meal.items.forEach((aiItem: any) => {
                              const match = products.find(p => p.id === aiItem.productId);
                              if (match) {
                                handleAddToCart(match, `Meal: ${mealKey}`);
                              }
                            });
                            alert(`Added all ${mealKey} ingredients to cart!`);
                          }}
                          className="px-3 py-1 bg-slate-950 border border-purple-500/20 text-purple-400 font-bold rounded-lg text-[9px] hover:bg-purple-500/10 transition-colors"
                        >
                          + Add Ingredients to Cart
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}

        {/* ==========================================
            AI RECIPE CARTS
            ========================================== */}
        {activeScreen === 'recipes' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                <X className="w-4 h-4" />
              </button>
              <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                <Sparkles className="w-4 h-4 text-amber-400" /> AI Recipe Cart Builder
              </h2>
            </div>

            <div className="bg-[#121418] border border-slate-850 rounded-2xl p-4 space-y-3">
              <p className="text-[11px] text-slate-400">
                Search any Indian or global recipe. FlashCart automatically reads preparation steps and parses all required ingredients directly into product catalog additions!
              </p>

              <div className="flex gap-2">
                <input 
                  type="text" 
                  value={recipeSearch}
                  onChange={(e) => setRecipeSearch(e.target.value)}
                  placeholder="e.g. Sourdough Egg Scramble, Paneer Masala..."
                  className="flex-1 bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-xs text-white focus:outline-none focus:border-amber-500"
                />
                <button
                  onClick={() => runRecipeMode(recipeSearch)}
                  disabled={recipeLoading || !recipeSearch}
                  className="px-4 py-2 bg-amber-500 hover:bg-amber-600 disabled:opacity-50 text-slate-950 font-bold rounded-xl text-xs"
                >
                  {recipeLoading ? 'ANALYZING...' : 'SEARCH'}
                </button>
              </div>
            </div>

            {recipeResult && (
              <div className="space-y-3">
                <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-2">
                  <div className="flex justify-between items-center">
                    <h3 className="text-xs font-bold text-white">{recipeResult.title}</h3>
                    <span className="text-[9px] text-slate-400">Prep: {recipeResult.prepTime} | Cook: {recipeResult.cookTime}</span>
                  </div>
                  <p className="text-[11px] text-slate-400 mt-1"><strong>Chef's Secret Tip:</strong> {recipeResult.chefTip}</p>
                </div>

                {/* Steps */}
                <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-2">
                  <p className="text-[10px] uppercase font-bold tracking-wider text-amber-400">Preparation Steps</p>
                  <ol className="list-decimal pl-4 space-y-1.5 text-[11px] text-slate-300">
                    {recipeResult.steps.map((st: string, idx: number) => (
                      <li key={idx}>{st}</li>
                    ))}
                  </ol>
                </div>

                {/* Buy all */}
                <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-3 text-center">
                  <p className="text-[10px] text-slate-400 font-bold">Matched catalog ingredients are ready to check out.</p>
                  <button 
                    onClick={() => {
                      recipeResult.itemsToBuy.forEach((aiItem: any) => {
                        const match = products.find(p => p.id === aiItem.productId);
                        if (match) {
                          handleAddToCart(match, "Recipe Mode");
                        }
                      });
                      alert("Recipe ingredients added to cart!");
                    }}
                    className="w-full py-2 bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold rounded-xl text-xs"
                  >
                    ✓ Add All Recipe Ingredients to Cart
                  </button>
                </div>
              </div>
            )}
          </div>
        )}

        {/* ==========================================
            WISHLIST SCREEN
            ========================================== */}
        {activeScreen === 'wishlist' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4" />
                </button>
                <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                  <Heart className="w-4 h-4 text-rose-500 fill-rose-500" /> My Saved Wishlist ({wishlist.length})
                </h2>
              </div>
            </div>

            {wishlist.length > 0 ? (
              <div className="grid grid-cols-2 gap-3">
                {products.filter(p => wishlist.includes(p.id)).map(prod => (
                  <div key={prod.id} className="bg-slate-900/60 border border-slate-800 rounded-2xl p-3 flex flex-col justify-between space-y-2 relative">
                    <button 
                      onClick={() => handleToggleWishlist(prod.id)} 
                      className="absolute top-2 right-2 p-1 bg-slate-950/80 rounded-full text-rose-500 hover:text-slate-400"
                    >
                      <X className="w-3.5 h-3.5" />
                    </button>
                    
                    <img src={prod.image} className="w-full aspect-square rounded-xl object-cover bg-slate-950" />
                    <div>
                      <p className="font-bold text-white text-xs line-clamp-1">{prod.name}</p>
                      <p className="text-[10px] text-slate-500">₹{prod.price} • {prod.unit}</p>
                    </div>

                    <button 
                      onClick={() => {
                        handleAddToCart(prod);
                        handleToggleWishlist(prod.id);
                      }}
                      className="w-full py-1.5 bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold rounded-xl text-[10px] flex items-center justify-center gap-1"
                    >
                      <Plus className="w-3 h-3" /> Move to Cart
                    </button>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-20 text-slate-500 text-xs space-y-2">
                <Heart className="w-10 h-10 mx-auto text-slate-700" />
                <p className="font-semibold text-slate-400">Your wishlist is empty</p>
                <p className="text-[10px] text-slate-600">Tap the heart icon on any product to save it here for later!</p>
              </div>
            )}
          </div>
        )}

        {/* ==========================================
            CART VIEW SCREEN
            ========================================== */}
        {activeScreen === 'cart' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                <X className="w-4 h-4" />
              </button>
              <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                <ShoppingBag className="w-4 h-4 text-emerald-400" /> Collaborative Shopping Engine
              </h2>
            </div>

            {/* Collaborative toggler */}
            <div className="bg-[#121418] border border-slate-850 p-3 rounded-2xl flex justify-between items-center text-xs">
              <div>
                <p className="font-semibold text-white">Family Collaboration Active</p>
                <p className="text-[9px] text-slate-500">Arav and Nisha are editing simultaneously</p>
              </div>
              <button 
                onClick={() => setCollaborativeCartActive(!collaborativeCartActive)}
                className={`px-3 py-1 rounded-full font-bold text-[10px] border transition-all ${
                  collaborativeCartActive 
                    ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' 
                    : 'bg-slate-800 text-slate-400 border-slate-700/50'
                }`}
              >
                {collaborativeCartActive ? 'SYNCED' : 'OFFLINE'}
              </button>
            </div>

            {/* Cart list */}
            {activeCartItems.length > 0 || savedForLaterItems.length > 0 ? (
              <div className="space-y-4">
                
                {/* Active Items */}
                {activeCartItems.length > 0 && (
                  <div className="space-y-2">
                    <p className="text-[10px] uppercase font-bold text-slate-500 tracking-wider">Cart Items ({activeCartItems.length})</p>
                    {activeCartItems.map(item => (
                      <div key={item.product.id} className="bg-slate-900/60 border border-slate-850 rounded-xl p-3 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2.5 truncate max-w-[180px]">
                          <img src={item.product.image} className="w-8 h-8 rounded-lg object-cover" />
                          <div>
                            <p className="font-bold text-white truncate text-[11px]">{item.product.name}</p>
                            <p className="text-[9px] text-slate-500">₹{item.product.price} • {item.product.unit}</p>
                            {collaborativeCartActive && item.addedBy && (
                              <span className="inline-block mt-0.5 px-1 py-0.2 bg-purple-500/10 text-purple-400 rounded text-[8px]">
                                Added by {item.addedBy}
                              </span>
                            )}
                          </div>
                        </div>

                        <div className="flex items-center gap-2">
                          <button 
                            onClick={() => handleToggleSaveForLater(item.product)} 
                            className="p-1 hover:bg-slate-800 rounded text-slate-400 hover:text-amber-400 transition-colors"
                            title="Save for Later"
                          >
                            <Bookmark className="w-3.5 h-3.5" />
                          </button>
                          
                          <div className="flex items-center gap-1 bg-slate-950 border border-slate-800 rounded px-1">
                            <button onClick={() => handleRemoveFromCart(item.product)} className="text-slate-400 p-0.5">
                              <Minus className="w-2.5 h-2.5" />
                            </button>
                            <span className="font-bold font-mono text-white text-[11px]">{item.quantity}</span>
                            <button onClick={() => handleAddToCart(item.product)} className="text-slate-400 p-0.5">
                              <Plus className="w-2.5 h-2.5" />
                            </button>
                          </div>
                          <span className="font-bold text-white font-mono w-10 text-right">₹{item.product.price * item.quantity}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                {/* Save For Later Section */}
                {savedForLaterItems.length > 0 && (
                  <div className="bg-slate-900/30 border border-slate-800/80 rounded-2xl p-3 space-y-2">
                    <p className="text-[10px] uppercase font-bold text-amber-400 flex items-center gap-1">
                      <Bookmark className="w-3 h-3" /> Saved For Later ({savedForLaterItems.length})
                    </p>
                    <div className="space-y-1.5">
                      {savedForLaterItems.map(item => (
                        <div key={item.product.id} className="flex justify-between items-center text-xs p-2 bg-slate-950/60 rounded-xl">
                          <div className="flex items-center gap-2">
                            <img src={item.product.image} className="w-6 h-6 rounded object-cover" />
                            <span className="font-semibold text-slate-300 text-[11px]">{item.product.name}</span>
                          </div>
                          <button 
                            onClick={() => handleToggleSaveForLater(item.product)}
                            className="px-2.5 py-1 bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 font-bold rounded-lg text-[9px] hover:bg-emerald-500/20"
                          >
                            Move to Cart
                          </button>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Coupons & Promo Codes Engine */}
                <div className="bg-slate-900/60 border border-slate-850 rounded-2xl p-3.5 space-y-3">
                  <p className="text-[10px] uppercase font-bold text-purple-400 tracking-wider">Coupons & Promo Offers</p>
                  
                  {appliedCoupon ? (
                    <div className="flex items-center justify-between p-2.5 bg-purple-500/10 border border-purple-500/30 rounded-xl text-xs">
                      <div className="flex items-center gap-2">
                        <Check className="w-4 h-4 text-purple-400" />
                        <div>
                          <p className="font-bold text-white">{appliedCoupon} APPLIED</p>
                          <p className="text-[9px] text-purple-300">Saved ₹{couponDiscount} on this checkout</p>
                        </div>
                      </div>
                      <button 
                        onClick={handleRemoveCoupon} 
                        className="text-[10px] font-bold text-rose-400 hover:underline"
                      >
                        Remove
                      </button>
                    </div>
                  ) : (
                    <div className="flex gap-2">
                      <input 
                        type="text" 
                        value={couponCodeInput}
                        onChange={(e) => setCouponCodeInput(e.target.value.toUpperCase())}
                        placeholder="ENTER COUPON CODE"
                        className="flex-1 bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs font-mono uppercase text-white placeholder-slate-600 focus:outline-none focus:border-purple-500"
                      />
                      <button 
                        onClick={() => handleApplyCoupon()}
                        disabled={couponLoading || !couponCodeInput}
                        className="px-4 py-2 bg-purple-600 hover:bg-purple-500 text-white font-bold rounded-xl text-xs disabled:opacity-50"
                      >
                        {couponLoading ? '...' : 'APPLY'}
                      </button>
                    </div>
                  )}

                  {couponMessage && (
                    <p className={`text-[10px] font-semibold ${couponMessage.type === 'success' ? 'text-emerald-400' : 'text-rose-400'}`}>
                      {couponMessage.text}
                    </p>
                  )}

                  {/* Available Coupons Pills */}
                  {availableCoupons.length > 0 && !appliedCoupon && (
                    <div className="pt-1 border-t border-slate-800/40">
                      <p className="text-[9px] text-slate-500 mb-1.5 font-bold uppercase">Available Promo Codes</p>
                      <div className="flex flex-wrap gap-1.5">
                        {availableCoupons.slice(0, 3).map((cp: any) => (
                          <button
                            key={cp.id || cp.code}
                            onClick={() => handleApplyCoupon(cp.code)}
                            className="px-2.5 py-1 bg-slate-950 hover:bg-slate-800 border border-purple-500/20 rounded-lg text-[9px] font-mono text-purple-300 font-bold"
                          >
                            🏷️ {cp.code} (Get {cp.discountValue || cp.value}{cp.type === 'PERCENTAGE' || cp.type === 'percentage' ? '%' : '₹'} OFF)
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                </div>

                {/* Smart Cart Score Metrics */}
                <div className="bg-slate-900/40 border border-slate-800 rounded-2xl p-4 space-y-3 text-xs">
                  <p className="text-[10px] uppercase font-bold tracking-wider text-purple-400">Smart Cart Index Scores</p>
                  
                  <div className="grid grid-cols-2 gap-3.5">
                    <div className="bg-slate-950/40 border border-slate-850 p-2.5 rounded-xl">
                      <p className="text-slate-500 text-[10px]">Healthy Score</p>
                      <div className="flex items-baseline gap-1 mt-0.5">
                        <span className="text-sm font-bold text-emerald-400">{healthAverage}%</span>
                        <span className="text-[8px] text-slate-500">Perfect Green</span>
                      </div>
                    </div>

                    <div className="bg-slate-950/40 border border-slate-850 p-2.5 rounded-xl">
                      <p className="text-slate-500 text-[10px]">Carbon Saved</p>
                      <div className="flex items-baseline gap-1 mt-0.5">
                        <span className="text-sm font-bold text-emerald-400">{ecoSavingsKg.toFixed(2)}kg</span>
                        <span className="text-[8px] text-slate-500">CO2 Equivalent</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Order Customizations (Notes, Scheduled, Gift) */}
                <div className="bg-slate-900/40 border border-slate-800 rounded-2xl p-3.5 space-y-3 text-xs">
                  <p className="text-[10px] uppercase font-bold tracking-wider text-purple-400 flex items-center gap-1.5">
                    <SlidersHorizontal className="w-3.5 h-3.5" /> Express Order Preferences
                  </p>

                  <div className="space-y-2">
                    <div>
                      <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Delivery Instructions / Notes</label>
                      <input 
                        type="text" 
                        value={orderNotesInput}
                        onChange={(e) => setOrderNotesInput(e.target.value)}
                        placeholder="e.g. Leave package at security gate / ring doorbell twice"
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white placeholder-slate-600 focus:outline-none focus:border-purple-500"
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Fulfillment Schedule</label>
                        <select 
                          value={scheduledDeliveryTime}
                          onChange={(e) => setScheduledDeliveryTime(e.target.value)}
                          className="w-full bg-slate-950 border border-slate-800 rounded-xl px-2.5 py-2 text-xs text-white focus:outline-none focus:border-purple-500"
                        >
                          <option value="">⚡ Express (9 Mins)</option>
                          <option value="Today Evening (6 - 7 PM)">Today Evening (6 - 7 PM)</option>
                          <option value="Tomorrow Morning (8 - 9 AM)">Tomorrow Morning (8 - 9 AM)</option>
                        </select>
                      </div>

                      <div className="flex flex-col justify-end">
                        <label className="flex items-center gap-2 bg-slate-950 border border-slate-800 rounded-xl p-2 cursor-pointer">
                          <input 
                            type="checkbox" 
                            checked={isGiftOrder} 
                            onChange={(e) => setIsGiftOrder(e.target.checked)}
                            className="rounded border-slate-700 text-purple-600 focus:ring-0"
                          />
                          <span className="text-[10px] font-bold text-white flex items-center gap-1">
                            <Gift className="w-3 h-3 text-pink-400" /> Gift Wrap
                          </span>
                        </label>
                      </div>
                    </div>

                    {isGiftOrder && (
                      <input 
                        type="text" 
                        value={giftMessageInput}
                        onChange={(e) => setGiftMessageInput(e.target.value)}
                        placeholder="Enter gift message to print on note..."
                        className="w-full bg-slate-950 border border-pink-500/30 rounded-xl px-3 py-2 text-xs text-pink-300 placeholder-slate-600 focus:outline-none focus:border-pink-500"
                      />
                    )}
                  </div>
                </div>

                {/* Module 6: Payment Method Selection Engine */}
                <div className="bg-slate-900/40 border border-slate-800 rounded-2xl p-3.5 space-y-2.5 text-xs">
                  <div className="flex justify-between items-center">
                    <p className="text-[10px] uppercase font-bold tracking-wider text-emerald-400 flex items-center gap-1.5">
                      <CreditCard className="w-3.5 h-3.5" /> Payment Method Infrastructure
                    </p>
                    <span className="text-[9px] text-slate-500 font-mono">100% Encrypted</span>
                  </div>

                  <div className="grid grid-cols-2 gap-2">
                    {[
                      { id: 'Shared Wallet (Family)', label: `Shared Wallet (₹${Math.round(walletBalance)})`, icon: '💳' },
                      { id: 'UPI (GPay/PhonePe)', label: 'UPI (GPay / PhonePe)', icon: '📱' },
                      { id: 'Credit/Debit Card', label: 'Credit / Debit Card', icon: '💳' },
                      { id: 'Net Banking', label: 'Net Banking', icon: '🏦' },
                      { id: 'Cash On Delivery', label: 'Cash On Delivery (COD)', icon: '💵' },
                      { id: 'FlashCart Gift Card', label: 'FlashCart Gift Card', icon: '🎁' }
                    ].map(pm => (
                      <button
                        key={pm.id}
                        onClick={() => setSelectedPaymentMethod(pm.id)}
                        className={`p-2.5 rounded-xl border text-left transition-all flex items-center gap-2 ${
                          selectedPaymentMethod === pm.id
                            ? 'bg-emerald-500/10 border-emerald-500 text-white font-bold'
                            : 'bg-slate-950/60 border-slate-800 text-slate-400 hover:text-white'
                        }`}
                      >
                        <span className="text-sm">{pm.icon}</span>
                        <span className="text-[10px] leading-tight font-semibold truncate">{pm.label}</span>
                      </button>
                    ))}
                  </div>

                  {selectedPaymentMethod === 'FlashCart Gift Card' && (
                    <input 
                      type="text" 
                      value={giftCardCodeInput}
                      onChange={(e) => setGiftCardCodeInput(e.target.value.toUpperCase())}
                      placeholder="ENTER GIFT CARD CODE (e.g. FLASHGIFT500)"
                      className="w-full bg-slate-950 border border-emerald-500/30 rounded-xl px-3 py-2 text-xs font-mono uppercase text-emerald-300 placeholder-slate-600 focus:outline-none focus:border-emerald-500 mt-2"
                    />
                  )}
                </div>

                {/* Bill Breakdown */}
                <div className="bg-[#121418] rounded-2xl p-4 space-y-2.5 text-xs">
                  <div className="flex justify-between items-center text-slate-400">
                    <span>Items Subtotal</span>
                    <span className="font-mono">₹{cartSubtotal}</span>
                  </div>
                  {couponDiscount > 0 && (
                    <div className="flex justify-between items-center text-purple-400">
                      <span>Coupon Discount ({appliedCoupon})</span>
                      <span className="font-mono">-₹{couponDiscount}</span>
                    </div>
                  )}
                  <div className="flex justify-between items-center text-slate-400">
                    <span>Carbon Offset Green Fee</span>
                    <span className="font-mono">₹{carbonOffsetFee}</span>
                  </div>
                  <div className="flex justify-between items-center text-slate-400">
                    <span>Delivery Fee</span>
                    <span className="font-mono">{deliveryFee === 0 ? 'FREE' : `₹${deliveryFee}`}</span>
                  </div>
                  <div className="border-t border-slate-800 pt-2 flex justify-between items-center text-sm font-bold text-white">
                    <span>Total To Pay</span>
                    <span className="font-mono text-emerald-400">₹{cartTotal}</span>
                  </div>
                </div>

                {/* Shared wallet kids limit */}
                <div className="bg-amber-500/5 border border-amber-500/10 p-3 rounded-xl text-xs text-amber-400 space-y-1">
                  <p className="font-semibold">Kids Allowance Warning</p>
                  <p className="text-[10px] text-slate-400">Using the shared family wallet. Your spouse Nisha will be notified of this charge instantly.</p>
                </div>

                {/* Checkout CTA */}
                <button
                  onClick={async () => {
                    // Stock Validation Check
                    try {
                      const res = await fetch('/api/checkout/validate', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ items: activeCartItems.map(i => ({ id: i.product.id, quantity: i.quantity })) })
                      });
                      if (res.ok) {
                        const data = await res.json();
                        if (data.isValid === false || data.valid === false) {
                          alert(data.message || data.reason || "Some items in your cart exceed available stock. Please adjust quantities.");
                          return;
                        }
                      }
                    } catch (e) {
                      console.warn("Stock validation check fallback:", e);
                    }
                    handlePlaceOrder();
                  }}
                  disabled={activeCartItems.length === 0}
                  className="w-full py-3 bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 text-slate-950 font-bold rounded-2xl text-xs flex items-center justify-center gap-1.5 transition-all shadow-lg active:scale-95"
                >
                  <Zap className="w-4 h-4" /> Place Express Delivery Order (₹{cartTotal})
                </button>
              </div>
            ) : (
              <div className="text-center py-20 text-slate-500 text-xs">
                <ShoppingBag className="w-10 h-10 mx-auto mb-3 text-slate-700 animate-bounce" />
                <p>Your FlashCart collaborative shopping cart is empty.</p>
                <p className="text-[10px] mt-1 text-slate-600">Explore items, try AI Search, or ask the AI assistant above!</p>
              </div>
            )}
          </div>
        )}

        {/* ==========================================
            ORDERS HISTORY & MANAGEMENT SCREEN
            ========================================== */}
        {activeScreen === 'orders' && (
          <div className="p-4 space-y-4 font-sans">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4" />
                </button>
                <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                  <Package className="w-4 h-4 text-emerald-400" /> Order History & Lifecycle
                </h2>
              </div>
              <button 
                onClick={fetchOrdersHistory} 
                className="p-1.5 bg-slate-900 border border-slate-800 rounded-xl text-slate-400 hover:text-emerald-400 active:scale-95 transition-all"
                title="Refresh Orders"
              >
                <RefreshCw className="w-3.5 h-3.5" />
              </button>
            </div>

            {/* Filter Pills */}
            <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none text-xs">
              {(['All', 'Active', 'Delivered', 'Cancelled'] as const).map(flt => (
                <button
                  key={flt}
                  onClick={() => setOrdersFilter(flt)}
                  className={`px-3 py-1.5 rounded-full font-semibold transition-all shrink-0 ${
                    ordersFilter === flt
                      ? 'bg-emerald-500 text-slate-950 font-bold'
                      : 'bg-slate-900 text-slate-400 hover:text-white border border-slate-800/80'
                  }`}
                >
                  {flt}
                </button>
              ))}
            </div>

            {/* Active Shipment Quick Banner */}
            {activeOrder && (
              <div className="bg-gradient-to-r from-emerald-950/60 to-purple-950/60 border border-emerald-500/30 rounded-2xl p-4 space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="relative flex h-2.5 w-2.5">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
                    </span>
                    <p className="text-xs font-bold text-emerald-400">ACTIVE EXPRESS DISPATCH</p>
                  </div>
                  <span className="text-[10px] font-mono text-slate-400">ID: {activeOrder.id}</span>
                </div>

                <div className="flex justify-between items-center text-xs">
                  <div>
                    <p className="font-bold text-white">Est. Delivery: {activeOrder.estimatedDeliveryTime || '9 Mins'}</p>
                    <p className="text-[10px] text-slate-400">Status: {activeOrder.status}</p>
                  </div>
                  <div className="flex gap-2">
                    <button 
                      onClick={() => setActiveScreen('tracking')}
                      className="px-3 py-1.5 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold rounded-xl text-[11px] flex items-center gap-1 active:scale-95 transition-transform"
                    >
                      <MapPin className="w-3 h-3" /> Track Map
                    </button>
                    <button 
                      onClick={() => handleCancelOrder(activeOrder.id, 'User requested cancellation in active banner')}
                      className="px-2.5 py-1.5 bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/30 font-bold rounded-xl text-[11px] active:scale-95"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* Orders History List */}
            <div className="space-y-3">
              {ordersHistory
                .filter(o => {
                  if (ordersFilter === 'All') return true;
                  if (ordersFilter === 'Active') return !['DELIVERED', 'CANCELLED', 'RETURNED'].includes(o.status.toUpperCase());
                  if (ordersFilter === 'Delivered') return o.status.toUpperCase() === 'DELIVERED';
                  if (ordersFilter === 'Cancelled') return o.status.toUpperCase() === 'CANCELLED';
                  return true;
                })
                .map(o => {
                  const statusUpper = o.status.toUpperCase();
                  const isDelivered = statusUpper === 'DELIVERED';
                  const isCancelled = statusUpper === 'CANCELLED';
                  const isCanCancel = ['PLACED', 'CONFIRMED', 'PICKING'].includes(statusUpper);

                  return (
                    <div key={o.id} className="bg-[#121418] border border-slate-800 rounded-2xl p-4 space-y-3">
                      {/* Header */}
                      <div className="flex justify-between items-start border-b border-slate-800/80 pb-2.5">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-bold text-white text-xs">{o.id}</span>
                            <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full uppercase border ${
                              isDelivered ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' :
                              isCancelled ? 'bg-rose-500/10 text-rose-400 border-rose-500/20' :
                              'bg-amber-500/10 text-amber-400 border-amber-500/20'
                            }`}>
                              {o.status}
                            </span>
                          </div>
                          <p className="text-[10px] text-slate-500 mt-0.5">
                            {new Date(o.createdAt).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })}
                          </p>
                        </div>
                        <div className="text-right">
                          <p className="text-xs font-bold text-emerald-400 font-mono">₹{o.total}</p>
                          <p className="text-[9px] text-slate-500">{o.paymentMethod}</p>
                        </div>
                      </div>

                      {/* Items Preview */}
                      <div className="space-y-1.5 text-xs">
                        {o.items.map((it: any, idx: number) => (
                          <div key={idx} className="flex justify-between items-center text-slate-300">
                            <span className="truncate max-w-[200px]">
                              {it.quantity}x {it.product.name}
                            </span>
                            <span className="font-mono text-slate-400">₹{it.quantity * it.product.price}</span>
                          </div>
                        ))}
                      </div>

                      {/* Notes / Gift if present */}
                      {(o.notes || o.isGift) && (
                        <div className="bg-slate-950/60 p-2 rounded-xl text-[10px] text-slate-400 space-y-0.5">
                          {o.notes && <p>📝 <span className="font-semibold text-slate-300">Note:</span> {o.notes}</p>}
                          {o.isGift && <p>🎁 <span className="font-semibold text-pink-400">Gift Order:</span> {o.giftMessage || 'With compliments'}</p>}
                        </div>
                      )}

                      {/* Action Buttons */}
                      <div className="flex flex-wrap gap-2 pt-1 border-t border-slate-800/60 text-[11px]">
                        <button
                          onClick={() => handleFetchInvoice(o.id)}
                          className="px-2.5 py-1 bg-slate-900 hover:bg-slate-800 text-slate-300 border border-slate-800 rounded-xl flex items-center gap-1 active:scale-95"
                        >
                          <Receipt className="w-3 h-3 text-purple-400" /> Invoice
                        </button>

                        <button
                          onClick={() => handleFetchTimeline(o.id)}
                          className="px-2.5 py-1 bg-slate-900 hover:bg-slate-800 text-slate-300 border border-slate-800 rounded-xl flex items-center gap-1 active:scale-95"
                        >
                          <Clock className="w-3 h-3 text-emerald-400" /> Timeline
                        </button>

                        <button
                          onClick={() => handleRepeatOrder(o.id)}
                          className="px-2.5 py-1 bg-purple-600/10 hover:bg-purple-600/20 text-purple-300 border border-purple-500/30 font-bold rounded-xl flex items-center gap-1 active:scale-95"
                        >
                          <RotateCcw className="w-3 h-3 text-purple-400" /> Repeat
                        </button>

                        {isCanCancel && (
                          <button
                            onClick={() => setCancellingOrderId(o.id)}
                            className="px-2 py-1 bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/30 font-bold rounded-xl ml-auto active:scale-95"
                          >
                            Cancel
                          </button>
                        )}
                      </div>
                    </div>
                  );
                })}

              {ordersHistory.length === 0 && (
                <div className="text-center py-16 text-slate-500 text-xs">
                  <Package className="w-10 h-10 mx-auto mb-2 text-slate-700 animate-bounce" />
                  <p>No orders placed yet.</p>
                  <p className="text-[10px] mt-1 text-slate-600">Start shopping and place your first express delivery order!</p>
                </div>
              )}
            </div>
          </div>
        )}

        {/* ==========================================
            MODULE 6: PAYMENTS & WALLET HUB SCREEN
            ========================================== */}
        {activeScreen === 'wallet' && (
          <div className="p-4 space-y-4 font-sans">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4" />
                </button>
                <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                  <Wallet className="w-4 h-4 text-emerald-400" /> Payments & Family Wallet
                </h2>
              </div>
              <button 
                onClick={fetchWalletData} 
                className="p-1.5 bg-slate-900 border border-slate-800 rounded-xl text-slate-400 hover:text-emerald-400 active:scale-95 transition-all"
                title="Refresh Balance & Ledger"
              >
                <RefreshCw className="w-3.5 h-3.5" />
              </button>
            </div>

            {/* Wallet Balance Hero Card */}
            <div className="bg-gradient-to-br from-emerald-950 via-slate-900 to-purple-950 border border-emerald-500/30 rounded-3xl p-5 shadow-2xl relative overflow-hidden space-y-4">
              <div className="flex justify-between items-start">
                <div>
                  <p className="text-[10px] uppercase font-bold text-emerald-400 tracking-widest flex items-center gap-1">
                    <ShieldCheck className="w-3 h-3 text-emerald-400" /> Double-Entry Ledger Active
                  </p>
                  <h3 className="text-2xl font-black text-white font-mono mt-1">₹{walletBalance.toFixed(2)}</h3>
                  <p className="text-[10px] text-slate-400 mt-0.5">FlashCart Shared Family Cash Balance</p>
                </div>
                <div className="bg-emerald-500/10 border border-emerald-500/20 px-2.5 py-1 rounded-full text-right">
                  <p className="text-[9px] text-emerald-400 font-bold uppercase">Loyalty Points</p>
                  <p className="text-xs font-bold text-amber-400 font-mono">{rewardPoints} Pts</p>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="grid grid-cols-3 gap-2 pt-1">
                <button 
                  onClick={() => setTopupModalOpen(true)}
                  className="py-2 px-3 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 active:scale-95 transition-all shadow-md"
                >
                  <Plus className="w-3.5 h-3.5" /> Refill
                </button>
                <button 
                  onClick={() => setWithdrawModalOpen(true)}
                  className="py-2 px-3 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 active:scale-95 transition-all"
                >
                  <ArrowUpRight className="w-3.5 h-3.5 text-purple-400" /> Withdraw
                </button>
                <button 
                  onClick={() => setRewardModalOpen(true)}
                  className="py-2 px-3 bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 border border-amber-500/30 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 active:scale-95 transition-all"
                >
                  <Coins className="w-3.5 h-3.5 text-amber-400" /> Redeem
                </button>
              </div>
            </div>

            {/* Quick Benefits / Cashback Pills */}
            <div className="grid grid-cols-2 gap-2 text-xs">
              <div className="bg-[#121418] border border-slate-800 p-3 rounded-2xl flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-purple-500/10 flex items-center justify-center text-purple-400 shrink-0">
                  <Zap className="w-4 h-4" />
                </div>
                <div>
                  <p className="font-bold text-white text-[11px]">Auto Cashback</p>
                  <p className="text-[9px] text-slate-400">2% back on UPI & Wallet</p>
                </div>
              </div>
              <div className="bg-[#121418] border border-slate-800 p-3 rounded-2xl flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-amber-500/10 flex items-center justify-center text-amber-400 shrink-0">
                  <Coins className="w-4 h-4" />
                </div>
                <div>
                  <p className="font-bold text-white text-[11px]">Reward Value</p>
                  <p className="text-[9px] text-slate-400">10 Points = ₹1 Cash</p>
                </div>
              </div>
            </div>

            {/* Double-Entry Ledger History */}
            <div className="space-y-2">
              <div className="flex justify-between items-center pt-2">
                <h3 className="text-xs font-bold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
                  <Receipt className="w-3.5 h-3.5 text-emerald-400" /> Double-Entry Audit Ledger
                </h3>
                <span className="text-[10px] font-mono text-slate-500">{walletLedger.length} Records</span>
              </div>

              <div className="space-y-2 max-h-[320px] overflow-y-auto pr-1">
                {walletLedger.map(entry => (
                  <div key={entry.id} className="bg-[#121418] border border-slate-800/80 rounded-2xl p-3 flex justify-between items-center text-xs">
                    <div className="flex items-center gap-2.5">
                      <div className={`w-7 h-7 rounded-full flex items-center justify-center shrink-0 ${
                        entry.type === 'CREDIT' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                      }`}>
                        {entry.type === 'CREDIT' ? <ArrowDownLeft className="w-3.5 h-3.5" /> : <ArrowUpRight className="w-3.5 h-3.5" />}
                      </div>
                      <div>
                        <p className="font-bold text-white text-[11px]">{entry.description || entry.category}</p>
                        <p className="text-[9px] text-slate-500 font-mono">
                          Ref: {entry.referenceId || entry.id} • {new Date(entry.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </p>
                      </div>
                    </div>

                    <div className="text-right">
                      <p className={`font-mono font-bold text-xs ${entry.type === 'CREDIT' ? 'text-emerald-400' : 'text-slate-300'}`}>
                        {entry.type === 'CREDIT' ? '+' : '-'}₹{entry.amount}
                      </p>
                      <p className="text-[9px] text-slate-500 font-mono">Bal: ₹{entry.balanceAfter}</p>
                    </div>
                  </div>
                ))}

                {walletLedger.length === 0 && (
                  <div className="text-center py-8 text-slate-500 text-xs bg-[#121418] border border-slate-800 rounded-2xl">
                    <Wallet className="w-8 h-8 mx-auto mb-2 text-slate-700" />
                    <p>No wallet ledger entries yet.</p>
                  </div>
                )}
              </div>
            </div>

            {/* Payment Gateway Transactions */}
            <div className="space-y-2 pt-2">
              <div className="flex justify-between items-center">
                <h3 className="text-xs font-bold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
                  <CreditCard className="w-3.5 h-3.5 text-purple-400" /> Payment Gateway History
                </h3>
                <span className="text-[10px] font-mono text-slate-500">{paymentHistory.length} Intents</span>
              </div>

              <div className="space-y-2">
                {paymentHistory.map(tx => (
                  <div key={tx.id} className="bg-[#121418] border border-slate-800/80 rounded-2xl p-3 flex justify-between items-center text-xs">
                    <div>
                      <div className="flex items-center gap-1.5">
                        <span className="font-bold text-white text-[11px]">{tx.paymentMethod}</span>
                        <span className={`text-[8px] font-bold px-1.5 py-0.5 rounded uppercase border ${
                          tx.status === 'SUCCESS' ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' :
                          tx.status === 'FAILED' ? 'bg-rose-500/10 text-rose-400 border-rose-500/20' : 'bg-amber-500/10 text-amber-400 border-amber-500/20'
                        }`}>
                          {tx.status}
                        </span>
                      </div>
                      <p className="text-[9px] text-slate-500 font-mono mt-0.5">TxID: {tx.transactionId}</p>
                    </div>

                    <div className="text-right">
                      <p className="font-mono font-bold text-emerald-400 text-xs">₹{tx.amount}</p>
                      <p className="text-[8px] text-slate-500">Risk Score: {(tx.riskScore * 100).toFixed(0)}%</p>
                    </div>
                  </div>
                ))}

                {paymentHistory.length === 0 && (
                  <div className="text-center py-6 text-slate-500 text-xs bg-[#121418] border border-slate-800 rounded-2xl">
                    <p>No payment intents logged yet.</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* ==========================================
            TRACKING / RIDER MAP SCREEN
            ========================================== */}
        {activeScreen === 'tracking' && (
          <div className="p-4 space-y-4">
            <div className="flex items-center gap-2">
              <button onClick={() => setActiveScreen('home')} className="p-1 hover:bg-slate-900 rounded-full">
                <X className="w-4 h-4" />
              </button>
              <h2 className="text-sm font-bold text-white flex items-center gap-1.5">
                <Clock className="w-4 h-4 text-emerald-400" /> Interactive Map Delivery tracking
              </h2>
            </div>

            {activeOrder ? (
              <div className="space-y-4">
                
                {/* Active Tracking Status Stepper */}
                <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 space-y-3.5">
                  <div className="flex justify-between items-center">
                    <div>
                      <p className="text-[10px] uppercase font-bold text-emerald-400">DELIVERING IN 9 MINUTES</p>
                      <p className="text-xs text-slate-300 font-semibold">Order ID: {activeOrder.id}</p>
                    </div>
                    <span className="px-2 py-0.5 bg-emerald-500/10 text-emerald-400 font-bold rounded text-[9px] uppercase">
                      {riderState.status.replace('_', ' ')}
                    </span>
                  </div>

                  {/* Visual Step progress lines */}
                  <div className="flex items-center justify-between gap-1.5 text-center text-[9px]">
                    {[
                      { step: 'placed', label: 'Placed' },
                      { step: 'at_store', label: 'Store Pick' },
                      { step: 'picked_up', label: 'Riding' },
                      { step: 'near_delivery', label: 'Arrived' },
                      { step: 'delivered', label: 'Delivered' }
                    ].map((stepObj, idx) => {
                      const isCurrentOrPast = 
                        (stepObj.step === 'placed') ||
                        (stepObj.step === 'at_store' && riderState.status !== 'assigned') ||
                        (stepObj.step === 'picked_up' && riderState.status !== 'assigned' && riderState.status !== 'at_store') ||
                        (stepObj.step === 'near_delivery' && (riderState.status === 'near_delivery' || riderState.status === 'delivered')) ||
                        (stepObj.step === 'delivered' && riderState.status === 'delivered');

                      return (
                        <div key={stepObj.step} className="flex-1 space-y-1">
                          <div className={`h-1 rounded-full transition-colors ${isCurrentOrPast ? 'bg-emerald-500' : 'bg-slate-800'}`}></div>
                          <span className={`block font-semibold ${isCurrentOrPast ? 'text-emerald-400' : 'text-slate-500'}`}>
                            {stepObj.label}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                </div>

                {/* Visual Animated Map Wrapper */}
                <div className="bg-slate-950 border border-slate-800 rounded-3xl h-[240px] relative overflow-hidden flex items-center justify-center">
                  
                  {/* Styled Grid Vector Map Mock */}
                  <div className="absolute inset-0 bg-slate-950 opacity-90 font-mono text-[8px] text-slate-700 p-2 overflow-hidden select-none select-none pointer-events-none">
                    <div className="grid grid-cols-12 grid-rows-12 h-full border border-slate-900/40">
                      {Array.from({ length: 144 }).map((_, i) => (
                        <div key={i} className="border-r border-b border-slate-900/10 flex items-center justify-center font-bold">
                          {i % 17 === 0 && '📍'}
                          {i === 55 && '🏢'}
                          {i === 92 && '🏬'}
                        </div>
                      ))}
                    </div>

                    {/* Styled Road Grid overlay */}
                    <div className="absolute w-[4px] h-full bg-slate-900/40 left-1/3"></div>
                    <div className="absolute w-[4px] h-full bg-slate-900/40 left-2/3"></div>
                    <div className="absolute h-[4px] w-full bg-slate-900/40 top-1/3"></div>
                    <div className="absolute h-[4px] w-full bg-slate-900/40 top-2/3"></div>

                    {/* Landmark annotations */}
                    <span className="absolute top-[35%] left-[10%] text-slate-600 font-sans">Koramangala Depot (A4)</span>
                    <span className="absolute bottom-[35%] right-[10%] text-slate-600 font-sans">Your Apartment</span>
                  </div>

                  {/* Dark Store Landmark Node */}
                  <div className="absolute top-[33%] left-[33%] -translate-x-1/2 -translate-y-1/2 bg-purple-500/10 border border-purple-500 p-1.5 rounded-full z-10">
                    <span className="text-[11px] block">🏬</span>
                  </div>

                  {/* Customer Landmark Node */}
                  <div className="absolute top-[66%] left-[66%] -translate-x-1/2 -translate-y-1/2 bg-emerald-500/10 border border-emerald-500 p-1.5 rounded-full z-10">
                    <span className="text-[11px] block">🏡</span>
                  </div>

                  {/* RIDER PIN (Calculated continuously via lat/lng interpolation) */}
                  <div 
                    style={{
                      // Map GPS coordinates into relative visual percentages
                      // Depot lat 12.9279, Customer lat 12.9348
                      // Depot lng 77.6250, Customer lng 77.6189
                      top: `${33 + ((riderState.lat - 12.9279) / (12.9348 - 12.9279)) * 33}%`,
                      left: `${33 + ((riderState.lng - 77.6250) / (77.6189 - 77.6250)) * 33}%`
                    }}
                    className="absolute -translate-x-1/2 -translate-y-1/2 w-8 h-8 bg-slate-900 border-2 border-emerald-400 rounded-full flex items-center justify-center z-20 shadow-xl transition-all duration-1000 ease-linear"
                  >
                    <span className="text-xs animate-bounce">🛵</span>
                  </div>

                  {/* Simulated telemetry HUD overlays */}
                  <div className="absolute bottom-2 left-2 bg-slate-950/80 px-2 py-1 rounded border border-slate-800 font-mono text-[9px] text-emerald-400">
                    Rider: {riderState.name} • 22 km/h
                  </div>
                  <div className="absolute top-2 right-2 bg-slate-950/80 px-2 py-1 rounded border border-slate-800 font-mono text-[9px] text-purple-400">
                    OTP: 4932
                  </div>
                </div>

                {/* Rider details */}
                <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-4 flex justify-between items-center text-xs">
                  <div className="flex items-center gap-3">
                    <img src={riderState.avatar} className="w-10 h-10 rounded-full object-cover" />
                    <div>
                      <p className="font-bold text-white">{riderState.name}</p>
                      <p className="text-[10px] text-slate-400">Rating ★ {riderState.rating} • Best Delivery partner</p>
                    </div>
                  </div>
                  <button className="px-3.5 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-emerald-400 font-bold active:scale-95 transition-transform">
                    📞 CALL
                  </button>
                </div>
              </div>
            ) : (
              <div className="text-center py-20 text-slate-500 text-xs">
                <p>No active shipments to track currently.</p>
                <p className="text-[10px] mt-1 text-slate-600">Add products to your cart and place an order first!</p>
              </div>
            )}
          </div>
        )}
      </div>

      {/* EMERGENCY SELECTION MODAL */}
      <AnimatePresence>
        {emergencyModalOpen && (
          <div className="absolute inset-0 bg-slate-950/90 z-50 flex flex-col justify-end">
            <motion.div 
              initial={{ y: "100%" }}
              animate={{ y: 0 }}
              exit={{ y: "100%" }}
              className="bg-[#121418] border-t border-slate-800 rounded-t-3xl p-6 space-y-5"
            >
              <div className="flex justify-between items-center">
                <h3 className="text-sm font-bold text-rose-400 flex items-center gap-1.5">
                  <Zap className="w-4 h-4 text-rose-500" /> One-Tap Emergency Auto-Cart
                </h3>
                <button onClick={() => setEmergencyModalOpen(false)} className="p-1.5 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4 text-slate-400" />
                </button>
              </div>

              <p className="text-[11px] text-slate-400">
                Select your category. FlashCart will bypass search entirely, load your critical wellness refills or essentials instantly, and direct you straight to checkout.
              </p>

              <div className="space-y-2.5">
                <button 
                  onClick={() => triggerEmergencyOrder('Medicine')}
                  className="w-full text-left p-3.5 bg-slate-950 border border-rose-500/20 hover:border-rose-500 rounded-2xl flex items-center justify-between"
                >
                  <div>
                    <h4 className="text-xs font-bold text-white">💊 Critical Daily Wellness Refills</h4>
                    <p className="text-[9px] text-slate-500">Multivitamins, basic paracetamols, active zincs</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-slate-500" />
                </button>

                <button 
                  onClick={() => triggerEmergencyOrder('Milk')}
                  className="w-full text-left p-3.5 bg-slate-950 border border-rose-500/20 hover:border-rose-500 rounded-2xl flex items-center justify-between"
                >
                  <div>
                    <h4 className="text-xs font-bold text-white">🥛 Standard Household Milk Refill</h4>
                    <p className="text-[9px] text-slate-500">Pasteurized milk full-cream pouch (500ml)</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-slate-500" />
                </button>

                <button 
                  onClick={() => triggerEmergencyOrder('Baby')}
                  className="w-full text-left p-3.5 bg-slate-950 border border-rose-500/20 hover:border-rose-500 rounded-2xl flex items-center justify-between"
                >
                  <div>
                    <h4 className="text-xs font-bold text-white">👶 Sensitive Baby Care Essentials</h4>
                    <p className="text-[9px] text-slate-500">Biodegradable bamboo water wipes</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-slate-500" />
                </button>
              </div>
            </motion.div>
          </div>
        )}
        {/* INVOICE MODAL */}
        {invoiceModalOrder && invoiceData && (
          <div className="absolute inset-0 bg-slate-950/90 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="bg-[#121418] border border-slate-800 rounded-2xl p-5 max-w-sm w-full space-y-4 max-h-[85vh] overflow-y-auto text-xs text-slate-200"
            >
              <div className="flex justify-between items-center border-b border-slate-800 pb-3">
                <div className="flex items-center gap-2">
                  <Receipt className="w-4 h-4 text-purple-400" />
                  <h3 className="font-bold text-white text-sm">Tax Invoice</h3>
                </div>
                <button onClick={() => { setInvoiceModalOrder(null); setInvoiceData(null); }} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4 text-slate-400" />
                </button>
              </div>

              {/* Printable Area */}
              <div id="printable-customer-invoice" className="space-y-3 font-mono text-[10px]">
                <div className="flex justify-between items-start border-b border-slate-800/80 pb-2">
                  <div>
                    <p className="font-bold text-white text-xs">{invoiceData.seller.name}</p>
                    <p className="text-slate-400">{invoiceData.seller.address}</p>
                    <p className="text-slate-500">GSTIN: {invoiceData.seller.gstin}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-purple-400 font-bold">{invoiceData.invoiceNumber}</p>
                    <p className="text-slate-400">{invoiceData.invoiceDate}</p>
                  </div>
                </div>

                <div className="border-b border-slate-800/80 pb-2">
                  <p className="text-slate-500 uppercase font-bold">Billed To:</p>
                  <p className="font-bold text-white">{invoiceData.customer.name}</p>
                  <p className="text-slate-400 truncate">{invoiceData.customer.address}</p>
                </div>

                {/* Items Table */}
                <div className="space-y-1">
                  <div className="flex justify-between font-bold text-slate-400 border-b border-slate-800 pb-1">
                    <span>ITEM</span>
                    <span>QTY x PRICE = TOTAL</span>
                  </div>
                  {invoiceData.items.map((it: any, idx: number) => (
                    <div key={idx} className="flex justify-between text-slate-300">
                      <span className="truncate max-w-[150px]">{it.name}</span>
                      <span>{it.quantity} x ₹{it.unitPrice} = ₹{it.totalPrice}</span>
                    </div>
                  ))}
                </div>

                {/* Totals */}
                <div className="border-t border-slate-800/80 pt-2 space-y-1">
                  <div className="flex justify-between text-slate-400"><span>Subtotal:</span><span>₹{invoiceData.subtotal}</span></div>
                  {invoiceData.discount > 0 && <div className="flex justify-between text-purple-400"><span>Discount:</span><span>-₹{invoiceData.discount}</span></div>}
                  <div className="flex justify-between text-slate-400"><span>GST Tax (5%):</span><span>₹{invoiceData.tax}</span></div>
                  <div className="flex justify-between text-slate-400"><span>Delivery Charge:</span><span>₹{invoiceData.deliveryFee}</span></div>
                  <div className="flex justify-between font-bold text-white text-xs border-t border-slate-800 pt-1">
                    <span>Grand Total:</span>
                    <span className="text-emerald-400">₹{invoiceData.grandTotal}</span>
                  </div>
                  <div className="flex justify-between text-[9px] text-slate-500 pt-1">
                    <span>Payment: {invoiceData.paymentMethod}</span>
                    <span className="text-emerald-400 font-bold uppercase">{invoiceData.paymentStatus}</span>
                  </div>
                </div>
              </div>

              <div className="flex gap-2 pt-2 border-t border-slate-800">
                <button 
                  onClick={() => window.print()} 
                  className="flex-1 py-2 bg-purple-600 hover:bg-purple-500 text-white font-bold rounded-xl flex items-center justify-center gap-1"
                >
                  <Printer className="w-3.5 h-3.5" /> Print Invoice
                </button>
                <button 
                  onClick={() => { setInvoiceModalOrder(null); setInvoiceData(null); }} 
                  className="px-4 py-2 bg-slate-900 border border-slate-800 text-slate-300 font-bold rounded-xl"
                >
                  Close
                </button>
              </div>
            </motion.div>
          </div>
        )}

        {/* TIMELINE MODAL */}
        {timelineModalOrder && timelineData && (
          <div className="absolute inset-0 bg-slate-950/90 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="bg-[#121418] border border-slate-800 rounded-2xl p-5 max-w-sm w-full space-y-4 max-h-[85vh] overflow-y-auto text-xs text-slate-200"
            >
              <div className="flex justify-between items-center border-b border-slate-800 pb-3">
                <div className="flex items-center gap-2">
                  <Clock className="w-4 h-4 text-emerald-400" />
                  <h3 className="font-bold text-white text-sm">Order Timeline Audit</h3>
                </div>
                <button onClick={() => { setTimelineModalOrder(null); setTimelineData(null); }} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4 text-slate-400" />
                </button>
              </div>

              <p className="text-[10px] text-slate-400">Real-time audit log for Order #{timelineModalOrder.id}</p>

              <div className="space-y-3 relative before:absolute before:left-2.5 before:top-2 before:bottom-2 before:w-0.5 before:bg-slate-800">
                {timelineData.map((evt: any, idx: number) => (
                  <div key={idx} className="flex items-start gap-3 relative z-10">
                    <div className={`w-5 h-5 rounded-full flex items-center justify-center text-[9px] font-bold shrink-0 ${
                      evt.completed ? 'bg-emerald-500 text-slate-950' : 'bg-slate-800 text-slate-500 border border-slate-700'
                    }`}>
                      {evt.completed ? '✓' : idx + 1}
                    </div>
                    <div className="space-y-0.5">
                      <p className={`font-bold ${evt.completed ? 'text-white' : 'text-slate-500'}`}>{evt.title}</p>
                      <p className="text-[10px] text-slate-400">{evt.notes}</p>
                      <span className="text-[9px] text-slate-500 font-mono block">{evt.timestamp}</span>
                    </div>
                  </div>
                ))}
              </div>

              <button 
                onClick={() => { setTimelineModalOrder(null); setTimelineData(null); }} 
                className="w-full py-2 bg-slate-900 border border-slate-800 text-slate-300 font-bold rounded-xl mt-2"
              >
                Close Audit Log
              </button>
            </motion.div>
          </div>
        )}

        {/* CANCELLATION REASON MODAL */}
        {cancellingOrderId && (
          <div className="absolute inset-0 bg-slate-950/90 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="bg-[#121418] border border-slate-800 rounded-2xl p-5 max-w-sm w-full space-y-4 text-xs text-slate-200"
            >
              <div className="flex justify-between items-center border-b border-slate-800 pb-2">
                <h3 className="font-bold text-rose-400 text-sm flex items-center gap-1.5">
                  <XCircle className="w-4 h-4 text-rose-500" /> Confirm Order Cancellation
                </h3>
                <button onClick={() => setCancellingOrderId(null)} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4 text-slate-400" />
                </button>
              </div>

              <p className="text-[11px] text-slate-400">
                Are you sure you want to cancel order #{cancellingOrderId}? Any deducted wallet funds will be refunded instantly to your FlashCart wallet balance.
              </p>

              <div>
                <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Reason for cancellation (optional)</label>
                <input 
                  type="text" 
                  value={cancelReasonInput}
                  onChange={(e) => setCancelReasonInput(e.target.value)}
                  placeholder="e.g. Placed order by mistake / Changed items"
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white placeholder-slate-600 focus:outline-none focus:border-rose-500"
                />
              </div>

              <div className="flex gap-2 pt-2">
                <button 
                  onClick={() => handleCancelOrder(cancellingOrderId, cancelReasonInput)}
                  className="flex-1 py-2 bg-rose-600 hover:bg-rose-500 text-white font-bold rounded-xl active:scale-95"
                >
                  Yes, Cancel & Refund
                </button>
                <button 
                  onClick={() => setCancellingOrderId(null)}
                  className="px-4 py-2 bg-slate-900 border border-slate-800 text-slate-300 font-bold rounded-xl"
                >
                  Keep Order
                </button>
              </div>
            </motion.div>
          </div>
        )}

        {/* TOPUP / REFILL WALLET MODAL */}
        {topupModalOpen && (
          <div className="absolute inset-0 bg-slate-950/90 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="bg-[#121418] border border-slate-800 rounded-3xl p-5 max-w-sm w-full space-y-4 text-xs text-slate-200"
            >
              <div className="flex justify-between items-center border-b border-slate-800 pb-2.5">
                <h3 className="font-bold text-emerald-400 text-sm flex items-center gap-1.5">
                  <Plus className="w-4 h-4 text-emerald-400" /> Refill FlashCart Wallet
                </h3>
                <button onClick={() => setTopupModalOpen(false)} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4 text-slate-400" />
                </button>
              </div>

              <div>
                <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Quick Amount Selection</label>
                <div className="grid grid-cols-4 gap-1.5 mb-3">
                  {[500, 1000, 2000, 5000].map(amt => (
                    <button
                      key={amt}
                      onClick={() => setTopupAmountInput(amt)}
                      className={`py-1.5 rounded-xl border text-xs font-mono font-bold transition-all ${
                        topupAmountInput === amt 
                          ? 'bg-emerald-500 text-slate-950 border-emerald-500' 
                          : 'bg-slate-950 text-slate-300 border-slate-800 hover:border-slate-700'
                      }`}
                    >
                      ₹{amt}
                    </button>
                  ))}
                </div>

                <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Custom Amount (₹)</label>
                <input 
                  type="number" 
                  value={topupAmountInput}
                  onChange={(e) => setTopupAmountInput(Number(e.target.value))}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm font-mono text-white focus:outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Payment Provider</label>
                <select 
                  value={topupMethodInput}
                  onChange={(e) => setTopupMethodInput(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-emerald-500"
                >
                  <option value="UPI (GPay)">📱 Google Pay UPI</option>
                  <option value="UPI (PhonePe)">📱 PhonePe UPI</option>
                  <option value="UPI (Paytm)">📱 Paytm UPI</option>
                  <option value="Credit Card">💳 Credit / Debit Card</option>
                </select>
              </div>

              <div className="flex gap-2 pt-2">
                <button 
                  onClick={handleTopupSubmit}
                  className="flex-1 py-2.5 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold rounded-xl active:scale-95 transition-all shadow-lg text-xs"
                >
                  Pay ₹{topupAmountInput} & Add to Wallet
                </button>
              </div>
            </motion.div>
          </div>
        )}

        {/* WITHDRAW WALLET MODAL */}
        {withdrawModalOpen && (
          <div className="absolute inset-0 bg-slate-950/90 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="bg-[#121418] border border-slate-800 rounded-3xl p-5 max-w-sm w-full space-y-4 text-xs text-slate-200"
            >
              <div className="flex justify-between items-center border-b border-slate-800 pb-2.5">
                <h3 className="font-bold text-purple-400 text-sm flex items-center gap-1.5">
                  <ArrowUpRight className="w-4 h-4 text-purple-400" /> Withdraw Wallet Cash
                </h3>
                <button onClick={() => setWithdrawModalOpen(false)} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4 text-slate-400" />
                </button>
              </div>

              <div>
                <p className="text-[11px] text-slate-400 mb-2">Available Cash Balance: <span className="font-bold text-emerald-400 font-mono">₹{walletBalance.toFixed(2)}</span></p>

                <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Withdrawal Amount (₹)</label>
                <input 
                  type="number" 
                  value={withdrawAmountInput}
                  onChange={(e) => setWithdrawAmountInput(Number(e.target.value))}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm font-mono text-white focus:outline-none focus:border-purple-500"
                />
              </div>

              <div>
                <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Destination VPA / UPI ID</label>
                <input 
                  type="text" 
                  value={withdrawUpiInput}
                  onChange={(e) => setWithdrawUpiInput(e.target.value)}
                  placeholder="e.g. name@upi"
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-purple-500"
                />
              </div>

              <div className="flex gap-2 pt-2">
                <button 
                  onClick={handleWithdrawSubmit}
                  className="flex-1 py-2.5 bg-purple-600 hover:bg-purple-500 text-white font-bold rounded-xl active:scale-95 transition-all text-xs"
                >
                  Initiate ₹{withdrawAmountInput} Instant Transfer
                </button>
              </div>
            </motion.div>
          </div>
        )}

        {/* REDEEM REWARD POINTS MODAL */}
        {rewardModalOpen && (
          <div className="absolute inset-0 bg-slate-950/90 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="bg-[#121418] border border-slate-800 rounded-3xl p-5 max-w-sm w-full space-y-4 text-xs text-slate-200"
            >
              <div className="flex justify-between items-center border-b border-slate-800 pb-2.5">
                <h3 className="font-bold text-amber-400 text-sm flex items-center gap-1.5">
                  <Coins className="w-4 h-4 text-amber-400" /> Convert Rewards to Cash
                </h3>
                <button onClick={() => setRewardModalOpen(false)} className="p-1 hover:bg-slate-900 rounded-full">
                  <X className="w-4 h-4 text-slate-400" />
                </button>
              </div>

              <div className="bg-amber-500/10 border border-amber-500/20 p-3 rounded-2xl text-center">
                <p className="text-[10px] uppercase font-bold text-amber-400">Your Active Balance</p>
                <p className="text-xl font-bold text-white font-mono mt-0.5">{rewardPoints} Loyalty Points</p>
                <p className="text-[10px] text-slate-400 mt-1">10 Points = ₹1 Real Wallet Cash</p>
              </div>

              <div>
                <label className="text-[10px] text-slate-400 font-semibold mb-1 block">Points to Redeem</label>
                <input 
                  type="number" 
                  value={redeemPointsInput}
                  onChange={(e) => setRedeemPointsInput(Number(e.target.value))}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm font-mono text-white focus:outline-none focus:border-amber-500"
                />
                <p className="text-[10px] text-emerald-400 mt-1 font-semibold">
                  Equivalent Cash Credit: ₹{(redeemPointsInput / 10).toFixed(2)}
                </p>
              </div>

              <div className="flex gap-2 pt-2">
                <button 
                  onClick={handleRedeemPointsSubmit}
                  className="flex-1 py-2.5 bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold rounded-xl active:scale-95 transition-all text-xs"
                >
                  Convert & Add ₹{(redeemPointsInput / 10).toFixed(2)} to Wallet
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Bottom Floating iOS Tab Bar */}
      <div className="absolute bottom-3 left-4 right-4 h-14 bg-[#121418]/90 border border-slate-800/60 backdrop-blur-xl rounded-2xl px-3 flex items-center justify-between shadow-xl z-20">
        {[
          { id: 'home', label: 'Explore', icon: ShoppingBag },
          { id: 'wishlist', label: 'Wishlist', icon: Heart, badgeCount: wishlist.length },
          { id: 'orders', label: 'Orders', icon: Package, badgeCount: ordersHistory.length },
          { id: 'wallet', label: 'Wallet', icon: Wallet },
          { id: 'assistant', label: 'AI Helper', icon: Brain },
          { id: 'cart', label: 'Cart', icon: ShoppingBag, badgeCount: activeCartItems.length },
          { id: 'tracking', label: 'Track', icon: MapPin }
        ].map(tab => {
          const IconComp = tab.icon;
          const isSelected = activeScreen === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveScreen(tab.id)}
              className="flex flex-col items-center justify-center text-[10px] text-slate-400 hover:text-emerald-400 active:scale-95 transition-all relative py-1 shrink-0"
            >
              {tab.badgeCount && tab.badgeCount > 0 ? (
                <div className="absolute -top-1 -right-2 bg-emerald-500 text-slate-950 font-bold text-[8px] w-4.5 h-4.5 rounded-full flex items-center justify-center animate-bounce">
                  {tab.badgeCount}
                </div>
              ) : null}
              <IconComp className={`w-4 h-4 ${isSelected ? 'text-emerald-400 scale-110' : 'text-slate-400'}`} />
              <span className={`text-[8px] mt-0.5 font-bold ${isSelected ? 'text-emerald-400' : 'text-slate-500'}`}>
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>

      {/* Module 8 Notification Center Modal */}
      <NotificationCenterModal
        isOpen={notificationModalOpen}
        onClose={() => setNotificationModalOpen(false)}
        userId="u1"
        role="CUSTOMER"
        onUnreadCountChange={setUnreadNotificationCount}
      />
    </div>
  );
}
