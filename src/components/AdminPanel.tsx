import React, { useState, useMemo } from 'react';
import {
  ThemeProvider, createTheme, CssBaseline, Box, Drawer, AppBar, Toolbar,
  List, ListItem, ListItemButton, ListItemIcon, ListItemText, Typography,
  IconButton, Avatar, Menu, MenuItem, Divider, Badge
} from '@mui/material';
import {
  LayoutDashboard, ShoppingCart, FolderHeart, FileClock, Users, Bike,
  Bookmark, Image, ShieldAlert, Sparkles, Settings, LogOut, Sun, Moon, Key,
  CreditCard, Bell
} from 'lucide-react';

import { Product } from '../types';

// Mock Data & Interfaces
import {
  initialCategories, initialOrders, initialCustomers, initialRiders,
  initialCoupons, initialBanners, Category, Order, Customer, Rider, Coupon, AppBanner
} from './AdminPanel/mockData';

// Modular Screen Imports
import LoginModule from './AdminPanel/LoginModule';
import DashboardModule from './AdminPanel/DashboardModule';
import ProductModule from './AdminPanel/ProductModule';
import CategoryModule from './AdminPanel/CategoryModule';
import OrderModule from './AdminPanel/OrderModule';
import CustomerModule from './AdminPanel/CustomerModule';
import DeliveryModule from './AdminPanel/DeliveryModule';
import CouponModule from './AdminPanel/CouponModule';
import BannerModule from './AdminPanel/BannerModule';
import ReportModule from './AdminPanel/ReportModule';
import AIModule from './AdminPanel/AIModule';
import SettingsModule from './AdminPanel/SettingsModule';
import PaymentModule from './AdminPanel/PaymentModule';
import NotificationModule from './AdminPanel/NotificationModule';

interface AdminPanelProps {
  products: Product[];
  setProducts: React.Dispatch<React.SetStateAction<Product[]>>;
  activeTab: 'admin' | 'store';
}

