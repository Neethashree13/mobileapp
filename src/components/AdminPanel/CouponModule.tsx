import React, { useState } from 'react';
import {
  Box, Card, CardContent, Typography, Button, Grid, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, TextField, Dialog, DialogTitle, DialogContent,
  DialogActions, Select, MenuItem, FormControl, InputLabel, Snackbar, Switch, Chip, InputAdornment
} from '@mui/material';
import { Plus, Ticket, Calendar, AlertCircle } from 'lucide-react';
import { Coupon } from './mockData';

interface CouponModuleProps {
  coupons: Coupon[];
  onCreateCoupon: (coupon: Coupon) => void;
  onToggleCouponStatus: (couponId: string) => void;
}

export default function CouponModule({ coupons, onCreateCoupon, onToggleCouponStatus }: CouponModuleProps) {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [formCode, setFormCode] = useState('');
  const [formType, setFormType] = useState<'percentage' | 'flat'>('percentage');
  const [formValue, setFormValue] = useState(10);
  const [formExpiry, setFormExpiry] = useState('2026-08-31');
  const [formLimit, setFormLimit] = useState(1000);
  const [formMinOrder, setFormMinOrder] = useState(200);

  // Notifications
  const [toastOpen, setToastOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  const handleOpenCreate = () => {
    setFormCode('');
    setFormType('percentage');
    setFormValue(10);
    setFormExpiry('2026-08-31');
    setFormLimit(1000);
    setFormMinOrder(200);
    setDialogOpen(true);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formCode || formValue <= 0) {
      setToastMessage('Error: Code and valid discount value are required.');
      setToastOpen(true);
      return;
    }

    const payload: Coupon = {
      id: `cp_${Date.now()}`,
      code: formCode.toUpperCase(),
      type: formType,
      value: Number(formValue),
      expiry: formExpiry,
      usageLimit: Number(formLimit),
      usageCount: 0,
      minOrderValue: Number(formMinOrder),
      status: 'Active'
    };

    onCreateCoupon(payload);
    setDialogOpen(false);
    setToastMessage(`Coupon Code ${payload.code} registered!`);
    setToastOpen(true);
  };

  return (
    <Box>
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h5" fontWeight="bold">
            Promotional Coupons & Voucher Codes
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Deploy flat discount percentages, set limits, and define target expiries
          </Typography>
        </Box>
        <Button startIcon={<Plus size={16} />} variant="contained" sx={{ backgroundColor: '#6200ee' }} onClick={handleOpenCreate}>
          Create Coupon
        </Button>
      </Box>

      {/* Coupon List */}
      <TableContainer component={Paper} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
        <Table>
          <TableHead sx={{ backgroundColor: 'action.hover' }}>
            <TableRow>
              <TableCell sx={{ fontWeight: 'bold' }}>Coupon Code</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Discount Type</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Discount Value</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Min Order Requirement</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Usage Index</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Expiry Timeline</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Availability</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {coupons.map((c) => (
              <TableRow key={c.id} hover>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Ticket size={16} style={{ color: '#6200ee' }} />
                    <Typography variant="body2" fontWeight="bold">{c.code}</Typography>
                  </Box>
                </TableCell>
                <TableCell>
                  <Chip
                    label={c.type === 'percentage' ? 'Percentage' : 'Flat Discount'}
                    size="small"
                    color={c.type === 'percentage' ? 'primary' : 'secondary'}
                    variant="outlined"
                    sx={{ fontWeight: 'bold', fontSize: '0.65rem' }}
                  />
                </TableCell>
                <TableCell>
                  <Typography variant="body2" fontWeight="bold">
                    {c.type === 'percentage' ? `${c.value}%` : `₹${c.value}`}
                  </Typography>
                </TableCell>
                <TableCell>₹{c.minOrderValue}</TableCell>
                <TableCell>
                  <Typography variant="body2" fontWeight="bold">{c.usageCount} / {c.usageLimit}</Typography>
                </TableCell>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, color: 'text.secondary', fontSize: '0.8rem' }}>
                    <Calendar size={14} /> {c.expiry}
                  </Box>
                </TableCell>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Switch
                      checked={c.status === 'Active'}
                      onChange={() => onToggleCouponStatus(c.id)}
                      color="success"
                      size="small"
                    />
                    <Chip
                      label={c.status}
                      size="small"
                      color={
                        c.status === 'Active' ? 'success' :
                        c.status === 'Expired' ? 'error' : 'default'
                      }
                      sx={{ fontWeight: 'bold', fontSize: '0.6rem', height: 18 }}
                    />
                  </Box>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Creation Dialog */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="xs" fullWidth>
        <form onSubmit={handleSubmit}>
          <DialogTitle sx={{ fontWeight: 'bold' }}>Create Promotional Voucher</DialogTitle>
          <DialogContent dividers>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  label="Voucher Code"
                  placeholder="e.g. MONSOON20"
                  value={formCode}
                  onChange={(e) => setFormCode(e.target.value)}
                  inputProps={{ style: { textTransform: 'uppercase' } }}
                />
              </Grid>
              <Grid item xs={6}>
                <FormControl fullWidth required>
                  <InputLabel>Discount Type</InputLabel>
                  <Select
                    value={formType}
                    label="Discount Type"
                    onChange={(e) => setFormType(e.target.value as 'percentage' | 'flat')}
                  >
                    <MenuItem value="percentage">Percentage (%)</MenuItem>
                    <MenuItem value="flat">Flat Cash (₹)</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  required
                  type="number"
                  label="Discount Value"
                  value={formValue}
                  onChange={(e) => setFormValue(Number(e.target.value))}
                />
              </Grid>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  type="number"
                  label="Minimum Order Value Req."
                  value={formMinOrder}
                  onChange={(e) => setFormMinOrder(Number(e.target.value))}
                  InputProps={{
                    startAdornment: <InputAdornment position="start">₹</InputAdornment>
                  }}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  required
                  type="number"
                  label="Usage Limit Cap"
                  value={formLimit}
                  onChange={(e) => setFormLimit(Number(e.target.value))}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  required
                  type="date"
                  label="Expiry Timeline"
                  value={formExpiry}
                  onChange={(e) => setFormExpiry(e.target.value)}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setDialogOpen(false)} color="inherit">Cancel</Button>
            <Button type="submit" variant="contained" sx={{ backgroundColor: '#6200ee' }}>Confirm Voucher</Button>
          </DialogActions>
        </form>
      </Dialog>

      <Snackbar
        open={toastOpen}
        autoHideDuration={4000}
        onClose={() => setToastOpen(false)}
        message={toastMessage}
      />
    </Box>
  );
}
