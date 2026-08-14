import React, { useState } from 'react';
import {
  Box, Card, CardContent, Typography, Grid, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, Avatar, Button, Dialog,
  DialogTitle, DialogContent, DialogActions, TextField, Divider, List, ListItem, ListItemText, Chip
} from '@mui/material';
import { Search, Wallet, Star, ShieldCheck, ShoppingBag } from 'lucide-react';
import { Customer } from './mockData';

interface CustomerModuleProps {
  customers: Customer[];
  onAdjustWallet: (customerId: string, amount: number) => void;
  onAdjustPoints: (customerId: string, points: number) => void;
}

export default function CustomerModule({ customers, onAdjustWallet, onAdjustPoints }: CustomerModuleProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);

  // Adjusted modals
  const [walletOpen, setWalletOpen] = useState(false);
  const [adjustAmount, setAdjustAmount] = useState<number>(500);

  const [pointsOpen, setPointsOpen] = useState(false);
  const [adjustPoints, setAdjustPoints] = useState<number>(100);

  const filteredCustomers = customers.filter(c =>
    c.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    c.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleWalletSubmit = () => {
    if (selectedCustomer && adjustAmount) {
      onAdjustWallet(selectedCustomer.id, adjustAmount);
      setWalletOpen(false);
      // Synchronize modal state
      setSelectedCustomer(prev => prev ? { ...prev, walletBalance: prev.walletBalance + adjustAmount } : null);
    }
  };

  const handlePointsSubmit = () => {
    if (selectedCustomer && adjustPoints) {
      onAdjustPoints(selectedCustomer.id, adjustPoints);
      setPointsOpen(false);
      setSelectedCustomer(prev => prev ? { ...prev, loyaltyPoints: prev.loyaltyPoints + adjustPoints } : null);
    }
  };

  return (
    <Box>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h5" fontWeight="bold">
          Consumer Profiles & Loyalty Engine
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Track customer orders, manage virtual wallets, and award loyalty points
        </Typography>
      </Box>

      {/* Search Filter */}
      <Card sx={{ mb: 3, borderRadius: 3 }}>
        <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
          <TextField
            fullWidth
            size="small"
            placeholder="Search consumer files by legal name, email hash..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            InputProps={{
              startAdornment: (
                <Box sx={{ color: 'text.secondary', mr: 1, display: 'flex' }}>
                  <Search size={18} />
                </Box>
              )
            }}
          />
        </CardContent>
      </Card>

      <Grid container spacing={3}>
        {/* Customer Table */}
        <Grid item xs={12} lg={selectedCustomer ? 7 : 12}>
          <TableContainer component={Paper} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
            <Table>
              <TableHead sx={{ backgroundColor: 'action.hover' }}>
                <TableRow>
                  <TableCell sx={{ fontWeight: 'bold' }}>Consumer</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Wallet Balance</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Loyalty Index</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Join Date</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Frequency</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredCustomers.map((c) => (
                  <TableRow
                    key={c.id}
                    hover
                    onClick={() => setSelectedCustomer(c)}
                    selected={selectedCustomer?.id === c.id}
                    sx={{ cursor: 'pointer', '&.Mui-selected': { backgroundColor: 'rgba(98, 0, 238, 0.08)' } }}
                  >
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                        <Avatar src={c.avatar} sx={{ width: 36, height: 36 }} />
                        <Box>
                          <Typography variant="body2" fontWeight="bold">{c.name}</Typography>
                          <Typography variant="caption" color="text.secondary">{c.email}</Typography>
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="bold">₹{c.walletBalance}</Typography>
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                        <Star size={14} style={{ color: '#fbbf24', fill: '#fbbf24' }} />
                        <Typography variant="body2" fontWeight="bold">{c.loyaltyPoints} pts</Typography>
                      </Box>
                    </TableCell>
                    <TableCell>{c.joinDate}</TableCell>
                    <TableCell>
                      <Chip label={`${c.orderCount} Orders`} size="small" sx={{ fontWeight: 'bold', fontSize: '0.7rem' }} />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>

        {/* Selected Customer Drawer */}
        {selectedCustomer && (
          <Grid item xs={12} lg={5}>
            <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2.5 }}>
                  <Avatar src={selectedCustomer.avatar} sx={{ width: 56, height: 56 }} />
                  <Box>
                    <Typography variant="subtitle1" fontWeight="bold">{selectedCustomer.name}</Typography>
                    <Typography variant="caption" color="text.secondary">{selectedCustomer.phone}</Typography>
                  </Box>
                </Box>
                <Divider sx={{ mb: 2 }} />

                {/* Substats */}
                <Grid container spacing={2} sx={{ mb: 3 }}>
                  <Grid item xs={6}>
                    <Paper variant="outlined" sx={{ p: 1.5, textAlign: 'center', borderRadius: 2 }}>
                      <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>WALLET WALLET</Typography>
                      <Typography variant="body1" fontWeight="bold" color="primary.main">₹{selectedCustomer.walletBalance}</Typography>
                      <Button size="small" startIcon={<Wallet size={12} />} onClick={() => setWalletOpen(true)} sx={{ mt: 1, textTransform: 'none', fontWeight: 'bold' }}>Refill</Button>
                    </Paper>
                  </Grid>
                  <Grid item xs={6}>
                    <Paper variant="outlined" sx={{ p: 1.5, textAlign: 'center', borderRadius: 2 }}>
                      <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>LOYALTY BALANCE</Typography>
                      <Typography variant="body1" fontWeight="bold" color="secondary.main">{selectedCustomer.loyaltyPoints} pts</Typography>
                      <Button size="small" startIcon={<Star size={12} />} onClick={() => setPointsOpen(true)} color="secondary" sx={{ mt: 1, textTransform: 'none', fontWeight: 'bold' }}>Award</Button>
                    </Paper>
                  </Grid>
                </Grid>

                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1, fontWeight: 'bold' }}>REGISTERED ADDRESS FILES</Typography>
                <List size="small" disablePadding sx={{ mb: 2 }}>
                  {selectedCustomer.addresses.map((addr, idx) => (
                    <ListItem key={idx} sx={{ p: 0, py: 0.5 }}>
                      <ListItemText
                        primary={`Address File #${idx + 1}`}
                        secondary={addr}
                        primaryTypographyProps={{ variant: 'caption', fontWeight: 'bold' }}
                        secondaryTypographyProps={{ variant: 'body2', sx: { color: 'text.primary' } }}
                      />
                    </ListItem>
                  ))}
                </List>

                <Button variant="outlined" size="small" color="inherit" fullWidth onClick={() => setSelectedCustomer(null)}>
                  Close Customer File
                </Button>
              </CardContent>
            </Card>
          </Grid>
        )}
      </Grid>

      {/* Wallet refill modal */}
      <Dialog open={walletOpen} onClose={() => setWalletOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 'bold' }}>Refill Customer Wallet Balance</DialogTitle>
        <DialogContent dividers>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Provide manual compensation or wallet balance topups for <strong>{selectedCustomer?.name}</strong>.
          </Typography>
          <TextField
            fullWidth
            type="number"
            label="Load Amount (INR)"
            value={adjustAmount}
            onChange={(e) => setAdjustAmount(Number(e.target.value))}
            InputProps={{
              startAdornment: <Typography sx={{ mr: 1, color: 'text.secondary' }}>₹</Typography>
            }}
          />
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button onClick={() => setWalletOpen(false)} color="inherit">Cancel</Button>
          <Button onClick={handleWalletSubmit} variant="contained" color="success">Commit Balance Load</Button>
        </DialogActions>
      </Dialog>

      {/* Points Award Modal */}
      <Dialog open={pointsOpen} onClose={() => setPointsOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 'bold' }}>Award Loyalty Points</DialogTitle>
        <DialogContent dividers>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Award promotional or loyalty reward points to <strong>{selectedCustomer?.name}</strong> for active, eco-conscious purchases.
          </Typography>
          <TextField
            fullWidth
            type="number"
            label="Points to Award"
            value={adjustPoints}
            onChange={(e) => setAdjustPoints(Number(e.target.value))}
          />
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button onClick={() => setPointsOpen(false)} color="inherit">Cancel</Button>
          <Button onClick={handlePointsSubmit} variant="contained" color="secondary">Award Points</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