export default function AdminPanel({ products, setProducts, activeTab }: AdminPanelProps) {
  // Global Login & Role state
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentUser, setCurrentUser] = useState<{ name: string; role: string } | null>(null);

  // Active Screen Selector (maps to 12 modules)
  // If activeTab is 'store', default to 'products' (Module 3 - Merchant Stock Room)
  const [activeScreen, setActiveScreen] = useState<string>(activeTab === 'store' ? 'products' : 'dashboard');

  // Theme configuration (Dark & Light Mode)
  const [isDarkMode, setIsDarkMode] = useState(true);

  // Local state pipelines for Admin modules
  const [categoriesState, setCategoriesState] = useState<Category[]>(initialCategories);
  const [ordersState, setOrdersState] = useState<Order[]>(initialOrders);
  const [customersState, setCustomersState] = useState<Customer[]>(initialCustomers);
  const [ridersState, setRidersState] = useState<Rider[]>(initialRiders);
  const [couponsState, setCouponsState] = useState<Coupon[]>(initialCoupons);
  const [bannersState, setBannersState] = useState<AppBanner[]>(initialBanners);

  // Fetch Coupons from backend
  React.useEffect(() => {
    const fetchCoupons = async () => {
      try {
        const res = await fetch('/api/coupons');
        if (res.ok) {
          const data = await res.json();
          if (Array.isArray(data) && data.length > 0) {
            setCouponsState(data.map((c: any) => ({
              id: c.id,
              code: c.code,
              type: c.type === 'PERCENTAGE' || c.type === 'percentage' ? 'percentage' : 'flat',
              value: c.discountValue || c.value || 10,
              expiry: (c.validUntil || c.expiry || '2026-12-31').substring(0, 10),
              usageLimit: c.totalUsageLimit || c.usageLimit || 1000,
              usageCount: c.timesUsed || c.usageCount || 0,
              minOrderValue: c.minOrderAmount || c.minOrderValue || 200,
              status: c.isActive !== false && c.status !== 'Disabled' ? 'Active' : 'Disabled'
            })));
          }
        }
      } catch (err) {
        console.error("Error fetching coupons:", err);
      }
    };
    fetchCoupons();
  }, []);

  // Profile Menu anchoring
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);

  // Custom MUI Theme generator
  const theme = useMemo(() => {
    return createTheme({
      palette: {
        mode: isDarkMode ? 'dark' : 'light',
        primary: {
          main: '#6200ee',
        },
        secondary: {
          main: '#10b981',
        },
        background: {
          default: isDarkMode ? '#0a0b0d' : '#f8fafc',
          paper: isDarkMode ? '#111317' : '#ffffff',
        },
        text: {
          primary: isDarkMode ? '#f8fafc' : '#0f172a',
          secondary: isDarkMode ? '#94a3b8' : '#475569',
        },
      },
      typography: {
        fontFamily: '"Inter", sans-serif',
      },
      components: {
        MuiCard: {
          styleOverrides: {
            root: {
              boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
              backgroundImage: 'none',
            },
          },
        },
        MuiButton: {
          styleOverrides: {
            root: {
              textTransform: 'none',
              borderRadius: 8,
              fontWeight: 'bold',
            },
          },
        },
      },
    });
  }, [isDarkMode]);

  // Sync products state with parent (App.tsx)
  const handleAddProduct = (newProd: Product) => {
    setProducts(prev => [...prev, newProd]);
  };

  const handleEditProduct = (editedProd: Product) => {
    setProducts(prev => prev.map(p => p.id === editedProd.id ? editedProd : p));
  };

  const handleDeleteProduct = (productId: string) => {
    setProducts(prev => prev.filter(p => p.id !== productId));
  };

  const handleBulkUpload = (bulkProducts: Product[]) => {
    setProducts(prev => [...prev, ...bulkProducts]);
  };

  const handleRestockProduct = (productId: string) => {
    setProducts(prev => prev.map(p => p.id === productId ? { ...p, inventory: p.inventory + 50 } : p));
  };

  // State adjustment for Orders
  React.useEffect(() => {
    const fetchOrders = async () => {
      try {
        const res = await fetch('/api/orders');
        if (res.ok) {
          const data = await res.json();
          if (Array.isArray(data) && data.length > 0) {
            setOrdersState(data.map((o: any) => ({
              id: o.id,
              customerName: o.customerName || "Arav Sharma",
              customerEmail: o.customerEmail || "arav@flashcart.ai",
              address: o.deliveryAddress || "Symphony Premium Apts, Koramangala 3rd Block",
              items: o.items.map((i: any) => ({
                id: i.product.id,
                name: i.product.name,
                price: i.product.price,
                quantity: i.quantity
              })),
              total: o.total,
              tax: o.tax || Math.round(o.subtotal * 0.05),
              discount: o.discount || 0,
              status: o.status === 'PLACED' || o.status === 'CONFIRMED' || o.status === 'PICKING' ? 'Pending' :
                      o.status === 'PACKING' || o.status === 'READY_FOR_PICKUP' ? 'Packed' :
                      o.status === 'OUT_FOR_DELIVERY' ? 'Out for Delivery' :
                      o.status === 'DELIVERED' ? 'Delivered' :
                      o.status === 'CANCELLED' ? 'Cancelled' :
                      o.status === 'RETURNED' ? 'Returned' : o.status,
              createdAt: o.createdAt,
              paymentMethod: o.paymentMethod || "Wallet Pay",
              riderName: "Suresh Kumar"
            })));
          }
        }
      } catch (err) {
        console.error("Error fetching orders in AdminPanel:", err);
      }
    };
    fetchOrders();
    const interval = setInterval(fetchOrders, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleUpdateOrderStatus = async (orderId: string, newStatus: Order['status']) => {
    setOrdersState(prev => prev.map(o => o.id === orderId ? { ...o, status: newStatus } : o));
    try {
      let apiStatus = newStatus.toUpperCase();
      if (newStatus === 'Pending') apiStatus = 'CONFIRMED';
      if (newStatus === 'Packed') apiStatus = 'PACKING';
      if (newStatus === 'Out for Delivery') apiStatus = 'OUT_FOR_DELIVERY';
      if (newStatus === 'Delivered') apiStatus = 'DELIVERED';
      if (newStatus === 'Cancelled') apiStatus = 'CANCELLED';
      if (newStatus === 'Returned') apiStatus = 'RETURNED';

      await fetch(`/api/orders/${orderId}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: apiStatus })
      });
    } catch (e) {
      console.error("Error updating order status:", e);
    }
  };

  // State adjustment for Customers
  const handleAdjustWallet = (customerId: string, amount: number) => {
    setCustomersState(prev => prev.map(c => c.id === customerId ? { ...c, walletBalance: c.walletBalance + amount } : c));
  };

  const handleAdjustPoints = (customerId: string, points: number) => {
    setCustomersState(prev => prev.map(c => c.id === customerId ? { ...c, loyaltyPoints: c.loyaltyPoints + points } : c));
  };

  // State adjustment for Riders
  const handleToggleRiderStatus = (riderId: string) => {
    setRidersState(prev => prev.map(r => r.id === riderId ? { ...r, status: r.status === 'Offline' ? 'Online' : 'Offline' } : r));
  };

  const handleUpdateRiderLocation = (riderId: string, lat: number, lng: number) => {
    setRidersState(prev => prev.map(r => r.id === riderId ? { ...r, lat, lng } : r));
  };

  // Coupons
  const handleCreateCoupon = async (coupon: Coupon) => {
    setCouponsState(prev => [...prev, coupon]);
    try {
      await fetch('/api/admin/coupons', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          code: coupon.code,
          title: `Special ${coupon.code}`,
          description: `${coupon.type === 'percentage' ? coupon.value + '%' : '₹' + coupon.value} OFF on orders above ₹${coupon.minOrderValue}`,
          type: coupon.type === 'percentage' ? 'PERCENTAGE' : 'FLAT',
          discountValue: coupon.value,
          minOrderAmount: coupon.minOrderValue,
          validUntil: coupon.expiry,
          totalUsageLimit: coupon.usageLimit,
          isActive: true
        })
      });
    } catch (e) {
      console.error("Error creating coupon on backend:", e);
    }
  };

  const handleToggleCouponStatus = async (couponId: string) => {
    const target = couponsState.find(c => c.id === couponId);
    const newStatus = target?.status === 'Active' ? 'Disabled' : 'Active';
    setCouponsState(prev => prev.map(c => c.id === couponId ? { ...c, status: newStatus } : c));
    try {
      await fetch(`/api/admin/coupons/${couponId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive: newStatus === 'Active' })
      });
    } catch (e) {
      console.error("Error toggling coupon status on backend:", e);
    }
  };

  // Banners
  const handleAddBanner = (banner: AppBanner) => {
    setBannersState(prev => [...prev, banner]);
  };

  const handleToggleBannerStatus = (bannerId: string) => {
    setBannersState(prev => prev.map(b => b.id === bannerId ? { ...b, status: b.status === 'Active' ? 'Inactive' : 'Active' } : b));
  };

  const handleDeleteBanner = (bannerId: string) => {
    setBannersState(prev => prev.filter(b => b.id !== bannerId));
  };

  // Navigation sidebar entries
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: <LayoutDashboard size={20} />, roles: ['admin'] },
    { id: 'products', label: 'Products', icon: <ShoppingCart size={20} />, roles: ['admin', 'store'] },
    { id: 'categories', label: 'Categories', icon: <FolderHeart size={20} />, roles: ['admin'] },
    { id: 'orders', label: 'Orders', icon: <FileClock size={20} />, roles: ['admin', 'store'] },
    { id: 'payments', label: 'Payments & Wallet', icon: <CreditCard size={20} />, roles: ['admin'] },
    { id: 'notifications', label: 'Notifications Hub', icon: <Bell size={20} />, roles: ['admin', 'store'] },
    { id: 'customers', label: 'Customers', icon: <Users size={20} />, roles: ['admin'] },
    { id: 'delivery', label: 'Delivery Logistics', icon: <Bike size={20} />, roles: ['admin'] },
    { id: 'coupons', label: 'Coupons', icon: <Bookmark size={20} />, roles: ['admin'] },
    { id: 'banners', label: 'Banners', icon: <Image size={20} />, roles: ['admin'] },
    { id: 'reports', label: 'Reports & Tax', icon: <ShieldAlert size={20} />, roles: ['admin'] },
    { id: 'ai', label: 'AI Analytics', icon: <Sparkles size={20} />, roles: ['admin'] },
    { id: 'settings', label: 'Settings & Roles', icon: <Settings size={20} />, roles: ['admin', 'store'] },
  ];

  const handleLoginSuccess = (user: { name: string; role: string }) => {
    setCurrentUser(user);
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setCurrentUser(null);
  };

  // Filter menu items by the current active tab / role mapping
  const visibleMenuItems = menuItems.filter(item => {
    if (activeTab === 'store') {
      return item.roles.includes('store');
    }
    return item.roles.includes('admin');
  });

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Box sx={{ display: 'flex', height: '100%', overflow: 'hidden' }}>
        
        {/* Render auth shield if not logged in */}
        {!isLoggedIn ? (
          <Box sx={{ width: '100%', height: '100%', overflowY: 'auto', backgroundColor: 'background.default' }}>
            <LoginModule onLoginSuccess={handleLoginSuccess} />
          </Box>
        ) : (
          <>
            {/* Left Sidebar Menu */}
            <Drawer
              variant="permanent"
              sx={{
                width: 220,
                flexShrink: 0,
                [`& .MuiDrawer-paper`]: {
                  width: 220,
                  boxSizing: 'border-box',
                  borderRight: '1px solid',
                  borderColor: 'divider',
                  position: 'relative',
                  backgroundColor: 'background.paper',
                },
              }}
            >
              <Box sx={{ p: 2, display: 'flex', alignItems: 'center', gap: 1, borderBottom: '1px solid', borderColor: 'divider' }}>
                <Sparkles size={20} color="#6200ee" style={{ fill: 'rgba(98,0,238,0.2)' }} />
                <Typography variant="subtitle2" fontWeight="bold">
                  {activeTab === 'store' ? 'Merchant Portal' : 'Admin Control'}
                </Typography>
              </Box>

              <List sx={{ px: 1, py: 1.5 }}>
                {visibleMenuItems.map((item) => (
                  <ListItem key={item.id} disablePadding sx={{ mb: 0.5 }}>
                    <ListItemButton
                      selected={activeScreen === item.id}
                      onClick={() => setActiveScreen(item.id)}
                      sx={{
                        borderRadius: 2,
                        '&.Mui-selected': {
                          backgroundColor: 'rgba(98, 0, 238, 0.08)',
                          color: '#6200ee',
                          fontWeight: 'bold',
                          '& .MuiListItemIcon-root': { color: '#6200ee' }
                        },
                      }}
                    >
                      <ListItemIcon sx={{ minWidth: 40, color: 'text.secondary' }}>
                        {item.icon}
                      </ListItemIcon>
                      <ListItemText
                        primary={item.label}
                        primaryTypographyProps={{ fontSize: '0.8rem', fontWeight: activeScreen === item.id ? 'bold' : 'medium' }}
                      />
                    </ListItemButton>
                  </ListItem>
                ))}
              </List>

              {/* Sidebar bottom logged in info */}
              <Box sx={{ mt: 'auto', p: 1.5, borderTop: '1px solid', borderColor: 'divider', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Avatar sx={{ width: 28, height: 28, backgroundColor: '#6200ee', fontSize: '0.75rem', fontWeight: 'bold' }}>
                    A
                  </Avatar>
                  <Box sx={{ minWidth: 0 }}>
                    <Typography variant="caption" fontWeight="bold" noWrap sx={{ display: 'block' }}>
                      {currentUser?.name}
                    </Typography>
                    <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.65rem' }}>
                      {currentUser?.role}
                    </Typography>
                  </Box>
                </Box>
                <IconButton size="small" onClick={handleLogout} color="error" title="Sign Out">
                  <LogOut size={16} />
                </IconButton>
              </Box>
            </Drawer>

            {/* Right Main Content Area */}
            <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column', height: '100%', overflow: 'hidden' }}>
              
              {/* Header AppBar */}
              <AppBar position="static" color="transparent" elevation={0} sx={{ borderBottom: '1px solid', borderColor: 'divider', backgroundColor: 'background.paper' }}>
                <Toolbar sx={{ justifyContent: 'space-between', minHeight: '56px !important', px: 2 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="subtitle1" fontWeight="bold">
                      {activeScreen.toUpperCase()} MODULE
                    </Typography>
                  </Box>

                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    {/* Light/Dark Toggler */}
                    <IconButton size="small" onClick={() => setIsDarkMode(!isDarkMode)}>
                      {isDarkMode ? <Sun size={18} /> : <Moon size={18} />}
                    </IconButton>
                  </Box>
                </Toolbar>
              </AppBar>

              {/* Central Module Switcher Panel */}
              <Box sx={{ flexGrow: 1, p: 3, overflowY: 'auto', backgroundColor: 'background.default' }}>
                {activeScreen === 'dashboard' && (
                  <DashboardModule
                    products={products}
                    orders={ordersState}
                    onRestock={handleRestockProduct}
                    onNavigateToTab={setActiveScreen}
                  />
                )}
                {activeScreen === 'products' && (
                  <ProductModule
                    products={products}
                    onAddProduct={handleAddProduct}
                    onEditProduct={handleEditProduct}
                    onDeleteProduct={handleDeleteProduct}
                    onBulkUpload={handleBulkUpload}
                  />
                )}
                {activeScreen === 'categories' && (
                  <CategoryModule
                    categories={categoriesState}
                    onAddCategory={(cat) => setCategoriesState(prev => [...prev, cat])}
                    onEditCategory={(editedCat) => setCategoriesState(prev => prev.map(c => c.id === editedCat.id ? editedCat : c))}
                    onDeleteCategory={(catId) => setCategoriesState(prev => prev.filter(c => c.id !== catId))}
                  />
                )}
                {activeScreen === 'orders' && (
                  <OrderModule
                    orders={ordersState}
                    onUpdateOrderStatus={handleUpdateOrderStatus}
                  />
                )}
                {activeScreen === 'payments' && (
                  <PaymentModule />
                )}
                {activeScreen === 'notifications' && (
                  <NotificationModule />
                )}
                {activeScreen === 'customers' && (
                  <CustomerModule
                    customers={customersState}
                    onAdjustWallet={handleAdjustWallet}
                    onAdjustPoints={handleAdjustPoints}
                  />
                )}
                {activeScreen === 'delivery' && (
                  <DeliveryModule
                    riders={ridersState}
                    onToggleRiderStatus={handleToggleRiderStatus}
                    onUpdateRiderLocation={handleUpdateRiderLocation}
                  />
                )}
                {activeScreen === 'coupons' && (
                  <CouponModule
                    coupons={couponsState}
                    onCreateCoupon={handleCreateCoupon}
                    onToggleCouponStatus={handleToggleCouponStatus}
                  />
                )}
                {activeScreen === 'banners' && (
                  <BannerModule
                    banners={bannersState}
                    onAddBanner={handleAddBanner}
                    onToggleBannerStatus={handleToggleBannerStatus}
                    onDeleteBanner={handleDeleteBanner}
                  />
                )}
                {activeScreen === 'reports' && (
                  <ReportModule />
                )}
                {activeScreen === 'ai' && (
                  <AIModule />
                )}
                {activeScreen === 'settings' && (
                  <SettingsModule />
                )}
              </Box>
            </Box>
          </>
        )}
      </Box>
    </ThemeProvider>
  );
}
