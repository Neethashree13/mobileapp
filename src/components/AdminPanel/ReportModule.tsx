import React from 'react';
import {
  Box, Card, CardContent, Typography, Grid, Button, Table, TableBody,
  TableCell, TableContainer, TableHead, TableRow, Paper, Divider, Chip
} from '@mui/material';
import { Download, TrendingUp, Wallet, ShieldAlert, Layers } from 'lucide-react';
import {
  ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Legend
} from 'recharts';
import { salesTrends } from './mockData';

export default function ReportModule() {
  const taxSummary = [
    { period: 'July 1 - July 21', grossSales: 405000, igst: 18400, cgst: 22100, sgst: 22100, netTax: 62600, status: 'Audited' },
    { period: 'June 1 - June 30', grossSales: 1240000, igst: 42300, cgst: 90200, sgst: 90200, netTax: 222700, status: 'Paid' },
    { period: 'May 1 - May 31', grossSales: 980000, igst: 32400, cgst: 71200, sgst: 71200, netTax: 174800, status: 'Paid' }
  ];

  const handleExport = (reportType: string) => {
    alert(`Generating cryptographically signed secure ledger export: ${reportType}.csv has been requested.`);
  };

  return (
    <Box>
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Box>
          <Typography variant="h5" fontWeight="bold">
            Tax Ledger & Operations Ledger
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Analyze consolidated sales ledgers, audited GST files, and export data feeds
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 1.5 }}>
          <Button startIcon={<Download size={16} />} variant="outlined" onClick={() => handleExport('Tax_Filing_2026')}>
            Export Tax Filing
          </Button>
          <Button startIcon={<Download size={16} />} variant="contained" sx={{ backgroundColor: '#6200ee' }} onClick={() => handleExport('Gross_Sales_Ledger')}>
            Export Gross Sales Ledger
          </Button>
        </Box>
      </Box>

      {/* Graphs */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12}>
          <Card sx={{ borderRadius: 3, p: 2 }}>
            <Typography variant="subtitle1" fontWeight="bold" sx={{ mb: 2, px: 1 }}>
              Demand Conversion Trends (Sales vs Customer Growth)
            </Typography>
            <Box sx={{ height: 300, width: '100%' }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={salesTrends} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                  <XAxis dataKey="name" stroke="#94a3b8" fontSize={11} tickLine={false} />
                  <YAxis stroke="#94a3b8" fontSize={11} tickLine={false} />
                  <Tooltip contentStyle={{ borderRadius: 8 }} />
                  <Legend />
                  <Bar dataKey="sales" name="Fulfillment Sales (₹)" fill="#6200ee" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="customers" name="Customers" fill="#10b981" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </Card>
        </Grid>
      </Grid>

      {/* Tax Report Breakdown */}
      <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
        <CardContent>
          <Typography variant="subtitle1" fontWeight="bold" sx={{ mb: 2 }}>
            Legal GST Ledger Records & Filing Status
          </Typography>
          <TableContainer component={Paper} elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <Table>
              <TableHead sx={{ backgroundColor: 'action.hover' }}>
                <TableRow>
                  <TableRowCell sx={{ fontWeight: 'bold' }}>Reporting Period</TableRowCell>
                  <TableRowCell sx={{ fontWeight: 'bold' }}>Gross Sales Receipt</TableRowCell>
                  <TableRowCell sx={{ fontWeight: 'bold' }}>IGST (Integrated)</TableRowCell>
                  <TableRowCell sx={{ fontWeight: 'bold' }}>CGST (Central)</TableRowCell>
                  <TableRowCell sx={{ fontWeight: 'bold' }}>SGST (State)</TableRowCell>
                  <TableRowCell sx={{ fontWeight: 'bold' }}>Net Tax Paid</TableRowCell>
                  <TableRowCell sx={{ fontWeight: 'bold' }}>Filing Status</TableRowCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {taxSummary.map((tax, idx) => (
                  <TableRow key={idx} hover>
                    <TableCell sx={{ fontWeight: 'bold' }}>{tax.period}</TableCell>
                    <TableCell>₹{tax.grossSales.toLocaleString()}</TableCell>
                    <TableCell>₹{tax.igst.toLocaleString()}</TableCell>
                    <TableCell>₹{tax.cgst.toLocaleString()}</TableCell>
                    <TableCell>₹{tax.sgst.toLocaleString()}</TableCell>
                    <TableCell sx={{ fontWeight: 'bold', color: 'primary.main' }}>₹{tax.netTax.toLocaleString()}</TableCell>
                    <TableCell>
                      <Chip
                        label={tax.status}
                        size="small"
                        color={tax.status === 'Paid' ? 'success' : 'warning'}
                        sx={{ fontWeight: 'bold', fontSize: '0.65rem' }}
                      />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>
    </Box>
  );
}

// Temporary internal component wrapper for TableCell
function TableRowCell({ children, sx }: { children: React.ReactNode; sx?: any }) {
  return <TableCell sx={sx}>{children}</TableCell>;
}
