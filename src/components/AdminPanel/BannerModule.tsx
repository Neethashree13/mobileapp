import React, { useState } from 'react';
import {
  Box, Card, CardContent, Typography, Button, Grid, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, TextField, Dialog, DialogTitle, DialogContent,
  DialogActions, Select, MenuItem, FormControl, InputLabel, Snackbar, CardMedia, CardActions, IconButton, Chip
} from '@mui/material';
import { Plus, Trash2, Edit, CalendarDays } from 'lucide-react';
import { AppBanner } from './mockData';

interface BannerModuleProps {
  banners: AppBanner[];
  onAddBanner: (banner: AppBanner) => void;
  onToggleBannerStatus: (bannerId: string) => void;
  onDeleteBanner: (bannerId: string) => void;
}

export default function BannerModule({ banners, onAddBanner, onToggleBannerStatus, onDeleteBanner }: BannerModuleProps) {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [formTitle, setFormTitle] = useState('');
  const [formType, setFormType] = useState<'Home' | 'Campaign' | 'Festival'>('Home');
  const [formImage, setFormImage] = useState('https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500&q=80');
  const [formLink, setFormLink] = useState('/categories/bakery');

  const [toastOpen, setToastOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formTitle || !formImage) return;

    const payload: AppBanner = {
      id: `b_${Date.now()}`,
      title: formTitle,
      type: formType,
      imageUrl: formImage,
      linkTo: formLink,
      status: 'Active'
    };

    onAddBanner(payload);
    setDialogOpen(false);
    setToastMessage(`Banner campaign "${formTitle}" initiated!`);
    setToastOpen(true);
  };

  const handleDelete = (id: string) => {
    onDeleteBanner(id);
    setToastMessage('Banner campaign archived.');
    setToastOpen(true);
  };

  return (
    <Box>
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h5" fontWeight="bold">
            Promotional & Campaign Visual Banners
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Set interactive banners, direct traffic pathways, and manage active festivals
          </Typography>
        </Box>
        <Button startIcon={<Plus size={16} />} variant="contained" sx={{ backgroundColor: '#6200ee' }} onClick={() => setDialogOpen(true)}>
          Add Banner Listing
        </Button>
      </Box>

      {/* Grid of Graphic Cards */}
      <Grid container spacing={3}>
        {banners.map((b) => (
          <Grid item xs={12} sm={6} md={4} key={b.id}>
            <Card sx={{ borderRadius: 3, height: '100%', display: 'flex', flexDirection: 'column', border: '1px solid', borderColor: 'divider' }}>
              <CardMedia
                component="img"
                height="160"
                image={b.imageUrl}
                alt={b.title}
                sx={{ objectFit: 'cover' }}
              />
              <CardContent sx={{ flexGrow: 1 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1.5 }}>
                  <Chip
                    label={b.type}
                    size="small"
                    sx={{ fontWeight: 'bold', fontSize: '0.65rem', backgroundColor: 'rgba(98, 0, 238, 0.08)', color: '#6200ee' }}
                  />
                  <Chip
                    label={b.status}
                    size="small"
                    color={
                      b.status === 'Active' ? 'success' :
                      b.status === 'Scheduled' ? 'info' : 'default'
                    }
                    sx={{ fontWeight: 'bold', fontSize: '0.65rem' }}
                  />
                </Box>
                <Typography variant="body1" fontWeight="bold" sx={{ mb: 1 }}>
                  {b.title}
                </Typography>
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', wordBreak: 'break-all' }}>
                  Target route: {b.linkTo}
                </Typography>
              </CardContent>
              <CardActions sx={{ borderTop: '1px solid', borderColor: 'divider', justifyContent: 'space-between', p: 1.5 }}>
                <Button size="small" onClick={() => onToggleBannerStatus(b.id)} sx={{ textTransform: 'none', fontWeight: 'bold' }}>
                  Toggle Status
                </Button>
                <IconButton size="small" color="error" onClick={() => handleDelete(b.id)}>
                  <Trash2 size={16} />
                </IconButton>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* Creation Dialog */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="xs" fullWidth>
        <form onSubmit={handleSubmit}>
          <DialogTitle sx={{ fontWeight: 'bold' }}>Initiate Campaign Banner</DialogTitle>
          <DialogContent dividers>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  label="Campaign Title / Heading"
                  value={formTitle}
                  onChange={(e) => setFormTitle(e.target.value)}
                />
              </Grid>
              <Grid item xs={12}>
                <FormControl fullWidth required>
                  <InputLabel>Target Channel Type</InputLabel>
                  <Select
                    value={formType}
                    label="Target Channel Type"
                    onChange={(e) => setFormType(e.target.value as any)}
                  >
                    <MenuItem value="Home">Home Hero Banners</MenuItem>
                    <MenuItem value="Campaign">Special Campaign Banners</MenuItem>
                    <MenuItem value="Festival">Festival & Regional Banners</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  label="Campaign Image Asset URL"
                  value={formImage}
                  onChange={(e) => setFormImage(e.target.value)}
                />
              </Grid>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  label="Target Path Redirection"
                  value={formLink}
                  onChange={(e) => setFormLink(e.target.value)}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setDialogOpen(false)} color="inherit">Cancel</Button>
            <Button type="submit" variant="contained" sx={{ backgroundColor: '#6200ee' }}>Deploy Banner</Button>
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
