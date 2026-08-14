import React, { useState } from 'react';
import {
  Box, Card, CardContent, Typography, Button, Grid, TextField,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Paper, IconButton, Dialog, DialogTitle, DialogContent, DialogActions,
  Select, MenuItem, FormControl, InputLabel, Alert, Snackbar, Tooltip,
  InputAdornment, Avatar
} from '@mui/material';
import {
  Search, Plus, Edit2, Trash2, Upload, Sparkles, Filter,
  CheckCircle, ArrowUpRight
} from 'lucide-react';
import { Product } from './mockData';

interface ProductModuleProps {
  products: Product[];
  onAddProduct: (product: Product) => void;
  onEditProduct: (product: Product) => void;
  onDeleteProduct: (productId: string) => void;
  onBulkUpload: (bulkProducts: Product[]) => void;
}

export default function ProductModule({ products, onAddProduct, onEditProduct, onDeleteProduct, onBulkUpload }: ProductModuleProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');

  // Modal / Dialog state
  const [dialogOpen, setDialogOpen] = useState(false);
  const [dialogMode, setDialogMode] = useState<'add' | 'edit'>('add');
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

  // Bulk Upload State
  const [bulkDialogOpen, setBulkDialogOpen] = useState(false);
  const [csvContent, setCsvContent] = useState('');
  const [bulkError, setBulkError] = useState('');

  // Toast notifications
  const [toastMessage, setToastMessage] = useState('');
  const [toastOpen, setToastOpen] = useState(false);

  // Form states
  const [formName, setFormName] = useState('');
  const [formCategory, setFormCategory] = useState('Fruits & Vegetables');
  const [formBrand, setFormBrand] = useState('');
  const [formPrice, setFormPrice] = useState(0);
  const [formUnit, setFormUnit] = useState('1 kg');
  const [formInventory, setFormInventory] = useState(50);
  const [formImage, setFormImage] = useState('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=120&q=80');
  const [formRating, setFormRating] = useState(4.5);
  const [formCarbon, setFormCarbon] = useState(0.5);
  const [formEco, setFormEco] = useState('B');

  const openAddDialog = () => {
    setDialogMode('add');
    setFormName('');
    setFormCategory('Fruits & Vegetables');
    setFormBrand('');
    setFormPrice(0);
    setFormUnit('1 kg');
    setFormInventory(50);
    setFormImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=120&q=80');
    setFormRating(4.5);
    setFormCarbon(0.5);
    setFormEco('B');
    setDialogOpen(true);
  };

  const openEditDialog = (p: Product) => {
    setDialogMode('edit');
    setSelectedProduct(p);
    setFormName(p.name);
    setFormCategory(p.category);
    setFormBrand(p.brand);
    setFormPrice(p.price);
    setFormUnit(p.unit);
    setFormInventory(p.inventory);
    setFormImage(p.image);
    setFormRating(p.rating);
    setFormCarbon(p.carbonEmission);
    setFormEco(p.ecoScore);
    setDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName || !formBrand || formPrice <= 0) {
      setToastMessage('Error: Name, brand, and positive pricing are required.');
      setToastOpen(true);
      return;
    }

    const payload: Product = {
      ...(dialogMode === 'edit' ? selectedProduct : {
        reviewsCount: 15,
        calories: 120,
        protein: 2.5,
        deliveryTimeMins: 10,
      }),
      id: dialogMode === 'add' ? `p_${Date.now()}` : selectedProduct!.id,
      name: formName,
      category: formCategory,
      brand: formBrand,
      price: Number(formPrice),
      unit: formUnit,
      inventory: Number(formInventory),
      image: formImage,
      rating: Number(formRating),
      carbonEmission: Number(formCarbon),
      ecoScore: formEco as any
    };

    try {
      if (dialogMode === 'add') {
        const res = await fetch('/api/admin/products', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        if (res.ok) {
          onAddProduct(payload);
          setToastMessage('Product appended to live PostgreSQL catalog successfully!');
        }
      } else {
        const res = await fetch(`/api/admin/products/${selectedProduct!.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        if (res.ok) {
          onEditProduct(payload);
          setToastMessage('Product catalog attributes synchronized to live DB!');
        }
      }
    } catch (err) {
      console.error("API error during product submit", err);
      if (dialogMode === 'add') onAddProduct(payload);
      else onEditProduct(payload);
    }
    setDialogOpen(false);
    setToastOpen(true);
  };

  const handleDelete = async (id: string) => {
    try {
      await fetch(`/api/admin/products/${id}`, { method: 'DELETE' });
    } catch (err) {
      console.error("API delete error:", err);
    }
    onDeleteProduct(id);
    setToastMessage('Product deleted from PostgreSQL database pipeline.');
    setToastOpen(true);
  };

  const handleSimulateBulkUpload = async () => {
    const parsedBulk: Product[] = [
      { id: 'p_b1', name: 'Premium Organic Strawberries', category: 'Fruits & Vegetables', brand: 'NatureFresh', price: 299, unit: '250g', inventory: 100, image: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&q=80', rating: 4.9, carbonEmission: 0.3, ecoScore: 'A', reviewsCount: 45, calories: 32, protein: 0.7, deliveryTimeMins: 10 },
      { id: 'p_b2', name: 'Fresh Italian Sourdough Croissants', category: 'Bakery & Dairy', brand: 'LaBoulangerie', price: 149, unit: '2 pcs', inventory: 80, image: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=120&q=80', rating: 4.8, carbonEmission: 0.5, ecoScore: 'B', reviewsCount: 110, calories: 280, protein: 6, deliveryTimeMins: 12 },
      { id: 'p_b3', name: 'Premium Cold Brew Concentrate', category: 'Beverages', brand: 'BrewCraft', price: 549, unit: '500ml', inventory: 40, image: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=120&q=80', rating: 4.9, carbonEmission: 0.7, ecoScore: 'B', reviewsCount: 75, calories: 5, protein: 0.1, deliveryTimeMins: 10 },
      { id: 'p_b4', name: 'Organic Roasted Almonds', category: 'Snacks & Cereal', brand: 'FitMeal', price: 380, unit: '200g', inventory: 120, image: 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=120&q=80', rating: 4.7, carbonEmission: 0.4, ecoScore: 'A', reviewsCount: 142, calories: 579, protein: 21, deliveryTimeMins: 10 }
    ];

    try {
      await fetch('/api/admin/products/import', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ products: parsedBulk })
      });
    } catch (err) {
      console.error("CSV import API error:", err);
    }

    onBulkUpload(parsedBulk);
    setBulkDialogOpen(false);
    setToastMessage('Bulk CSV Upload parsed & committed to PostgreSQL!');
    setToastOpen(true);
  };


  const filteredProducts = products.filter(p => {
    const matchSearch = p.name.toLowerCase().includes(searchTerm.toLowerCase()) || p.brand.toLowerCase().includes(searchTerm.toLowerCase());
    const matchCategory = selectedCategory === 'All' || p.category === selectedCategory;
    return matchSearch && matchCategory;
  });

  return (
    <Box>
      {/* Module Title */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h5" fontWeight="bold">
            Enterprise Product Catalog
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Manage real-time digital inventory, dynamic listings, and packaging specs
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 1.5 }}>
          <Button startIcon={<Upload size={16} />} variant="outlined" onClick={() => setBulkDialogOpen(true)}>
            Bulk Upload CSV
          </Button>
          <Button startIcon={<Plus size={16} />} variant="contained" sx={{ backgroundColor: '#6200ee' }} onClick={openAddDialog}>
            Add Product
          </Button>
        </Box>
      </Box>

      {/* Filter and Search Rail */}
      <Card sx={{ mb: 3, borderRadius: 3 }}>
        <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                size="small"
                placeholder="Search by product name, barcode, brand..."
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
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <FormControl fullWidth size="small">
                <InputLabel>Category Filter</InputLabel>
                <Select
                  value={selectedCategory}
                  label="Category Filter"
                  onChange={(e) => setSelectedCategory(e.target.value)}
                >
                  <MenuItem value="All">All Categories</MenuItem>
                  <MenuItem value="Fruits & Vegetables">Fruits & Vegetables</MenuItem>
                  <MenuItem value="Bakery & Dairy">Bakery & Dairy</MenuItem>
                  <MenuItem value="Beverages">Beverages</MenuItem>
                  <MenuItem value="Snacks & Cereal">Snacks & Cereal</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6} md={3} sx={{ textAlign: 'right' }}>
              <Typography variant="caption" fontWeight="bold" color="text.secondary">
                Showing {filteredProducts.length} of {products.length} Products
              </Typography>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Main Products Table */}
      <TableContainer component={Paper} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
        <Table size="medium">
          <TableHead sx={{ backgroundColor: 'action.hover' }}>
            <TableRow>
              <TableCell sx={{ fontWeight: 'bold' }}>Info</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Brand / Category</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Price</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Inventory</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Eco Specs</TableCell>
              <TableCell align="center" sx={{ fontWeight: 'bold' }}>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredProducts.map((p) => (
              <TableRow key={p.id} hover>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Avatar variant="rounded" src={p.image} sx={{ width: 44, height: 44 }} />
                    <Box>
                      <Typography variant="body2" fontWeight="bold">
                        {p.name}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {p.unit}
                      </Typography>
                    </Box>
                  </Box>
                </TableCell>
                <TableCell>
                  <Typography variant="body2" fontWeight="medium">
                    {p.brand}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {p.category}
                  </Typography>
                </TableCell>
                <TableCell>
                  <Typography variant="body2" fontWeight="bold">
                    ₹{p.price}
                  </Typography>
                </TableCell>
                <TableCell>
                  <Typography variant="body2" fontWeight="bold" color={p.inventory < 20 ? 'error.main' : 'text.primary'}>
                    {p.inventory} units
                  </Typography>
                </TableCell>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="caption" fontWeight="bold" sx={{ px: 1, py: 0.2, backgroundColor: p.ecoScore === 'A' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(245, 158, 11, 0.1)', color: p.ecoScore === 'A' ? '#10b981' : '#f59e0b', borderRadius: 1 }}>
                      Eco: {p.ecoScore}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {p.carbonEmission}kg CO2
                    </Typography>
                  </Box>
                </TableCell>
                <TableCell align="center">
                  <Box sx={{ display: 'flex', justifyContent: 'center', gap: 1 }}>
                    <IconButton size="small" onClick={() => openEditDialog(p)} color="primary">
                      <Edit2 size={16} />
                    </IconButton>
                    <IconButton size="small" onClick={() => handleDelete(p.id)} color="error">
                      <Trash2 size={16} />
                    </IconButton>
                  </Box>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* CRUD Add/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="sm" fullWidth>
        <form onSubmit={handleSubmit}>
          <DialogTitle sx={{ fontWeight: 'bold' }}>
            {dialogMode === 'add' ? 'Add Digital Inventory Listing' : 'Edit Catalog Specifications'}
          </DialogTitle>
          <DialogContent dividers>
            <Grid container spacing={2.5}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  label="Product Listing Name"
                  value={formName}
                  onChange={(e) => setFormName(e.target.value)}
                />
              </Grid>
              <Grid item xs={6}>
                <FormControl fullWidth required>
                  <InputLabel>Category</InputLabel>
                  <Select
                    value={formCategory}
                    label="Category"
                    onChange={(e) => setFormCategory(e.target.value)}
                  >
                    <MenuItem value="Fruits & Vegetables">Fruits & Vegetables</MenuItem>
                    <MenuItem value="Bakery & Dairy">Bakery & Dairy</MenuItem>
                    <MenuItem value="Beverages">Beverages</MenuItem>
                    <MenuItem value="Snacks & Cereal">Snacks & Cereal</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  required
                  label="Listing Brand"
                  value={formBrand}
                  onChange={(e) => setFormBrand(e.target.value)}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  required
                  type="number"
                  label="Retail Price"
                  value={formPrice}
                  onChange={(e) => setFormPrice(Number(e.target.value))}
                  InputProps={{
                    startAdornment: <InputAdornment position="start">₹</InputAdornment>,
                  }}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  required
                  label="Unit Size (e.g. 1 kg, 500ml)"
                  value={formUnit}
                  onChange={(e) => setFormUnit(e.target.value)}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  required
                  type="number"
                  label="Stock Inventory Level"
                  value={formInventory}
                  onChange={(e) => setFormInventory(Number(e.target.value))}
                />
              </Grid>
              <Grid item xs={6}>
                <TextField
                  fullWidth
                  label="Image Asset URL"
                  value={formImage}
                  onChange={(e) => setFormImage(e.target.value)}
                />
              </Grid>
              <Grid item xs={4}>
                <TextField
                  fullWidth
                  type="number"
                  label="Eco-Emission Score"
                  value={formCarbon}
                  onChange={(e) => setFormCarbon(Number(e.target.value))}
                />
              </Grid>
              <Grid item xs={4}>
                <FormControl fullWidth>
                  <InputLabel>Eco Grade</InputLabel>
                  <Select
                    value={formEco}
                    label="Eco Grade"
                    onChange={(e) => setFormEco(e.target.value)}
                  >
                    <MenuItem value="A">A - Excellent</MenuItem>
                    <MenuItem value="B">B - Good</MenuItem>
                    <MenuItem value="C">C - Moderate</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={4}>
                <TextField
                  fullWidth
                  type="number"
                  label="User Rating"
                  value={formRating}
                  onChange={(e) => setFormRating(Number(e.target.value))}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions sx={{ p: 2, px: 3 }}>
            <Button onClick={() => setDialogOpen(false)} color="inherit">
              Cancel
            </Button>
            <Button type="submit" variant="contained" sx={{ backgroundColor: '#6200ee' }}>
              Sync Catalog
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Bulk Upload CSV Simulator Dialog */}
      <Dialog open={bulkDialogOpen} onClose={() => setBulkDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 'bold' }}>CSV/Bulk Catalog Upload</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Drag & drop catalog manifest CSV or click below to simulation parse high-demand lines.
          </Typography>
          <Paper variant="outlined" sx={{ p: 3, borderStyle: 'dashed', textAlign: 'center', cursor: 'pointer', mb: 2, '&:hover': { backgroundColor: 'action.hover' } }} onClick={handleSimulateBulkUpload}>
            <Upload size={28} style={{ color: '#6200ee', margin: '0 auto 8px' }} />
            <Typography variant="body2" fontWeight="bold">
              Click to Parse & Upload CSV
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Simulates feeding organic line logs
            </Typography>
          </Paper>
          <TextField
            fullWidth
            multiline
            rows={4}
            variant="outlined"
            placeholder="[CSV Text Editor Console]"
            value={csvContent}
            onChange={(e) => setCsvContent(e.target.value)}
            helperText="Optional raw stream data entry"
          />
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button onClick={() => setBulkDialogOpen(false)} color="inherit">
            Cancel
          </Button>
          <Button onClick={handleSimulateBulkUpload} variant="contained" color="success">
            Inject Pipeline
          </Button>
        </DialogActions>
      </Dialog>

      {/* Toast Alert */}
      <Snackbar
        open={toastOpen}
        autoHideDuration={4000}
        onClose={() => setToastOpen(false)}
        message={toastMessage}
      />
    </Box>
  );
}
