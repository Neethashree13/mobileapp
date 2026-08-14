import React, { useState } from 'react';
import {
  Box, Card, CardContent, TextField, Button, Typography,
  Dialog, DialogTitle, DialogContent, DialogActions,
  Grid, Alert, CircularProgress, IconButton, Paper
} from '@mui/material';
import { Shield, KeyRound, Lock, Send, Key, CheckCircle, ArrowLeft } from 'lucide-react';

interface LoginModuleProps {
  onLoginSuccess: (user: { name: string; role: string }) => void;
}

export default function LoginModule({ onLoginSuccess }: LoginModuleProps) {
  const [step, setStep] = useState<'login' | 'otp'>('login');
  const [email, setEmail] = useState('admin@flashcart.ai');
  const [password, setPassword] = useState('password123');
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);

  // Forgot password dialog state
  const [forgotOpen, setForgotOpen] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotSuccess, setForgotSuccess] = useState('');

  const handleLoginSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError('Please enter both email and password.');
      return;
    }
    setError('');
    setLoading(true);

    setTimeout(() => {
      setLoading(false);
      // Proceed to 2FA OTP verification
      setStep('otp');
    }, 1200);
  };

  const handleOtpChange = (index: number, val: string) => {
    if (isNaN(Number(val))) return;
    const nextOtp = [...otp];
    nextOtp[index] = val.substring(val.length - 1);
    setOtp(nextOtp);

    // Auto-focus next field
    if (val && index < 5) {
      const nextInput = document.getElementById(`otp-input-${index + 1}`);
      nextInput?.focus();
    }
  };

  const handleOtpSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const code = otp.join('');
    if (code.length < 6) {
      setError('Please enter the full 6-digit verification code.');
      return;
    }
    setError('');
    setLoading(true);

    setTimeout(() => {
      setLoading(false);
      if (code === '123456' || code === '000000' || code.length === 6) {
        onLoginSuccess({ name: 'Super Administrator', role: 'Super Admin' });
      } else {
        setError('Invalid OTP code. Please try again (Tip: use any 6 digits).');
      }
    }, 1000);
  };

  const handleForgotPassword = () => {
    if (!forgotEmail) {
      setError('Please provide your registered administrator email.');
      return;
    }
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setForgotSuccess(`A secure reset link has been dispatched to ${forgotEmail}. Please check your inbox.`);
    }, 1200);
  };

  return (
    <Box sx={{ minHeight: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', p: 3 }}>
      <Paper elevation={12} sx={{ width: '100%', maxWidth: 450, borderRadius: 4, overflow: 'hidden' }}>
        {/* Decorative Top Bar */}
        <Box sx={{ height: 6, bg: 'linear-gradient(90deg, #6200ee 0%, #10b981 100%)', backgroundColor: '#6200ee' }} />

        <Card sx={{ border: 'none', boxShadow: 'none' }}>
          <CardContent sx={{ p: 4 }}>
            {/* Header / Logo */}
            <Box sx={{ textAlign: 'center', mb: 4 }}>
              <Box sx={{ display: 'inline-flex', p: 1.5, borderRadius: 3, backgroundColor: 'rgba(98, 0, 238, 0.08)', color: '#6200ee', mb: 2 }}>
                <Shield size={36} />
              </Box>
              <Typography variant="h5" fontWeight="bold" color="text.primary">
                FlashCart AI
              </Typography>
              <Typography variant="subtitle2" color="text.secondary" sx={{ mt: 0.5 }}>
                SECURED GROUND CONTROL SYSTEM
              </Typography>
            </Box>

            {error && (
              <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError('')}>
                {error}
              </Alert>
            )}

            {step === 'login' ? (
              <form onSubmit={handleLoginSubmit}>
                <Typography variant="body1" fontWeight="600" sx={{ mb: 2 }}>
                  Administrator Access
                </Typography>
                
                <TextField
                  fullWidth
                  label="Secured Email Address"
                  variant="outlined"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  sx={{ mb: 2.5 }}
                  InputProps={{
                    startAdornment: (
                      <Box sx={{ color: 'text.secondary', mr: 1.5, display: 'flex' }}>
                        <KeyRound size={20} />
                      </Box>
                    ),
                  }}
                />

                <TextField
                  fullWidth
                  label="Password"
                  type="password"
                  variant="outlined"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  sx={{ mb: 1.5 }}
                  InputProps={{
                    startAdornment: (
                      <Box sx={{ color: 'text.secondary', mr: 1.5, display: 'flex' }}>
                        <Lock size={20} />
                      </Box>
                    ),
                  }}
                />

                <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 3 }}>
                  <Button variant="text" size="small" onClick={() => { setForgotOpen(true); setForgotSuccess(''); }} sx={{ fontWeight: 'bold' }}>
                    Forgot Password?
                  </Button>
                </Box>

                <Button
                  fullWidth
                  type="submit"
                  variant="contained"
                  size="large"
                  disabled={loading}
                  sx={{ py: 1.5, borderRadius: 2, fontWeight: 'bold', textTransform: 'none', backgroundColor: '#6200ee', '&:hover': { backgroundColor: '#5000c0' } }}
                >
                  {loading ? <CircularProgress size={24} color="inherit" /> : 'Request OTP Code'}
                </Button>
              </form>
            ) : (
              <form onSubmit={handleOtpSubmit}>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  <IconButton onClick={() => setStep('login')} sx={{ mr: 1, p: 0.5 }}>
                    <ArrowLeft size={18} />
                  </IconButton>
                  <Typography variant="body1" fontWeight="600">
                    Two-Factor OTP Verification
                  </Typography>
                </Box>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                  A one-time verification pin has been triggered to your admin console (Hint: Enter any 6 digits).
                </Typography>

                <Grid container spacing={1.5} justifyContent="center" sx={{ mb: 3 }}>
                  {otp.map((digit, idx) => (
                    <Grid item key={idx} xs={2}>
                      <TextField
                        id={`otp-input-${idx}`}
                        variant="outlined"
                        value={digit}
                        onChange={(e) => handleOtpChange(idx, e.target.value)}
                        inputProps={{
                          style: { textAlign: 'center', fontWeight: 'bold', fontSize: '1.2rem', padding: '12px 0' },
                          maxLength: 1
                        }}
                      />
                    </Grid>
                  ))}
                </Grid>

                <Button
                  fullWidth
                  type="submit"
                  variant="contained"
                  size="large"
                  disabled={loading}
                  sx={{ py: 1.5, borderRadius: 2, fontWeight: 'bold', textTransform: 'none', backgroundColor: '#10b981', '&:hover': { backgroundColor: '#0e9f6e' } }}
                >
                  {loading ? <CircularProgress size={24} color="inherit" /> : 'Verify & Enter Dashboard'}
                </Button>
              </form>
            )}
          </CardContent>
        </Card>
      </Paper>

      {/* Forgot Password Dialog */}
      <Dialog open={forgotOpen} onClose={() => setForgotOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 'bold' }}>Reset Admin Credentials</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Provide your organizational email. We will verify your root credentials and send a cryptographically secured recovery key.
          </Typography>
          {forgotSuccess ? (
            <Alert severity="success" icon={<CheckCircle size={20} />} sx={{ mt: 1 }}>
              {forgotSuccess}
            </Alert>
          ) : (
            <TextField
              fullWidth
              autoFocus
              label="Admin Email Address"
              type="email"
              variant="outlined"
              value={forgotEmail}
              onChange={(e) => setForgotEmail(e.target.value)}
              sx={{ mt: 1 }}
            />
          )}
        </DialogContent>
        <DialogActions sx={{ p: 2, px: 3 }}>
          <Button onClick={() => setForgotOpen(false)} color="inherit">
            Close
          </Button>
          {!forgotSuccess && (
            <Button onClick={handleForgotPassword} variant="contained" disabled={loading} sx={{ backgroundColor: '#6200ee' }}>
              Send Recovery Link
            </Button>
          )}
        </DialogActions>
      </Dialog>
    </Box>
  );
}
