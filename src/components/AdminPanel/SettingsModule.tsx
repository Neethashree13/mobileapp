import React, { useState } from 'react';
import {
  Box, Card, CardContent, Typography, Grid, TextField, Button, Switch,
  FormControlLabel, Divider, Select, MenuItem, InputLabel, FormControl,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip, Snackbar
} from '@mui/material';
import { Store, ShieldCheck, Mail, Percent, Layers } from 'lucide-react';

export default function SettingsModule() {
  const [storeName, setStoreName] = useState('FlashCart HQ Hub');
  const [storeAddress, setStoreAddress] = useState('Sector 3, HSR Layout, Bangalore');
  const [cgst, setCgst] = useState(9);
  const [sgst, setSgst] = useState(9);

  // Toggle flags
  const [upiEnabled, setUpiEnabled] = useState(true);
  const [walletEnabled, setWalletEnabled] = useState(true);
  const [smsNotification, setSmsNotification] = useState(true);
  const [emailNotification, setEmailNotification] = useState(true);

  // Toast notifications
  const [toastOpen, setToastOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  // Mock roles
  const [admins, setAdmins] = useState([
    { id: 'u1', name: 'Super Administrator', role: 'Super Admin', email: 'admin@flashcart.ai', status: 'Active' },
    { id: 'u2', name: 'Divya Iyer', role: 'Operations Lead', email: 'divya@flashcart.ai', status: 'Active' },
    { id: 'u3', name: 'Rohan Sharma', role: 'Marketing Associate', email: 'rohan@flashcart.ai', status: 'Suspended' }
  ]);

  const handleSaveConfig = () => {
    setToastMessage('Global system configurations committed successfully!');
    setToastOpen(true);
  };

  const handleToggleAdminStatus = (id: string) => {
    setAdmins(prev => prev.map(a => {
      if (a.id === id) {
        return { ...a, status: a.status === 'Active' ? 'Suspended' : 'Active' };
      }
      return a;
    }));
    setToastMessage('Administrator access level updated.');
    setToastOpen(true);
  };

  return (
    <Box>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h5" fontWeight="bold">
          System Core & Role Settings
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Configure physical store locations, payment paths, tax brackets, and staff role permissions
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Core Store Settings */}
        <Grid item xs={12} md={6}>
          <Card sx={{ borderRadius: 3, mb: 3 }}>
            <CardContent>
              <Typography variant="subtitle1" fontWeight="bold" sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                <Store size={18} color="#6200ee" />
                Store Operations Settings
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    size="small"
                    label="Physical Hub Name"
                    value={storeName}
                    onChange={(e) => setStoreName(e.target.value)}
                  />
                </Grid>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    size="small"
                    label="Hub Center Address"
                    value={storeAddress}
                    onChange={(e) => setStoreAddress(e.target.value)}
                  />
                </Grid>
              </Grid>

              <Divider sx={{ my: 2 }} />

              <Typography variant="subtitle1" fontWeight="bold" sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                <Percent size={18} color="#10b981" />
                Fulfillment Tax Bracket Settings
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={6}>
                  <TextField
                    fullWidth
                    size="small"
                    type="number"
                    label="Central CGST (%)"
                    value={cgst}
                    onChange={(e) => setCgst(Number(e.target.value))}
                  />
                </Grid>
                <Grid item xs={6}>
                  <TextField
                    fullWidth
                    size="small"
                    type="number"
                    label="State SGST (%)"
                    value={sgst}
                    onChange={(e) => setSgst(Number(e.target.value))}
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>

          {/* Payment Gateways & SMS notifications */}
          <Card sx={{ borderRadius: 3 }}>
            <CardContent>
              <Typography variant="subtitle1" fontWeight="bold" sx={{ mb: 2 }}>
                Payment Gateways
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1, mb: 3 }}>
                <FormControlLabel
                  control={<Switch checked={upiEnabled} onChange={() => setUpiEnabled(!upiEnabled)} color="primary" />}
                  label="Direct UPI Integrations (PhonePe, GPay)"
                />
                <FormControlLabel
                  control={<Switch checked={walletEnabled} onChange={() => setWalletEnabled(!walletEnabled)} color="primary" />}
                  label="Secured Customer Digital Wallets"
                />
              </Box>

              <Divider sx={{ mb: 2 }} />

              <Typography variant="subtitle1" fontWeight="bold" sx={{ mb: 2 }}>
                System Notification Dispatches
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <FormControlLabel
                  control={<Switch checked={smsNotification} onChange={() => setSmsNotification(!smsNotification)} color="secondary" />}
                  label="SMS Order Dispatch Alerts"
                />
                <FormControlLabel
                  control={<Switch checked={emailNotification} onChange={() => setEmailNotification(!emailNotification)} color="secondary" />}
                  label="Weekly Tax & Sales E-Mail Reports"
                />
              </Box>

              <Button variant="contained" sx={{ mt: 3, backgroundColor: '#6200ee' }} onClick={handleSaveConfig} fullWidth>
                Commit Core Settings
              </Button>
            </CardContent>
          </Card>
        </Grid>

        {/* Roles and Admin User Permissions */}
        <Grid item xs={12} md={6}>
          <Card sx={{ borderRadius: 3, height: '100%' }}>
            <CardContent>
              <Typography variant="subtitle1" fontWeight="bold" sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                <ShieldCheck size={18} color="#6200ee" />
                Staff Role Permissions & Scope
              </Typography>
              <TableContainer component={Paper} elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
                <Table size="small">
                  <TableHead sx={{ backgroundColor: 'action.hover' }}>
                    <TableRow>
                      <TableCell sx={{ fontWeight: 'bold' }}>Administrator</TableCell>
                      <TableCell sx={{ fontWeight: 'bold' }}>Access Role</TableCell>
                      <TableCell align="center" sx={{ fontWeight: 'bold' }}>Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {admins.map((admin) => (
                      <TableRow key={admin.id} hover>
                        <TableCell>
                          <Typography variant="body2" fontWeight="bold">{admin.name}</Typography>
                          <Typography variant="caption" color="text.secondary">{admin.email}</Typography>
                        </TableCell>
                        <TableCell>
                          <Chip
                            label={admin.role}
                            size="small"
                            sx={{
                              fontWeight: 'bold',
                              fontSize: '0.65rem',
                              backgroundColor: admin.role === 'Super Admin' ? 'rgba(98, 0, 238, 0.08)' : 'rgba(16, 185, 129, 0.08)',
                              color: admin.role === 'Super Admin' ? '#6200ee' : '#10b981'
                            }}
                          />
                        </TableCell>
                        <TableCell align="center">
                          {admin.role !== 'Super Admin' ? (
                            <Button
                              size="small"
                              variant="text"
                              color={admin.status === 'Active' ? 'error' : 'success'}
                              onClick={() => handleToggleAdminStatus(admin.id)}
                              sx={{ textTransform: 'none', fontWeight: 'bold' }}
                            >
                              {admin.status === 'Active' ? 'Suspend' : 'Activate'}
                            </Button>
                          ) : (
                            <Typography variant="caption" color="text.secondary" fontWeight="bold">Protected Root</Typography>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Snackbar
        open={toastOpen}
        autoHideDuration={4000}
        onClose={() => setToastOpen(false)}
        message={toastMessage}
      />
    </Box>
  );
}
