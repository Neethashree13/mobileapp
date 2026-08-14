import React, { useState, useEffect } from 'react';
import {
  Box, Card, CardContent, Typography, Grid, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, Avatar, Button, Chip,
  Rating, Switch, FormControlLabel, Divider
} from '@mui/material';
import { Truck, MapPin, Compass, Award, Play } from 'lucide-react';
import { Rider } from './mockData';

interface DeliveryModuleProps {
  riders: Rider[];
  onToggleRiderStatus: (riderId: string) => void;
  onUpdateRiderLocation: (riderId: string, lat: number, lng: number) => void;
}

export default function DeliveryModule({ riders, onToggleRiderStatus, onUpdateRiderLocation }: DeliveryModuleProps) {
  const [selectedRider, setSelectedRider] = useState<Rider | null>(riders[0]);
  const [simLat, setSimLat] = useState(12.9279);
  const [simLng, setSimLng] = useState(77.6250);
  const [animationActive, setAnimationActive] = useState(false);

  // Simple location simulation animation
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (animationActive && selectedRider) {
      interval = setInterval(() => {
        // Mock rider moves towards target coordinate (Customer at 12.9320, 77.6310)
        const targetLat = 12.9320;
        const targetLng = 77.6310;
        
        setSimLat(prev => {
          const diff = targetLat - prev;
          if (Math.abs(diff) < 0.0005) return targetLat;
          return prev + diff * 0.15;
        });

        setSimLng(prev => {
          const diff = targetLng - prev;
          if (Math.abs(diff) < 0.0005) return targetLng;
          return prev + diff * 0.15;
        });
      }, 800);
    }
    return () => clearInterval(interval);
  }, [animationActive, selectedRider]);

  useEffect(() => {
    if (selectedRider) {
      setSimLat(selectedRider.lat);
      setSimLng(selectedRider.lng);
      setAnimationActive(false);
    }
  }, [selectedRider]);

  const handleStartTrackingSimulation = () => {
    setAnimationActive(true);
  };

  return (
    <Box>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h5" fontWeight="bold">
          Logistics Fleet & Live GPS Tracking
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Monitor active dispatch riders, toggle online availability, and track orders in real-time
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Riders List */}
        <Grid item xs={12} lg={6}>
          <TableContainer component={Paper} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
            <Table size="small">
              <TableHead sx={{ backgroundColor: 'action.hover' }}>
                <TableRow>
                  <TableCell sx={{ fontWeight: 'bold' }}>Rider</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Status</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Deliveries</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Rating</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>Active Duty</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {riders.map((r) => (
                  <TableRow
                    key={r.id}
                    hover
                    onClick={() => setSelectedRider(r)}
                    selected={selectedRider?.id === r.id}
                    sx={{ cursor: 'pointer', '&.Mui-selected': { backgroundColor: 'rgba(98, 0, 238, 0.08)' } }}
                  >
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Avatar src={r.avatar} sx={{ width: 32, height: 32 }} />
                        <Box>
                          <Typography variant="body2" fontWeight="bold">{r.name}</Typography>
                          <Typography variant="caption" color="text.secondary">{r.phone}</Typography>
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={r.status}
                        size="small"
                        color={
                          r.status === 'In Delivery' ? 'info' :
                          r.status === 'Online' ? 'success' : 'default'
                        }
                        sx={{ fontWeight: 'bold', fontSize: '0.65rem' }}
                      />
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="bold">{r.deliveriesCompleted}</Typography>
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                        <Rating value={r.rating} readOnly precision={0.1} size="small" sx={{ fontSize: '0.8rem' }} />
                        <Typography variant="caption" fontWeight="bold">{r.rating}</Typography>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Typography variant="caption" fontWeight="bold" color="text.secondary">
                        {r.activeAssignment || 'Idle'}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>

        {/* GPS Live Tracking Visual Simulation */}
        <Grid item xs={12} lg={6}>
          {selectedRider ? (
            <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider', height: '100%' }}>
              <CardContent sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                  <Box>
                    <Typography variant="subtitle1" fontWeight="bold">
                      Fleet Operator: {selectedRider.name}
                    </Typography>
                    <Typography variant="caption" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                      <Compass size={12} /> LAT: {simLat.toFixed(4)}, LNG: {simLng.toFixed(4)}
                    </Typography>
                  </Box>
                  <FormControlLabel
                    control={
                      <Switch
                        checked={selectedRider.status !== 'Offline'}
                        onChange={() => onToggleRiderStatus(selectedRider.id)}
                        color="success"
                        size="small"
                      />
                    }
                    label="Online Status"
                    sx={{ m: 0 }}
                  />
                </Box>
                <Divider sx={{ mb: 2 }} />

                {/* SVG Map representation */}
                <Box sx={{ flexGrow: 1, height: 240, position: 'relative', backgroundColor: 'action.hover', borderRadius: 3, overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '1px solid', borderColor: 'divider', mb: 2 }}>
                  <svg width="100%" height="100%" style={{ position: 'absolute', top: 0, left: 0 }}>
                    {/* Simulated street grid */}
                    <line x1="10%" y1="0%" x2="10%" y2="100%" stroke="rgba(148, 163, 184, 0.15)" strokeWidth="4" />
                    <line x1="35%" y1="0%" x2="35%" y2="100%" stroke="rgba(148, 163, 184, 0.15)" strokeWidth="4" />
                    <line x1="70%" y1="0%" x2="70%" y2="100%" stroke="rgba(148, 163, 184, 0.15)" strokeWidth="4" />
                    <line x1="90%" y1="0%" x2="90%" y2="100%" stroke="rgba(148, 163, 184, 0.15)" strokeWidth="4" />
                    
                    <line x1="0%" y1="20%" x2="100%" y2="20%" stroke="rgba(148, 163, 184, 0.15)" strokeWidth="4" />
                    <line x1="0%" y1="50%" x2="100%" y2="50%" stroke="rgba(148, 163, 184, 0.15)" strokeWidth="4" />
                    <line x1="0%" y1="80%" x2="100%" y2="80%" stroke="rgba(148, 163, 184, 0.15)" strokeWidth="4" />

                    {/* Dark Store Dark Depot Marker */}
                    <circle cx="35%" cy="80%" r="8" fill="#6200ee" opacity="0.8" />
                    <text x="35%" y="72%" fill="#6200ee" fontSize="10" fontWeight="bold" textAnchor="middle">DARK STORE DEPOT</text>

                    {/* Client destination Coordinates Marker */}
                    <circle cx="70%" cy="20%" r="8" fill="#10b981" opacity="0.8" />
                    <text x="70%" y="12%" fill="#10b981" fontSize="10" fontWeight="bold" textAnchor="middle">CUSTOMER</text>

                    {/* Rider Marker coordinates mapping: simLat is between 12.9279 and 12.9320. simLng is between 77.6250 and 77.6310 */}
                    {/* Normalizing coordinates to SVG percentages */}
                    {(() => {
                      const latPct = 80 - ((simLat - 12.9279) / (12.9320 - 12.9279)) * 60;
                      const lngPct = 35 + ((simLng - 77.6250) / (77.6310 - 77.6250)) * 35;
                      return (
                        <g>
                          <path d={`M ${lngPct} ${latPct - 15} L ${lngPct - 10} ${latPct} L ${lngPct + 10} ${latPct} Z`} fill="#06b6d4" />
                          <circle cx={`${lngPct}%`} cy={`${latPct}%`} r="12" fill="#06b6d4" opacity="0.3" className="animate-ping" />
                          <circle cx={`${lngPct}%`} cy={`${latPct}%`} r="5" fill="#06b6d4" />
                          <text x={`${lngPct}%`} y={`${latPct + 15}%`} fill="#06b6d4" fontSize="10" fontWeight="black" textAnchor="middle">CARGO TRUCK</text>
                        </g>
                      );
                    })()}
                  </svg>
                </Box>

                {/* Simulation command block */}
                {selectedRider.status === 'In Delivery' ? (
                  <Button
                    startIcon={<Play size={16} />}
                    variant="contained"
                    fullWidth
                    color="primary"
                    disabled={animationActive}
                    onClick={handleStartTrackingSimulation}
                    sx={{ backgroundColor: '#6200ee', py: 1 }}
                  >
                    {animationActive ? 'Logistics Route In Progress...' : 'Launch Live Delivery Tracking Simulation'}
                  </Button>
                ) : (
                  <Paper variant="outlined" sx={{ p: 2, textAlign: 'center', borderRadius: 2 }}>
                    <Typography variant="body2" color="text.secondary">
                      Rider is currently waiting for active order dispatches. No tracking simulations available.
                    </Typography>
                  </Paper>
                )}
              </CardContent>
            </Card>
          ) : (
            <Card sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider', display: 'flex', alignItems: 'center', justifyContent: 'center', p: 4 }}>
              <Typography variant="body2" color="text.secondary">
                Select a logistics partner to view live telemetry
              </Typography>
            </Card>
          )}
        </Grid>
      </Grid>
    </Box>
  );
}
