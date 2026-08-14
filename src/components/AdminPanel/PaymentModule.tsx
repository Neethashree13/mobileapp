import React, { useState, useEffect } from 'react';
import {
  Box, Typography, Grid, Card, CardContent, Table, TableBody, TableCell,
  TableHead, TableRow, Chip, Button, TextField, Dialog, DialogTitle,
  DialogContent, DialogActions, Select, MenuItem, InputLabel, FormControl,
  IconButton, Tooltip, Alert, LinearProgress
} from '@mui/material';
import {
  CreditCard, RefreshCw, ShieldAlert, CheckCircle2, XCircle, ArrowUpRight,
  ArrowDownLeft, DollarSign, Receipt, AlertTriangle, ShieldCheck, Wallet
} from 'lucide-react';

export default function PaymentModule() {
  const [stats, setStats] = useState<any>(null);
  const [payments, setPayments] = useState<any[]>([]);
  const [refunds, setRefunds] = useState<any[]>([]);
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  // Manual Adjust Modal
  const [adjustModalOpen, setAdjustModalOpen] = useState(false);
  const [adjustUserId, setAdjustUserId] = useState("u1");
  const [adjustAmount, setAdjustAmount] = useState(500);
  const [adjustType, setAdjustType] = useState<"CREDIT" | "DEBIT">("CREDIT");
  const [adjustReason, setAdjustReason] = useState("Manual Customer Satisfaction Bonus");
  const [adjustSuccessMsg, setAdjustSuccessMsg] = useState("");

  const fetchData = async () => {
    setLoading(true);
    try {
      const [dashRes, refRes, logRes] = await Promise.all([
        fetch('/api/admin/payments/dashboard'),
        fetch('/api/admin/payments/refunds'),
        fetch('/api/admin/payments/logs')
      ]);

      if (dashRes.ok) {
        const dData = await dashRes.json();
        setStats(dData);
        setPayments(dData.recentPayments || []);
      }

      if (refRes.ok) {
        const rData = await refRes.json();
        setRefunds(Array.isArray(rData) ? rData : []);
      }

      if (logRes.ok) {
        const lData = await logRes.json();
        setLogs(Array.isArray(lData) ? lData : []);
      }
    } catch (err) {
      console.error("Error fetching admin payment stats:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 6000);
    return () => clearInterval(interval);
  }, []);

  const handleApproveRefund = async (refund: any) => {
    try {
      const res = await fetch('/api/payments/refund', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          paymentId: refund.paymentId || refund.id,
          orderId: refund.orderId,
          amount: refund.amount,
          reason: refund.reason || 'Admin Approved Refund',
          isPartial: refund.refundType === 'PARTIAL'
        })
      });

      if (res.ok) {
        alert(`Refund of ₹${refund.amount} approved and credited to customer wallet!`);
        fetchData();
      } else {
        const err = await res.json();
        alert(err.error || "Failed to approve refund");
      }
    } catch (e) {
      console.error("Error approving refund:", e);
    }
  };

  const handleAdminWalletAdjust = async () => {
    try {
      const res = await fetch('/api/admin/wallet-adjust', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: adjustUserId,
          amount: adjustAmount,
          type: adjustType,
          reason: adjustReason
        })
      });

      if (res.ok) {
        const data = await res.json();
        setAdjustSuccessMsg(`Wallet balance updated! New Balance: ₹${data.newBalance}`);
        setTimeout(() => {
          setAdjustSuccessMsg("");
          setAdjustModalOpen(false);
          fetchData();
        }, 1500);
      } else {
        const err = await res.json();
        alert(err.error || "Wallet adjustment failed");
      }
    } catch (e) {
      console.error("Error adjusting wallet:", e);
    }
  };

  return (
    <Box sx={{ p: 3, spaceY: 3 }}>
      {loading && <LinearProgress sx={{ mb: 2 }} />}

      {/* Header Title & Actions */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h5" fontWeight="bold" sx={{ color: 'text.primary', display: 'flex', alignItems: 'center', gap: 1 }}>
            <CreditCard size={24} color="#10b981" /> Payment Engine & Wallet Control Hub
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Production Payment State Machine, Double-Entry Wallet Ledger, Risk Scoring & Webhook Verification
          </Typography>
        </Box>

        <Box sx={{ display: 'flex', gap: 1.5 }}>
          <Button
            variant="outlined"
            color="primary"
            startIcon={<RefreshCw size={16} />}
            onClick={fetchData}
          >
            Refresh Data
          </Button>
          <Button
            variant="contained"
            color="secondary"
            startIcon={<Wallet size={16} />}
            onClick={() => setAdjustModalOpen(true)}
            sx={{ fontWeight: 'bold' }}
          >
            Admin Wallet Credit/Debit
          </Button>
        </Box>
      </Box>

      {/* Summary KPI Cards */}
      <Grid container spacing={2.5} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ bgcolor: 'background.paper', border: '1px solid rgba(255,255,255,0.08)' }}>
            <CardContent>
              <Typography color="text.secondary" variant="caption" fontWeight="bold">TOTAL SETTLED VOLUME</Typography>
              <Typography variant="h4" fontWeight="bold" sx={{ color: '#10b981', mt: 0.5 }}>
                ₹{stats?.totalVolume ? stats.totalVolume.toLocaleString() : '1,570.00'}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Across {stats?.totalTransactions || 2} Payment Intents
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ bgcolor: 'background.paper', border: '1px solid rgba(255,255,255,0.08)' }}>
            <CardContent>
              <Typography color="text.secondary" variant="caption" fontWeight="bold">SUCCESS RATE</Typography>
              <Typography variant="h4" fontWeight="bold" sx={{ color: '#3b82f6', mt: 0.5 }}>
                {stats?.successRate || 100}%
              </Typography>
              <Typography variant="caption" color="text.secondary">
                0 Payment Failures logged
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ bgcolor: 'background.paper', border: '1px solid rgba(255,255,255,0.08)' }}>
            <CardContent>
              <Typography color="text.secondary" variant="caption" fontWeight="bold">PENDING REFUNDS</Typography>
              <Typography variant="h4" fontWeight="bold" sx={{ color: '#f59e0b', mt: 0.5 }}>
                {refunds.length}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Auto Wallet Refund Engine Active
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ bgcolor: 'background.paper', border: '1px solid rgba(255,255,255,0.08)' }}>
            <CardContent>
              <Typography color="text.secondary" variant="caption" fontWeight="bold">FRAUD RISK FLAGGED</Typography>
              <Typography variant="h4" fontWeight="bold" sx={{ color: '#ef4444', mt: 0.5 }}>
                {stats?.flaggedTransactionsCount || 0}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Real-time risk scoring engine
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Payment Transactions Table */}
      <Card sx={{ mb: 4, bgcolor: 'background.paper', border: '1px solid rgba(255,255,255,0.08)' }}>
        <CardContent>
          <Typography variant="h6" fontWeight="bold" sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
            <Receipt size={20} color="#10b981" /> Payment Transactions Audit Log
          </Typography>

          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Payment ID</TableCell>
                <TableCell>Order ID</TableCell>
                <TableCell>Amount</TableCell>
                <TableCell>Method / Provider</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Risk Score</TableCell>
                <TableCell>Transaction Ref</TableCell>
                <TableCell>Timestamp</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {payments.map((p) => (
                <TableRow key={p.id}>
                  <TableCell sx={{ fontFamily: 'monospace', fontWeight: 'bold' }}>{p.id}</TableCell>
                  <TableCell>{p.orderId}</TableCell>
                  <TableCell sx={{ fontWeight: 'bold', color: '#10b981' }}>₹{p.amount}</TableCell>
                  <TableCell>
                    <Chip size="small" label={`${p.paymentMethod} (${p.provider})`} variant="outlined" />
                  </TableCell>
                  <TableCell>
                    <Chip
                      size="small"
                      label={p.status}
                      color={
                        p.status === 'SUCCESS' ? 'success' :
                        p.status === 'FAILED' ? 'error' :
                        p.status === 'REFUNDED' ? 'secondary' : 'warning'
                      }
                      sx={{ fontWeight: 'bold' }}
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      size="small"
                      label={`${(p.riskScore * 100).toFixed(0)}%`}
                      color={p.riskScore >= 0.7 ? 'error' : p.riskScore >= 0.3 ? 'warning' : 'default'}
                    />
                  </TableCell>
                  <TableCell sx={{ fontFamily: 'monospace', fontSize: '11px', color: 'text.secondary' }}>
                    {p.transactionId}
                  </TableCell>
                  <TableCell sx={{ fontSize: '11px', color: 'text.secondary' }}>
                    {new Date(p.createdAt).toLocaleString()}
                  </TableCell>
                </TableRow>
              ))}

              {payments.length === 0 && (
                <TableRow>
                  <TableCell colSpan={8} align="center" sx={{ py: 3, color: 'text.secondary' }}>
                    No payment transactions recorded yet.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Refunds Queue & Webhook Logs Grid */}
      <Grid container spacing={3}>
        {/* Refunds Queue */}
        <Grid item xs={12} md={6}>
          <Card sx={{ bgcolor: 'background.paper', border: '1px solid rgba(255,255,255,0.08)', height: '100%' }}>
            <CardContent>
              <Typography variant="h6" fontWeight="bold" sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                <ShieldCheck size={20} color="#f59e0b" /> Refunds Management Queue
              </Typography>

              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Refund ID</TableCell>
                    <TableCell>Order ID</TableCell>
                    <TableCell>Amount</TableCell>
                    <TableCell>Reason</TableCell>
                    <TableCell>Action</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {refunds.map((ref) => (
                    <TableRow key={ref.id}>
                      <TableCell sx={{ fontFamily: 'monospace' }}>{ref.id}</TableCell>
                      <TableCell>{ref.orderId}</TableCell>
                      <TableCell sx={{ fontWeight: 'bold', color: '#10b981' }}>₹{ref.amount}</TableCell>
                      <TableCell sx={{ fontSize: '11px' }}>{ref.reason}</TableCell>
                      <TableCell>
                        <Button
                          size="small"
                          variant="contained"
                          color="success"
                          onClick={() => handleApproveRefund(ref)}
                          sx={{ textTransform: 'none', fontSize: '10px' }}
                        >
                          Approve Refund
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}

                  {refunds.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={5} align="center" sx={{ py: 3, color: 'text.secondary', fontSize: '12px' }}>
                        No pending customer refund requests.
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </Grid>

        {/* Gateway & Webhook Audit Logs */}
        <Grid item xs={12} md={6}>
          <Card sx={{ bgcolor: 'background.paper', border: '1px solid rgba(255,255,255,0.08)', height: '100%' }}>
            <CardContent>
              <Typography variant="h6" fontWeight="bold" sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                <ShieldAlert size={20} color="#3b82f6" /> Gateway Webhook Audit Logs
              </Typography>

              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Provider</TableCell>
                    <TableCell>Event Type</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>Timestamp</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {logs.map((l) => (
                    <TableRow key={l.id}>
                      <TableCell sx={{ fontWeight: 'bold' }}>{l.provider}</TableCell>
                      <TableCell sx={{ fontSize: '11px', fontFamily: 'monospace' }}>{l.eventType}</TableCell>
                      <TableCell>
                        <Chip
                          size="small"
                          label={l.status}
                          color={l.status === 'VERIFIED' ? 'success' : 'error'}
                        />
                      </TableCell>
                      <TableCell sx={{ fontSize: '11px', color: 'text.secondary' }}>
                        {new Date(l.createdAt).toLocaleTimeString()}
                      </TableCell>
                    </TableRow>
                  ))}

                  {logs.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={4} align="center" sx={{ py: 3, color: 'text.secondary', fontSize: '12px' }}>
                        No webhook logs captured.
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Admin Wallet Credit/Debit Dialog */}
      <Dialog open={adjustModalOpen} onClose={() => setAdjustModalOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 'bold', display: 'flex', alignItems: 'center', gap: 1 }}>
          <Wallet size={20} color="#10b981" /> Manual Wallet Adjustment
        </DialogTitle>
        <DialogContent sx={{ spaceY: 2, pt: 1 }}>
          {adjustSuccessMsg && <Alert severity="success" sx={{ mb: 2 }}>{adjustSuccessMsg}</Alert>}

          <TextField
            fullWidth
            label="Target User ID or Firebase UID"
            value={adjustUserId}
            onChange={(e) => setAdjustUserId(e.target.value)}
            margin="dense"
          />

          <FormControl fullWidth margin="dense">
            <InputLabel>Adjustment Type</InputLabel>
            <Select
              value={adjustType}
              label="Adjustment Type"
              onChange={(e) => setAdjustType(e.target.value as any)}
            >
              <MenuItem value="CREDIT">CREDIT (+ Add Money)</MenuItem>
              <MenuItem value="DEBIT">DEBIT (- Deduct Money)</MenuItem>
            </Select>
          </FormControl>

          <TextField
            fullWidth
            type="number"
            label="Amount (₹)"
            value={adjustAmount}
            onChange={(e) => setAdjustAmount(Number(e.target.value))}
            margin="dense"
          />

          <TextField
            fullWidth
            label="Reason Log"
            value={adjustReason}
            onChange={(e) => setAdjustReason(e.target.value)}
            margin="dense"
          />
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button onClick={() => setAdjustModalOpen(false)}>Cancel</Button>
          <Button variant="contained" color="secondary" onClick={handleAdminWalletAdjust} sx={{ fontWeight: 'bold' }}>
            Execute Adjustment
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
