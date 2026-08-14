import React, { useState } from 'react';
import {
  Box, Card, CardContent, Typography, Grid, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, Button, Chip, Tabs, Tab,
  Dialog, DialogTitle, DialogContent, DialogActions, Divider, List, ListItem, ListItemText, Alert
} from '@mui/material';
import {
  Clock, Package, Truck, CheckCircle2, XCircle, RefreshCw, FileText, Printer, ShieldCheck
} from 'lucide-react';
import { Order } from './mockData';

interface OrderModuleProps {
  orders: Order[];
  onUpdateOrderStatus: (orderId: string, newStatus: Order['status']) => void;
}

export default function OrderModule({ orders, onUpdateOrderStatus }: OrderModuleProps) {
  const [selectedTab, setSelectedTab] = useState<number>(0);
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [invoiceOpen, setInvoiceOpen] = useState(false);

  const statuses: (Order['status'] | 'All')[] = [
    'All', 'Pending', 'Packed', 'Out for Delivery', 'Delivered', 'Cancelled', 'Returned'
  ];

  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setSelectedTab(newValue);
  };

  const filteredOrders = orders.filter(o => {
    const currentStatusFilter = statuses[selectedTab];
    if (currentStatusFilter === 'All') return true;
    return o.status === currentStatusFilter;
  });

  const getStatusIcon = (status: Order['status']) => {
    switch (status) {
      case 'Pending': return <Clock size={16} style={{ color: '#f59e0b' }} />;
      case 'Packed': return <Package size={16} style={{ color: '#3b82f6' }} />;
      case 'Out for Delivery': return <Truck size={16} style={{ color: '#06b6d4' }} />;
      case 'Delivered': return <CheckCircle2 size={16} style={{ color: '#10b981' }} />;
      case 'Cancelled': return <XCircle size={16} style={{ color: '#ef4444' }} />;
      case 'Returned': return <RefreshCw size={16} style={{ color: '#a855f7' }} />;
    }
  };

  const getStatusColor = (status: Order['status']) => {
    switch (status) {
      case 'Pending': return 'warning';
      case 'Packed': return 'primary';
      case 'Out for Delivery': return 'info';
      case 'Delivered': return 'success';
      case 'Cancelled': return 'error';
      case 'Returned': return 'secondary';
    }
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <Box>
      {/* Title */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h5" fontWeight="bold">
          Order Logistics & Invoice Dispatch
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Approve pending, monitor dispatch flows, and generate itemized invoices
        </Typography>
      </Box>

      {/* Tabs */}
      <Paper sx={{ mb: 3, borderRadius: 3 }}>
        <Tabs
          value={selectedTab}
          onChange={handleTabChange}
          indicatorColor="primary"
          textColor="primary"
          variant="scrollable"
          scrollButtons="auto"
          sx={{ borderBottom: 1, borderColor: 'divider' }}
        >
          {statuses.map((s, idx) => (
            <Tab key={idx} label={s} sx={{ fontWeight: 'bold', fontSize: '0.8rem' }} />
          ))}
        </Tabs>
      </Paper>

      {/* Main Grid: Left Side Table, Right Side Detail Box */}
      <Grid container spacing={3}>
        {/* Orders Table */}
        <Grid item xs={12} lg={selectedOrder ? 7 : 12}>
          <TableContainer component={Paper} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
            <Table>
              <TableHead sx={{ backgroundColor: 'action.hover' }}>
                <TableRow>
                  <TableCell sx={{ fontWeight: 'bold' }}>Order ID</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Customer</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Created</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Total</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Status</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredOrders.length === 0 ? (
                  <TableRow>
                    <td colSpan={5} style={{ textAlign: 'center', padding: '24px 0' }}>
                      <Typography variant="body2" color="text.secondary">
                        No orders found in this fulfillment state.
                      </Typography>
                    </td>
                  </TableRow>
                ) : (
                  filteredOrders.map((o) => (
                    <TableRow
                      key={o.id}
                      hover
                      onClick={() => setSelectedOrder(o)}
                      selected={selectedOrder?.id === o.id}
                      sx={{ cursor: 'pointer', '&.Mui-selected': { backgroundColor: 'rgba(98, 0, 238, 0.08)' } }}
                    >
                      <TableCell sx={{ fontWeight: 'bold' }}>{o.id}</TableCell>
                      <TableCell>{o.customerName}</TableCell>
                      <TableCell>{new Date(o.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</TableCell>
                      <TableCell sx={{ fontWeight: 'bold' }}>₹{o.total}</TableCell>
                      <TableCell>
                        <Chip
                          icon={getStatusIcon(o.status)}
                          label={o.status}
                          size="small"
                          color={getStatusColor(o.status)}
                          variant="outlined"
                          sx={{ fontWeight: 'bold' }}
                        />
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>

        {/* Selected Order details Panel */}
        {selectedOrder && (
          <Grid item xs={12} lg={5}>
            <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
              <CardContent>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                  <Typography variant="subtitle1" fontWeight="bold">
                    Order details: {selectedOrder.id}
                  </Typography>
                  <Button
                    startIcon={<FileText size={14} />}
                    size="small"
                    variant="outlined"
                    onClick={() => setInvoiceOpen(true)}
                  >
                    Invoice
                  </Button>
                </Box>
                <Divider sx={{ mb: 2 }} />

                {/* Details list */}
                <Grid container spacing={1.5} sx={{ mb: 2, fontSize: '0.85rem' }}>
                  <Grid item xs={4}>
                    <Typography variant="caption" color="text.secondary">CUSTOMER</Typography>
                    <Typography variant="body2" fontWeight="bold">{selectedOrder.customerName}</Typography>
                  </Grid>
                  <Grid item xs={8}>
                    <Typography variant="caption" color="text.secondary">SECURED ADDR</Typography>
                    <Typography variant="body2" noWrap sx={{ maxWidth: '100%' }}>{selectedOrder.address}</Typography>
                  </Grid>
                  <Grid item xs={4}>
                    <Typography variant="caption" color="text.secondary">PAYMENT METHOD</Typography>
                    <Typography variant="body2" fontWeight="bold">{selectedOrder.paymentMethod}</Typography>
                  </Grid>
                  <Grid item xs={8}>
                    <Typography variant="caption" color="text.secondary">RIDER ASSIGNED</Typography>
                    <Typography variant="body2" fontWeight="bold">{selectedOrder.riderName || 'Unassigned / Ground Team'}</Typography>
                  </Grid>
                </Grid>

                <Divider sx={{ mb: 2 }} />

                {/* Item List */}
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1, fontWeight: 'bold' }}>ITEMIZED ITEMS</Typography>
                <List size="small" disablePadding sx={{ mb: 2 }}>
                  {selectedOrder.items.map((it, idx) => (
                    <ListItem key={idx} sx={{ p: 0, py: 0.5 }}>
                      <ListItemText
                        primary={`${it.name}`}
                        secondary={`Quantity: ${it.quantity} x ₹${it.price}`}
                        primaryTypographyProps={{ variant: 'body2', fontWeight: 'bold' }}
                        secondaryTypographyProps={{ variant: 'caption' }}
                      />
                      <Typography variant="body2" fontWeight="bold">
                        ₹{it.quantity * it.price}
                      </Typography>
                    </ListItem>
                  ))}
                </List>

                <Divider sx={{ mb: 2 }} />

                {/* Pricing Summary */}
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, mb: 3 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Typography variant="body2" color="text.secondary">Subtotal</Typography>
                    <Typography variant="body2">₹{selectedOrder.total - selectedOrder.tax + selectedOrder.discount}</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Typography variant="body2" color="text.secondary">Fulfillment Tax</Typography>
                    <Typography variant="body2">₹{selectedOrder.tax}</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Typography variant="body2" color="error">Campaign Discount</Typography>
                    <Typography variant="body2" color="error">-₹{selectedOrder.discount}</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 1 }}>
                    <Typography variant="body2" fontWeight="bold">Final Bill Total</Typography>
                    <Typography variant="body2" fontWeight="bold" color="primary.main">₹{selectedOrder.total}</Typography>
                  </Box>
                </Box>

                {/* Status transitions */}
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1, fontWeight: 'bold' }}>UPDATE SHIPMENT LIFECYCLE</Typography>
                <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                  {selectedOrder.status === 'Pending' && (
                    <Button variant="contained" size="small" fullWidth color="primary" onClick={() => onUpdateOrderStatus(selectedOrder.id, 'Packed')} sx={{ backgroundColor: '#3b82f6' }}>
                      Mark Packed & Sealed
                    </Button>
                  )}
                  {selectedOrder.status === 'Packed' && (
                    <Button variant="contained" size="small" fullWidth color="info" onClick={() => onUpdateOrderStatus(selectedOrder.id, 'Out for Delivery')} sx={{ backgroundColor: '#06b6d4' }}>
                      Assign Rider & Dispatch
                    </Button>
                  )}
                  {selectedOrder.status === 'Out for Delivery' && (
                    <Button variant="contained" size="small" fullWidth color="success" onClick={() => onUpdateOrderStatus(selectedOrder.id, 'Delivered')} sx={{ backgroundColor: '#10b981' }}>
                      Verify OTP & Mark Delivered
                    </Button>
                  )}
                  {selectedOrder.status !== 'Delivered' && selectedOrder.status !== 'Cancelled' && (
                    <Button variant="outlined" size="small" color="error" onClick={() => onUpdateOrderStatus(selectedOrder.id, 'Cancelled')}>
                      Cancel Order
                    </Button>
                  )}
                  {selectedOrder.status === 'Delivered' && (
                    <Button variant="outlined" size="small" fullWidth color="secondary" onClick={() => onUpdateOrderStatus(selectedOrder.id, 'Returned')}>
                      Return Settlement Pipeline
                    </Button>
                  )}
                  {(selectedOrder.status === 'Cancelled' || selectedOrder.status === 'Returned') && (
                    <Alert severity="info" sx={{ width: '100%', py: 0.5 }}>
                      This order is fully settled and archived.
                    </Alert>
                  )}
                </Box>
              </CardContent>
            </Card>
          </Grid>
        )}
      </Grid>

      {/* Invoice Generator printable modal */}
      {selectedOrder && (
        <Dialog open={invoiceOpen} onClose={() => setInvoiceOpen(false)} maxWidth="sm" fullWidth>
          <DialogContent sx={{ p: 4 }}>
            {/* Printable Area Wrapper */}
            <Box id="printable-invoice" sx={{ fontFamily: 'monospace' }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 3 }}>
                <Box>
                  <Typography variant="h6" fontWeight="bold">FLASHCART AI INC.</Typography>
                  <Typography variant="caption" sx={{ display: 'block', color: 'text.secondary' }}>HQ Central Hub, Koramangala 3rd Sector</Typography>
                  <Typography variant="caption" sx={{ display: 'block', color: 'text.secondary' }}>GSTIN: 29AABCX9481A1Z0</Typography>
                </Box>
                <Box sx={{ textAlign: 'right' }}>
                  <Typography variant="h6" fontWeight="bold" color="primary">TAX INVOICE</Typography>
                  <Typography variant="body2" fontWeight="bold">{selectedOrder.id}</Typography>
                  <Typography variant="caption" sx={{ display: 'block' }}>Date: {new Date(selectedOrder.createdAt).toLocaleDateString()}</Typography>
                </Box>
              </Box>

              <Divider sx={{ mb: 2, borderStyle: 'dashed' }} />

              <Grid container spacing={2} sx={{ mb: 3 }}>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 'bold' }}>BILLED TO:</Typography>
                  <Typography variant="body2" fontWeight="bold">{selectedOrder.customerName}</Typography>
                  <Typography variant="caption" sx={{ display: 'block' }}>{selectedOrder.customerEmail}</Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 'bold' }}>SHIPPED VIA:</Typography>
                  <Typography variant="body2" fontWeight="bold">{selectedOrder.riderName || 'FlashCart Logistics'}</Typography>
                  <Typography variant="caption" sx={{ display: 'block' }}>{selectedOrder.address}</Typography>
                </Grid>
              </Grid>

              <TableContainer component={Paper} variant="outlined" sx={{ mb: 3 }}>
                <Table size="small">
                  <TableHead sx={{ backgroundColor: 'action.hover' }}>
                    <TableRow>
                      <TableCell sx={{ fontWeight: 'bold' }}>Product</TableCell>
                      <TableCell sx={{ fontWeight: 'bold' }}>Qty</TableCell>
                      <TableCell sx={{ fontWeight: 'bold' }}>Price</TableCell>
                      <TableCell sx={{ fontWeight: 'bold' }} align="right">Sub</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {selectedOrder.items.map((it, index) => (
                      <TableRow key={index}>
                        <TableCell>{it.name}</TableCell>
                        <TableCell>{it.quantity}</TableCell>
                        <TableCell>₹{it.price}</TableCell>
                        <TableCell align="right">₹{it.price * it.quantity}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>

              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                <Box>
                  <Typography variant="caption" sx={{ display: 'flex', alignItems: 'center', gap: 0.5, color: 'success.main', fontWeight: 'bold' }}>
                    <ShieldCheck size={14} /> SECURED SYSTEM FULFILLED
                  </Typography>
                </Box>
                <Box sx={{ width: 220, fontSize: '0.8rem' }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="caption">GST Tax (18% CGST/SGST):</Typography>
                    <Typography variant="caption" fontWeight="bold">₹{selectedOrder.tax}</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography variant="caption">Discounts:</Typography>
                    <Typography variant="caption" fontWeight="bold" color="error">-₹{selectedOrder.discount}</Typography>
                  </Box>
                  <Divider sx={{ my: 1, borderStyle: 'dashed' }} />
                  <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Typography variant="body2" fontWeight="bold">Total Bill Paid:</Typography>
                    <Typography variant="body2" fontWeight="bold">₹{selectedOrder.total}</Typography>
                  </Box>
                </Box>
              </Box>

              <Divider sx={{ mb: 2, borderStyle: 'dashed' }} />
              <Typography variant="caption" align="center" color="text.secondary" sx={{ display: 'block' }}>
                Thank you for choosing FlashCart AI. Standard terms and conditions apply.
              </Typography>
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setInvoiceOpen(false)} color="inherit">
              Close
            </Button>
            <Button startIcon={<Printer size={16} />} onClick={handlePrint} variant="contained" color="primary">
              Print / Save PDF
            </Button>
          </DialogActions>
        </Dialog>
      )}
    </Box>
  );
}
