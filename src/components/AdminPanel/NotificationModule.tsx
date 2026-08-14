import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Card, CardContent, Grid, Button, TextField, MenuItem, 
  Select, FormControl, InputLabel, Switch, FormControlLabel, Chip, Table, 
  TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Alert, CircularProgress, Tabs, Tab
} from '@mui/material';
import { Send, AlertTriangle, Bell, Mail, MessageSquare, Smartphone, Shield, RefreshCw, FileText } from 'lucide-react';

export default function NotificationModule() {
  const [tabIndex, setTabIndex] = useState(0);

  // Broadcast Form State
  const [targetRole, setTargetRole] = useState('ALL');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [category, setCategory] = useState('PROMO');
  const [isEmergency, setIsEmergency] = useState(false);
  const [selectedChannels, setSelectedChannels] = useState<string[]>(['IN_APP', 'PUSH']);
  const [broadcastLoading, setBroadcastLoading] = useState(false);
  const [broadcastAlert, setBroadcastAlert] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // Logs & Templates state
  const [logs, setLogs] = useState<any[]>([]);
  const [templates, setTemplates] = useState<any[]>([]);
  const [logsLoading, setLogsLoading] = useState(false);

  // Fetch Logs & Templates
  const fetchLogsAndTemplates = async () => {
    try {
      setLogsLoading(true);
      const [logsRes, templatesRes] = await Promise.all([
        fetch('/api/notifications/logs'),
        fetch('/api/notifications/templates')
      ]);

      if (logsRes.ok) {
        const logsData = await logsRes.json();
        setLogs(Array.isArray(logsData) ? logsData : []);
      }

      if (templatesRes.ok) {
        const templatesData = await templatesRes.json();
        setTemplates(Array.isArray(templatesData) ? templatesData : []);
      }
    } catch (err) {
      console.error("Error fetching notification logs/templates:", err);
    } finally {
      setLogsLoading(false);
    }
  };

  useEffect(() => {
    fetchLogsAndTemplates();
  }, []);

  const handleChannelToggle = (channel: string) => {
    if (selectedChannels.includes(channel)) {
      if (selectedChannels.length === 1) return; // keep at least 1
      setSelectedChannels(selectedChannels.filter(c => c !== channel));
    } else {
      setSelectedChannels([...selectedChannels, channel]);
    }
  };

  const handleSendBroadcast = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !body.trim()) {
      setBroadcastAlert({ type: 'error', message: 'Title and Message body are required' });
      return;
    }

    try {
      setBroadcastLoading(true);
      setBroadcastAlert(null);

      const res = await fetch('/api/notifications/broadcast', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          targetRole,
          title,
          body,
          category,
          isEmergency,
          channels: selectedChannels
        })
      });

      const data = await res.json();
      if (res.ok) {
        setBroadcastAlert({ type: 'success', message: `Successfully dispatched broadcast to ${data.recipientCount || 'all'} recipients!` });
        setTitle('');
        setBody('');
        fetchLogsAndTemplates();
      } else {
        setBroadcastAlert({ type: 'error', message: data.error || 'Failed to dispatch notification broadcast' });
      }
    } catch (err: any) {
      setBroadcastAlert({ type: 'error', message: err.message || 'Error connecting to broadcast gateway' });
    } finally {
      setBroadcastLoading(false);
    }
  };

  return (
    <Box sx={{ p: 3, spaceY: 3 }}>
      {/* Title */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h5" sx={{ fontWeight: 'bold', display: 'flex', alignItems: 'center', gap: 1 }}>
            <Bell className="w-6 h-6 text-emerald-400" />
            Communication & Notification Hub
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Multi-Channel Dispatcher (Socket.IO, Push/FCM, Email, SMS) & Real-Time Audit Logs
          </Typography>
        </Box>

        <Button 
          variant="outlined" 
          onClick={fetchLogsAndTemplates}
          startIcon={<RefreshCw className="w-4 h-4" />}
          sx={{ borderRadius: 2 }}
        >
          Refresh Logs
        </Button>
      </Box>

      {/* Tabs */}
      <Tabs 
        value={tabIndex} 
        onChange={(_, val) => setTabIndex(val)}
        sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}
      >
        <Tab label="Broadcast & Emergency Alert" icon={<Send className="w-4 h-4" />} iconPosition="start" />
        <Tab label="System Notification Templates" icon={<FileText className="w-4 h-4" />} iconPosition="start" />
        <Tab label="Audit & Dispatch Logs" icon={<Shield className="w-4 h-4" />} iconPosition="start" />
      </Tabs>

      {/* TAB 0: Broadcast Center */}
      {tabIndex === 0 && (
        <Grid container spacing={3}>
          <Grid item xs={12} md={7}>
            <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
              <CardContent sx={{ p: 3 }}>
                <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Send className="w-5 h-5 text-emerald-400" /> Send Broadcast Message
                </Typography>

                {broadcastAlert && (
                  <Alert severity={broadcastAlert.type} sx={{ mb: 2 }} onClose={() => setBroadcastAlert(null)}>
                    {broadcastAlert.message}
                  </Alert>
                )}

                <form onSubmit={handleSendBroadcast}>
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6}>
                      <FormControl fullWidth size="small">
                        <InputLabel>Target Audience</InputLabel>
                        <Select
                          value={targetRole}
                          label="Target Audience"
                          onChange={e => setTargetRole(e.target.value)}
                        >
                          <MenuItem value="ALL">All Users (Broadcast)</MenuItem>
                          <MenuItem value="CUSTOMER">Customers Only</MenuItem>
                          <MenuItem value="RIDER">Delivery Partners Only</MenuItem>
                          <MenuItem value="STORE_MANAGER">Store Managers Only</MenuItem>
                          <MenuItem value="ADMIN">System Admins</MenuItem>
                        </Select>
                      </FormControl>
                    </Grid>

                    <Grid item xs={12} sm={6}>
                      <FormControl fullWidth size="small">
                        <InputLabel>Category Topic</InputLabel>
                        <Select
                          value={category}
                          label="Category Topic"
                          onChange={e => setCategory(e.target.value)}
                        >
                          <MenuItem value="PROMO">Promotion / Offer</MenuItem>
                          <MenuItem value="ORDER">Order Updates</MenuItem>
                          <MenuItem value="DELIVERY">Delivery Status</MenuItem>
                          <MenuItem value="WALLET">Wallet & Cashback</MenuItem>
                          <MenuItem value="SYSTEM">System & Maintenance</MenuItem>
                          <MenuItem value="INVENTORY">Inventory Alert</MenuItem>
                        </Select>
                      </FormControl>
                    </Grid>

                    <Grid item xs={12}>
                      <TextField
                        fullWidth
                        size="small"
                        label="Notification Title"
                        placeholder="e.g. ⚡ Flash Sale: 50% OFF Mangoes!"
                        value={title}
                        onChange={e => setTitle(e.target.value)}
                        required
                      />
                    </Grid>

                    <Grid item xs={12}>
                      <TextField
                        fullWidth
                        multiline
                        rows={3}
                        label="Message Body"
                        placeholder="Type message content here..."
                        value={body}
                        onChange={e => setBody(e.target.value)}
                        required
                      />
                    </Grid>

                    <Grid item xs={12}>
                      <Typography variant="subtitle2" sx={{ fontWeight: 'bold', mb: 1, color: 'text.secondary' }}>
                        Dispatch Channels
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                        {[
                          { id: 'IN_APP', label: 'In-App Banner', icon: <Bell className="w-4 h-4" /> },
                          { id: 'PUSH', label: 'Push (FCM)', icon: <Smartphone className="w-4 h-4" /> },
                          { id: 'EMAIL', label: 'Email', icon: <Mail className="w-4 h-4" /> },
                          { id: 'SMS', label: 'SMS Gateway', icon: <MessageSquare className="w-4 h-4" /> }
                        ].map(ch => {
                          const active = selectedChannels.includes(ch.id);
                          return (
                            <Chip
                              key={ch.id}
                              icon={ch.icon}
                              label={ch.label}
                              clickable
                              color={active ? "primary" : "default"}
                              variant={active ? "filled" : "outlined"}
                              onClick={() => handleChannelToggle(ch.id)}
                            />
                          );
                        })}
                      </Box>
                    </Grid>

                    <Grid item xs={12}>
                      <FormControlLabel
                        control={
                          <Switch
                            checked={isEmergency}
                            onChange={e => setIsEmergency(e.target.checked)}
                            color="error"
                          />
                        }
                        label={
                          <Box sx={{ display: 'flex', itemsCenter: 'center', gap: 0.5 }}>
                            <AlertTriangle className="w-4 h-4 text-rose-500" />
                            <Typography variant="body2" sx={{ fontWeight: 'bold', color: isEmergency ? 'error.main' : 'text.primary' }}>
                              Emergency Override (Bypasses Quiet Hours & Mute)
                            </Typography>
                          </Box>
                        }
                      />
                    </Grid>

                    <Grid item xs={12}>
                      <Button
                        type="submit"
                        variant="contained"
                        fullWidth
                        size="large"
                        disabled={broadcastLoading}
                        color={isEmergency ? "error" : "primary"}
                        startIcon={broadcastLoading ? <CircularProgress size={20} color="inherit" /> : <Send className="w-5 h-5" />}
                        sx={{ py: 1.5, fontWeight: 'bold', borderRadius: 2 }}
                      >
                        {broadcastLoading ? "Dispatching..." : isEmergency ? "DISPATCH EMERGENCY BROADCAST" : "Dispatch Broadcast"}
                      </Button>
                    </Grid>
                  </Grid>
                </form>
              </CardContent>
            </Card>
          </Grid>

          {/* Quick Metrics */}
          <Grid item xs={12} md={5}>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider', bgcolor: 'background.paper' }}>
                  <CardContent>
                    <Typography variant="subtitle2" color="text.secondary">Total Sent Logs</Typography>
                    <Typography variant="h4" sx={{ fontWeight: 'bold', color: 'emerald.400', mt: 1 }}>
                      {logs.length}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">Recorded in Postgres notification_logs</Typography>
                  </CardContent>
                </Card>
              </Grid>

              <Grid item xs={12}>
                <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider', bgcolor: 'background.paper' }}>
                  <CardContent>
                    <Typography variant="subtitle2" color="text.secondary">Active Templates</Typography>
                    <Typography variant="h4" sx={{ fontWeight: 'bold', color: 'purple.400', mt: 1 }}>
                      {templates.length}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">Dynamic templates loaded from database</Typography>
                  </CardContent>
                </Card>
              </Grid>
            </Grid>
          </Grid>
        </Grid>
      )}

      {/* TAB 1: System Templates */}
      {tabIndex === 1 && (
        <Grid container spacing={2}>
          {templates.map(tpl => (
            <Grid item xs={12} sm={6} md={4} key={tpl.id || tpl.code}>
              <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider', height: '100%' }}>
                <CardContent>
                  <Box sx={{ display: 'flex', justifyBetween: 'space-between', alignItems: 'center', mb: 1 }}>
                    <Chip label={tpl.category} size="small" color="secondary" variant="outlined" />
                    <Chip label={tpl.code} size="small" color="primary" sx={{ fontFamily: 'monospace', fontWeight: 'bold' }} />
                  </Box>
                  <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mt: 1 }}>{tpl.titleTemplate}</Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mt: 1, fontFamily: 'monospace', fontSize: 12 }}>
                    {tpl.bodyTemplate}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      {/* TAB 2: Audit Logs */}
      {tabIndex === 2 && (
        <TableContainer component={Paper} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
          <Table size="small">
            <TableHead sx={{ bgcolor: 'action.hover' }}>
              <TableRow>
                <TableCell sx={{ fontWeight: 'bold' }}>Recipient</TableCell>
                <TableCell sx={{ fontWeight: 'bold' }}>Channel</TableCell>
                <TableCell sx={{ fontWeight: 'bold' }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 'bold' }}>Notification ID / Details</TableCell>
                <TableCell sx={{ fontWeight: 'bold' }}>Dispatched At</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {logs.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} align="center" sx={{ py: 4, color: 'text.secondary' }}>
                    No dispatch logs recorded yet.
                  </TableCell>
                </TableRow>
              ) : (
                logs.map(log => (
                  <TableRow key={log.id} hover>
                    <TableCell sx={{ fontFamily: 'monospace', fontSize: 12 }}>{log.userId || log.recipient}</TableCell>
                    <TableCell><Chip label={log.channel} size="small" variant="outlined" /></TableCell>
                    <TableCell>
                      <Chip 
                        label={log.status} 
                        size="small" 
                        color={log.status === 'SUCCESS' || log.status === 'SENT' || log.status === 'DELIVERED' ? 'success' : 'error'} 
                      />
                    </TableCell>
                    <TableCell sx={{ fontSize: 12 }}>{log.notificationId || log.errorReason || 'OK'}</TableCell>
                    <TableCell sx={{ fontSize: 11, color: 'text.secondary' }}>
                      {new Date(log.createdAt || Date.now()).toLocaleString()}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  );
}
