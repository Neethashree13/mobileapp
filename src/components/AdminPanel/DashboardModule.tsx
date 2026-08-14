import React from 'react';
import {
  Box, Grid, Card, CardContent, Typography,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Paper, Button, Alert, Chip, LinearProgress
} from '@mui/material';
import {
  TrendingUp, ShoppingBag, Users, Package, AlertTriangle,
  ArrowUpRight, RefreshCw, Layers
} from 'lucide-react';
import {
  ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip,
  BarChart, Bar, PieChart, Pie, Cell, Legend
} from 'recharts';
import {
  Product, Order, salesTrends, categoryDistribution
} from './mockData';

interface DashboardModuleProps {
  products: Product[];
  orders: Order[];
  onRestock: (productId: string) => void;
  onNavigateToTab: (tab: string) => void;
}

const COLORS = ['#6200ee', '#10b981', '#fbbf24', '#f87171'];

export default function DashboardModule({ products, orders, onRestock, onNavigateToTab }: DashboardModuleProps) {
  // Aggregate stats
  const totalRevenue = orders
    .filter(o => o.status !== 'Cancelled')
    .reduce((sum, o) => sum + o.total, 0);
  const totalOrders = orders.length;
  const lowStockProducts = products.filter(p => p.inventory < 20);

  // Today's Sales vs target (e.g., Target 50,000 INR)
  const todaySales = orders
    .filter(o => o.status !== 'Cancelled')
    .reduce((sum, o) => sum + o.total, 0);
  const targetSales = 3000;
  const salesProgressPct = Math.min((todaySales / targetSales) * 100, 100);

  // Status counts
  const statusCounts = orders.reduce((acc, order) => {
    acc[order.status] = (acc[order.status] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  return (
    <Box sx={{ spaceY: 3 }}>
      {/* Page Title */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h5" fontWeight="bold" color="text.primary">
            Ground Control Dashboard
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Real-time quick commerce metrics and fulfillment overview
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 1.5 }}>
          <Button startIcon={<RefreshCw size={16} />} variant="outlined" size="small" onClick={() => window.location.reload()}>
            Sync Pipeline
          </Button>
        </Box>
      </Box>

      {/* KPI Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1.5 }}>
                <Typography variant="subtitle2" color="text.secondary" fontWeight="medium">
                  TOTAL REVENUE
                </Typography>
                <Box sx={{ p: 1, borderRadius: 2, backgroundColor: 'rgba(98, 0, 238, 0.08)', color: '#6200ee', display: 'flex' }}>
                  <TrendingUp size={20} />
                </Box>
              </Box>
              <Typography variant="h4" fontWeight="bold" color="text.primary">
                ₹{totalRevenue.toLocaleString()}
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', mt: 1, gap: 0.5 }}>
                <Typography variant="caption" color="success.main" fontWeight="bold" sx={{ display: 'flex', alignItems: 'center' }}>
                  +18.2% <ArrowUpRight size={12} />
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  vs last week
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1.5 }}>
                <Typography variant="subtitle2" color="text.secondary" fontWeight="medium">
                  FULFILLMENT ORDERS
                </Typography>
                <Box sx={{ p: 1, borderRadius: 2, backgroundColor: 'rgba(16, 185, 129, 0.08)', color: '#10b981', display: 'flex' }}>
                  <ShoppingBag size={20} />
                </Box>
              </Box>
              <Typography variant="h4" fontWeight="bold" color="text.primary">
                {totalOrders}
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', mt: 1, gap: 0.5 }}>
                <Typography variant="caption" color="success.main" fontWeight="bold" sx={{ display: 'flex', alignItems: 'center' }}>
                  +5.4% <ArrowUpRight size={12} />
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  vs target speed
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1.5 }}>
                <Typography variant="subtitle2" color="text.secondary" fontWeight="medium">
                  ACTIVE CUSTOMERS
                </Typography>
                <Box sx={{ p: 1, borderRadius: 2, backgroundColor: 'rgba(59, 130, 246, 0.08)', color: '#3b82f6', display: 'flex' }}>
                  <Users size={20} />
                </Box>
              </Box>
              <Typography variant="h4" fontWeight="bold" color="text.primary">
                {products.length * 3 + 24}
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', mt: 1, gap: 0.5 }}>
                <Typography variant="caption" color="success.main" fontWeight="bold" sx={{ display: 'flex', alignItems: 'center' }}>
                  +12.8% <ArrowUpRight size={12} />
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  user conversions
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderRadius: 3, border: lowStockProducts.length > 0 ? '1px solid rgba(248, 113, 113, 0.3)' : 'none' }}>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1.5 }}>
                <Typography variant="subtitle2" color="text.secondary" fontWeight="medium">
                  LOW STOCK ALERTS
                </Typography>
                <Box sx={{
                  p: 1,
                  borderRadius: 2,
                  backgroundColor: lowStockProducts.length > 0 ? 'rgba(239, 68, 68, 0.08)' : 'rgba(245, 158, 11, 0.08)',
                  color: lowStockProducts.length > 0 ? '#ef4444' : '#f59e0b',
                  display: 'flex'
                }}>
                  <AlertTriangle size={20} />
                </Box>
              </Box>
              <Typography variant="h4" fontWeight="bold" color={lowStockProducts.length > 0 ? 'error.main' : 'text.primary'}>
                {lowStockProducts.length}
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', mt: 1, gap: 0.5 }}>
                <Typography variant="caption" color={lowStockProducts.length > 0 ? 'error.main' : 'warning.main'} fontWeight="bold">
                  {lowStockProducts.length > 0 ? 'Urgent attention required' : 'Inventory stable'}
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Target Progress & Quick Delivery Status Chips */}
      <Card sx={{ borderRadius: 3, mb: 3 }}>
        <CardContent>
          <Grid container spacing={3} alignItems="center">
            <Grid item xs={12} md={5}>
              <Typography variant="subtitle2" fontWeight="bold" color="text.primary" gutterBottom>
                TODAY'S SALES PROGRESS (₹{todaySales.toLocaleString()} / ₹{targetSales.toLocaleString()})
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Box sx={{ width: '100%' }}>
                  <LinearProgress variant="determinate" value={salesProgressPct} sx={{ height: 10, borderRadius: 5, backgroundColor: 'rgba(98, 0, 238, 0.1)', '& .MuiLinearProgress-bar': { backgroundColor: '#6200ee' } }} />
                </Box>
                <Typography variant="body2" fontWeight="bold" color="text.primary">
                  {salesProgressPct.toFixed(0)}%
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={12} md={7}>
              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', justifyContent: { md: 'flex-end' } }}>
                <Chip icon={<Layers size={14} />} label={`Pending: ${statusCounts['Pending'] || 0}`} color="warning" variant="outlined" size="small" />
                <Chip icon={<Layers size={14} />} label={`Packed: ${statusCounts['Packed'] || 0}`} color="primary" variant="outlined" size="small" />
                <Chip icon={<Layers size={14} />} label={`Out for Delivery: ${statusCounts['Out for Delivery'] || 0}`} color="info" variant="outlined" size="small" />
                <Chip icon={<Layers size={14} />} label={`Delivered: ${statusCounts['Delivered'] || 0}`} color="success" variant="outlined" size="small" />
              </Box>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Charts Section */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        {/* Sales & Orders Area Chart */}
        <Grid item xs={12} lg={8}>
          <Card sx={{ borderRadius: 3, p: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3, px: 1 }}>
              <Typography variant="subtitle1" fontWeight="bold" color="text.primary">
                Weekly Revenue & Demand Trend
              </Typography>
              <Chip label="Live Analytics" size="small" color="primary" sx={{ backgroundColor: 'rgba(98, 0, 238, 0.08)', color: '#6200ee', fontWeight: 'bold' }} />
            </Box>
            <Box sx={{ height: 300, width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={salesTrends} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorSales" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#6200ee" stopOpacity={0.2}/>
                      <stop offset="95%" stopColor="#6200ee" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={11} tickLine={false} />
                  <YAxis stroke="#94a3b8" fontSize={11} tickLine={false} />
                  <Tooltip contentStyle={{ borderRadius: 8 }} />
                  <Area type="monotone" dataKey="sales" name="Sales (₹)" stroke="#6200ee" strokeWidth={2} fillOpacity={1} fill="url(#colorSales)" />
                </AreaChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>

        {/* Categories Pie Chart */}
        <Grid item xs={12} lg={4}>
          <Card sx={{ borderRadius: 3, p: 2 }}>
            <Typography variant="subtitle1" fontWeight="bold" color="text.primary" sx={{ mb: 3, px: 1 }}>
              Top Selling Categories
            </Typography>
            <Box sx={{ height: 220, width: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={categoryDistribution}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={4}
                    dataKey="value"
                  >
                    {categoryDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value) => `₹${value.toLocaleString()}`} />
                </PieChart>
              </ResponsiveContainer>
            </Box>
            <Box sx={{ mt: 1, display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 1 }}>
              {categoryDistribution.map((entry, index) => (
                <Box key={entry.name} sx={{ display: 'flex', alignItems: 'center', gap: 1, px: 1 }}>
                  <Box sx={{ width: 10, height: 10, borderRadius: '50%', backgroundColor: COLORS[index % COLORS.length] }} />
                  <Typography variant="caption" fontWeight="bold" color="text.secondary" noWrap>
                    {entry.name}
                  </Typography>
                </Box>
              ))}
            </Box>
          </Card>
        </Grid>
      </Grid>

      {/* Low Stock Alerts & Today's Sales Summary */}
      <Grid container spacing={3}>
        {/* Low Stock Alerts */}
        <Grid item xs={12} md={5}>
          <Card sx={{ borderRadius: 3, p: 2, height: '100%' }}>
            <Typography variant="subtitle1" fontWeight="bold" color="text.primary" sx={{ mb: 2, px: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
              <AlertTriangle size={18} color="#ef4444" />
              Low Stock Replenishment Tracker
            </Typography>
            {lowStockProducts.length === 0 ? (
              <Alert severity="success" sx={{ mx: 1 }}>
                All inventory levels are safe.
              </Alert>
            ) : (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5, maxHeight: 320, overflowY: 'auto', px: 1 }}>
                {lowStockProducts.map(p => (
                  <Box key={p.id} sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 1.5, border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
                    <Box sx={{ minWidth: 0 }}>
                      <Typography variant="body2" fontWeight="bold" noWrap>
                        {p.name}
                      </Typography>
                      <Typography variant="caption" color="error.main" fontWeight="bold">
                        Only {p.inventory} left
                      </Typography>
                    </Box>
                    <Button variant="contained" size="small" onClick={() => onRestock(p.id)} sx={{ textTransform: 'none', py: 0.5, px: 1.5, backgroundColor: '#10b981', '&:hover': { backgroundColor: '#0e9f6e' }, color: 'white', fontWeight: 'bold' }}>
                      Restock +50
                    </Button>
                  </Box>
                ))}
              </Box>
            )}
          </Card>
        </Grid>

        {/* Today's Sales Table */}
        <Grid item xs={12} md={7}>
          <Card sx={{ borderRadius: 3, p: 2, height: '100%' }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2, px: 1 }}>
              <Typography variant="subtitle1" fontWeight="bold" color="text.primary">
                Fulfillment Activity Queue
              </Typography>
              <Button size="small" onClick={() => onNavigateToTab('orders')} sx={{ fontWeight: 'bold' }}>
                View Queue
              </Button>
            </Box>
            <TableContainer component={Paper} elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
              <Table size="small">
                <TableHead sx={{ backgroundColor: 'action.hover' }}>
                  <TableRow>
                    <TableCell sx={{ fontWeight: 'bold' }}>Order ID</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>Customer</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>Total</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {orders.slice(0, 5).map((o) => (
                    <TableRow key={o.id} hover>
                      <TableCell sx={{ fontWeight: 'bold' }}>{o.id}</TableCell>
                      <TableCell>{o.customerName}</TableCell>
                      <TableCell sx={{ fontWeight: 'bold' }}>₹{o.total}</TableCell>
                      <TableCell>
                        <Chip
                          label={o.status}
                          size="small"
                          color={
                            o.status === 'Delivered' ? 'success' :
                            o.status === 'Pending' ? 'warning' :
                            o.status === 'Packed' ? 'primary' : 'info'
                          }
                          variant="outlined"
                          sx={{ fontWeight: 'bold', height: 20, fontSize: '0.65rem' }}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
