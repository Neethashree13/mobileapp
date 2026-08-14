import React, { useState } from 'react';
import {
  Box, Card, CardContent, Typography, Button, Grid, TextField,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Paper, IconButton, Dialog, DialogTitle, DialogContent, DialogActions,
  FormControl, InputLabel, Select, MenuItem, Avatar, Snackbar, Chip
} from '@mui/material';
import { Plus, Edit2, Trash2, ArrowRight, Layers, FolderPlus } from 'lucide-react';
import { Category } from './mockData';

interface CategoryModuleProps {
  categories: Category[];
  onAddCategory: (category: Category) => void;
  onEditCategory: (category: Category) => void;
  onDeleteCategory: (categoryId: string) => void;
}

export default function CategoryModule({ categories, onAddCategory, onEditCategory, onDeleteCategory }: CategoryModuleProps) {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [dialogMode, setDialogMode] = useState<'add' | 'edit'>('add');
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);

  // Form fields
  const [formName, setFormName] = useState('');
  const [formParent, setFormParent] = useState('');
  const [formIcon, setFormIcon] = useState('Apple');
  const [formBanner, setFormBanner] = useState('https://images.unsplash.com/photo-1610348725531-843dff14722a?w=400&q=80');

  // Toasts
  const [toastOpen, setToastOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  const openAdd = () => {
    setDialogMode('add');
    setFormName('');
    setFormParent('');
    setFormIcon('Apple');
    setFormBanner('https://images.unsplash.com/photo-1610348725531-843dff14722a?w=400&q=80');
    setDialogOpen(true);
  };

  const openEdit = (c: Category) => {
    setDialogMode('edit');
    setSelectedCategory(c);
    setFormName(c.name);
    setFormParent(c.parent || '');
    setFormIcon(c.icon);
    setFormBanner(c.banner || 'https://images.unsplash.com/photo-1610348725531-843dff14722a?w=400&q=80');
    setDialogOpen(true);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName) return;

    const payload: Category = {
      id: dialogMode === 'add' ? `c_${Date.now()}` : selectedCategory!.id,
      name: formName,
      parent: formParent || undefined,
      icon: formIcon,
      banner: formBanner,
      productCount: dialogMode === 'add' ? 0 : selectedCategory!.productCount
    };

    if (dialogMode === 'add') {
      onAddCategory(payload);
      setToastMessage('Nested catalog category registered!');
    } else {
      onEditCategory(payload);
      setToastMessage('Category configurations updated!');
    }
    setDialogOpen(false);
    setToastOpen(true);
  };

  const handleDelete = (id: string) => {
    onDeleteCategory(id);
    setToastMessage('Category deleted from taxonomy.');
    setToastOpen(true);
  };

  return (
    <Box>
      {/* Title block */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h5" fontWeight="bold">
            Taxonomy & Category Structures
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Organize catalog structures, nest subcategories, and upload marketing banners
          </Typography>
        </Box>
        <Button startIcon={<FolderPlus size={16} />} variant="contained" sx={{ backgroundColor: '#6200ee' }} onClick={openAdd}>
          Create Category
        </Button>
      </Box>

      {/* Grid of hierarchies */}
      <Grid container spacing={3}>
        {/* Categories Table */}
        <Grid item xs={12}>
          <TableContainer component={Paper} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
            <Table>
              <TableHead sx={{ backgroundColor: 'action.hover' }}>
                <TableRow>
                  <TableCell sx={{ fontWeight: 'bold' }}>Banner & Title</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Taxonomy Level</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Descriptive Icon</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Linked Items</TableCell>
                  <TableCell align="center" sx={{ fontWeight: 'bold' }}>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {categories.map((c) => {
                  const isNested = !!c.parent;
                  return (
                    <TableRow key={c.id} hover sx={{ pl: isNested ? 4 : 0 }}>
                      <TableCell>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, pl: isNested ? 3 : 0 }}>
                          {isNested && <ArrowRight size={16} style={{ color: '#94a3b8' }} />}
                          <Avatar variant="rounded" src={c.banner} sx={{ width: 64, height: 36, mr: 1 }} />
                          <Typography variant="body2" fontWeight="bold">
                            {c.name}
                          </Typography>
                        </Box>
                      </TableCell>
                      <TableCell>
                        {isNested ? (
                          <Chip label={`Sub of ${c.parent}`} size="small" variant="outlined" color="primary" sx={{ fontSize: '0.7rem', fontWeight: 'bold' }} />
                        ) : (
                          <Chip label="Root Category" size="small" color="secondary" sx={{ fontSize: '0.7rem', fontWeight: 'bold', backgroundColor: '#6200ee', color: 'white' }} />
                        )}
                      </TableCell>
                      <TableCell>
                        <Chip icon={<Layers size={12} />} label={c.icon} size="small" variant="outlined" sx={{ fontWeight: 'medium' }} />
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" fontWeight="bold">
                          {c.productCount} items
                        </Typography>
                      </TableCell>
                      <TableCell align="center">
                        <Box sx={{ display: 'flex', justifyContent: 'center', gap: 1 }}>
                          <IconButton size="small" onClick={() => openEdit(c)} color="primary">
                            <Edit2 size={16} />
                          </IconButton>
                          <IconButton size="small" onClick={() => handleDelete(c.id)} color="error">
                            <Trash2 size={16} />
                          </IconButton>
                        </Box>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>
      </Grid>

      {/* CRUD Dialog */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="xs" fullWidth>
        <form onSubmit={handleSubmit}>
          <DialogTitle sx={{ fontWeight: 'bold' }}>
            {dialogMode === 'add' ? 'Create New Category Listing' : 'Edit Category Structures'}
          </DialogTitle>
          <DialogContent dividers>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  required
                  label="Category Title"
                  value={formName}
                  onChange={(e) => setFormName(e.target.value)}
                />
              </Grid>
              <Grid item xs={12}>
                <FormControl fullWidth>
                  <InputLabel>Parent Category (Nesting)</InputLabel>
                  <Select
                    value={formParent}
                    label="Parent Category (Nesting)"
                    onChange={(e) => setFormParent(e.target.value)}
                  >
                    <MenuItem value="">-- No Parent (Set as Root) --</MenuItem>
                    {categories.filter(c => !c.parent && c.id !== selectedCategory?.id).map(c => (
                      <MenuItem key={c.id} value={c.name}>{c.name}</MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12}>
                <FormControl fullWidth>
                  <InputLabel>Category Icon</InputLabel>
                  <Select
                    value={formIcon}
                    label="Category Icon"
                    onChange={(e) => setFormIcon(e.target.value)}
                  >
                    <MenuItem value="Apple">Apple (Fruits & Veg)</MenuItem>
                    <MenuItem value="Milk">Milk (Bakery & Dairy)</MenuItem>
                    <MenuItem value="Coffee">Coffee (Beverages)</MenuItem>
                    <MenuItem value="Cookie">Cookie (Snacks)</MenuItem>
                    <MenuItem value="Leaf">Leaf (Greens)</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Visual Banner URL"
                  value={formBanner}
                  onChange={(e) => setFormBanner(e.target.value)}
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setDialogOpen(false)} color="inherit">
              Cancel
            </Button>
            <Button type="submit" variant="contained" sx={{ backgroundColor: '#6200ee' }}>
              Confirm Taxonomies
            </Button>
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
