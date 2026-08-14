export const PRODUCT_CATALOG_CONTEXT = `
Available products in FlashCart AI store:
- p1: Organic Fresh Bananas (Category: veggies, Price: ₹69, Unit: 1 bunch of 5-6 pcs, Calories: 105, Protein: 1.3g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.15kg)
- p2: Fresh Red Tomatoes (Category: veggies, Price: ₹40, Unit: 500 g, Calories: 18, Protein: 0.9g, ecoScore: B, carbon: 0.28kg)
- p3: Hydroponic English Cucumber (Category: veggies, Price: ₹75, Unit: 1 pc, Calories: 15, Protein: 0.7g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.08kg)
- p4: Fresh Spinach Palak (Category: veggies, Price: ₹25, Unit: 1 bunch (250g), Calories: 23, Protein: 2.9g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.12kg)
- p5: Premium Fresh Paneer (Category: dairy, Price: ₹110, Unit: 200 g, Calories: 265, Protein: 18.3g, isHealthy: true, ecoScore: C, carbon: 1.20kg)
- p6: Organic Free-Range Eggs (Category: dairy, Price: ₹95, Unit: 6 pcs pack, Calories: 78, Protein: 6.3g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.45kg)
- p7: Pasteurized Full Cream Milk (Category: dairy, Price: ₹33, Unit: 500 ml pouch, Calories: 150, Protein: 8.0g, isHealthy: true, ecoScore: B, carbon: 0.85kg)
- p8: Artisanal Sourdough Bread (Category: bakery, Price: ₹120, Unit: 400 g, Calories: 220, Protein: 8.0g, isOrganic: true, isHealthy: true, ecoScore: B, carbon: 0.35kg)
- p9: Whole Wheat Brown Bread (Category: bakery, Price: ₹45, Unit: 400 g pack, Calories: 190, Protein: 6.5g, isHealthy: true, ecoScore: B, carbon: 0.42kg)
- p10: Gourmet Salted Roasted Cashews (Category: snacks, Price: ₹180, Unit: 100 g, Calories: 553, Protein: 18.2g, isOrganic: true, isHealthy: true, ecoScore: B, carbon: 0.52kg)
- p11: Spicy Potato Chips Classic (Category: snacks, Price: ₹30, Unit: 80 g bag, Calories: 450, Protein: 5.0g, ecoScore: D, carbon: 0.98kg)
- p12: Sparkling Natural Spring Water (Category: beverages, Price: ₹80, Unit: 750 ml Glass Bottle, Calories: 0, Protein: 0.0g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.10kg)
- p13: Premium Cold Brew Black Coffee (Category: beverages, Price: ₹150, Unit: 250 ml can, Calories: 5, Protein: 0.2g, isOrganic: true, isHealthy: true, ecoScore: B, carbon: 0.40kg)
- p14: Premium Basmati Rice Rozana (Category: pantry, Price: ₹199, Unit: 1 kg pack, Calories: 365, Protein: 7.1g, isHealthy: true, ecoScore: B, carbon: 0.65kg)
- p15: Organic Unpolished Arhar Dal (Category: pantry, Price: ₹160, Unit: 1 kg pack, Calories: 343, Protein: 22.0g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.30kg)
- p16: Premium Daily Multivitamin (Category: medicine, Price: ₹350, Unit: 30 tablets, Calories: 0, Protein: 0.0g, isHealthy: true, ecoScore: B, carbon: 0.18kg)
- p17: Biodegradable Bamboo Baby Wipes (Category: baby, Price: ₹220, Unit: 80 wipes, Calories: 0, Protein: 0.0g, isOrganic: true, isHealthy: true, ecoScore: A, carbon: 0.05kg)
`;

export interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  unit: string;
  image: string;
  rating: number;
  reviewsCount: number;
  calories: number;
  protein: number;
  isOrganic?: boolean;
  isHealthy?: boolean;
  ecoScore: "A" | "B" | "C" | "D";
  carbonEmission: number;
  inventory: number;
  deliveryTimeMins: number;
  originalPrice?: number;
  description?: string;
}

export const DB_STATE = {
  products: [
    {
      id: "p1",
      name: "Organic Fresh Bananas",
      category: "veggies",
      price: 69,
      unit: "1 bunch of 5-6 pcs",
      image: "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120",
      rating: 4.8,
      reviewsCount: 240,
      calories: 105,
      protein: 1.3,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "A" as const,
      carbonEmission: 0.15,
      inventory: 45,
      deliveryTimeMins: 9,
      originalPrice: 85,
      description: "Creamy, naturally sweet, and rich in potassium. Perfect for cereal, smoothies, or energy-rich snacks."
    },
    {
      id: "p2",
      name: "Fresh Red Tomatoes",
      category: "veggies",
      price: 40,
      unit: "500 g",
      image: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=120",
      rating: 4.6,
      reviewsCount: 180,
      calories: 18,
      protein: 0.9,
      isOrganic: false,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.28,
      inventory: 60,
      deliveryTimeMins: 10,
      originalPrice: 50,
      description: "Plump, red, and juicy. Essential for gravies, salads, and fresh Italian sauces."
    },
    {
      id: "p3",
      name: "Hydroponic English Cucumber",
      category: "veggies",
      price: 75,
      unit: "1 pc",
      image: "https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=120",
      rating: 4.7,
      reviewsCount: 95,
      calories: 15,
      protein: 0.7,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "A" as const,
      carbonEmission: 0.08,
      inventory: 30,
      deliveryTimeMins: 7,
      originalPrice: 90,
      description: "Crunchy, seedless, and refreshing cucumber grown in rich water nutrient bases."
    },
    {
      id: "p4",
      name: "Fresh Spinach Palak",
      category: "veggies",
      price: 25,
      unit: "1 bunch (250g)",
      image: "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=120",
      rating: 4.5,
      reviewsCount: 142,
      calories: 23,
      protein: 2.9,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "A" as const,
      carbonEmission: 0.12,
      inventory: 50,
      deliveryTimeMins: 8,
      originalPrice: 30,
      description: "Iron-rich, dark green leaves harvested at sunrise. Ideal for healthy salads or classic Indian Palak paneer."
    },
    {
      id: "p5",
      name: "Premium Fresh Paneer",
      category: "dairy",
      price: 110,
      unit: "200 g",
      image: "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=120",
      rating: 4.9,
      reviewsCount: 310,
      calories: 265,
      protein: 18.3,
      isOrganic: false,
      isHealthy: true,
      ecoScore: "C" as const,
      carbonEmission: 1.20,
      inventory: 25,
      deliveryTimeMins: 9,
      originalPrice: 130,
      description: "Mouth-melting soft cottage cheese made from pure cow milk. Ideal for baking, grilling, or rich tomato gravies."
    },
    {
      id: "p6",
      name: "Organic Free-Range Eggs",
      category: "dairy",
      price: 95,
      unit: "6 pcs pack",
      image: "https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=120",
      rating: 4.8,
      reviewsCount: 220,
      calories: 78,
      protein: 6.3,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "A" as const,
      carbonEmission: 0.45,
      inventory: 40,
      deliveryTimeMins: 10,
      originalPrice: 115,
      description: "Sourced from pasture-raised hens fed on 100% organic grain. Excellent daily source of clean proteins."
    },
    {
      id: "p7",
      name: "Pasteurized Full Cream Milk",
      category: "dairy",
      price: 33,
      unit: "500 ml pouch",
      image: "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=120",
      rating: 4.7,
      reviewsCount: 450,
      calories: 150,
      protein: 8.0,
      isOrganic: false,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.85,
      inventory: 80,
      deliveryTimeMins: 9,
      originalPrice: 35,
      description: "Freshly pasteurized milk containing natural fat-soluble vitamins. Ideal for brewing or setting rich curds."
    },
    {
      id: "p8",
      name: "Artisanal Sourdough Bread",
      category: "bakery",
      price: 120,
      unit: "400 g",
      image: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=120",
      rating: 4.9,
      reviewsCount: 112,
      calories: 220,
      protein: 8.0,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.35,
      inventory: 15,
      deliveryTimeMins: 11,
      originalPrice: 150,
      description: "Baked daily in small batches with live wild yeast culture. Sliced, crusty, and full of natural probiotics."
    },
    {
      id: "p9",
      name: "Whole Wheat Brown Bread",
      category: "bakery",
      price: 45,
      unit: "400 g pack",
      image: "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=120",
      rating: 4.6,
      reviewsCount: 198,
      calories: 190,
      protein: 6.5,
      isOrganic: false,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.42,
      inventory: 35,
      deliveryTimeMins: 8,
      originalPrice: 50,
      description: "High-fiber brown bread baked using whole wheat grain. Perfect for diet toast, sandwiches, or egg rolls."
    },
    {
      id: "p10",
      name: "Gourmet Salted Roasted Cashews",
      category: "snacks",
      price: 180,
      unit: "100 g",
      image: "https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=120",
      rating: 4.7,
      reviewsCount: 88,
      calories: 553,
      protein: 18.2,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.52,
      inventory: 20,
      deliveryTimeMins: 9,
      originalPrice: 200,
      description: "Roasted to golden perfection and lightly sprinkled with pink Himalayan salt. Rich in healthy monounsaturated fats."
    },
    {
      id: "p11",
      name: "Spicy Potato Chips Classic",
      category: "snacks",
      price: 30,
      unit: "80 g bag",
      image: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=120",
      rating: 4.2,
      reviewsCount: 310,
      calories: 450,
      protein: 5.0,
      isOrganic: false,
      isHealthy: false,
      ecoScore: "D" as const,
      carbonEmission: 0.98,
      inventory: 100,
      deliveryTimeMins: 7,
      originalPrice: 35,
      description: "Thin, crispy slices of potatoes kettle-cooked in small batches and dusted with high-spiciness hot masala spices."
    },
    {
      id: "p12",
      name: "Sparkling Natural Spring Water",
      category: "beverages",
      price: 80,
      unit: "750 ml Glass Bottle",
      image: "https://images.unsplash.com/photo-1608885898957-a599fb18e841?w=120",
      rating: 4.8,
      reviewsCount: 74,
      calories: 0,
      protein: 0.0,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "A" as const,
      carbonEmission: 0.10,
      inventory: 40,
      deliveryTimeMins: 9,
      originalPrice: 95,
      description: "Naturally carbonated mineral water bottled at the Himalayan springs. Zero calorie crisp clean bubbly soda substitute."
    },
    {
      id: "p13",
      name: "Premium Cold Brew Black Coffee",
      category: "beverages",
      price: 150,
      unit: "250 ml can",
      image: "https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=120",
      rating: 4.7,
      reviewsCount: 130,
      calories: 5,
      protein: 0.2,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.40,
      inventory: 30,
      deliveryTimeMins: 8,
      originalPrice: 175,
      description: "Brewed for 18 hours in mountain spring water from single-origin Arabica coffee beans. Bold, low-acid, clean energy."
    },
    {
      id: "p14",
      name: "Premium Basmati Rice Rozana",
      category: "pantry",
      price: 199,
      unit: "1 kg pack",
      image: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=120",
      rating: 4.6,
      reviewsCount: 165,
      calories: 365,
      protein: 7.1,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.65,
      inventory: 40,
      deliveryTimeMins: 11,
      originalPrice: 249,
      description: "Long-grain aromatic rice harvested from the foothills of the Himalayas. Expands to double its length when boiled."
    },
    {
      id: "p15",
      name: "Organic Unpolished Arhar Dal",
      category: "pantry",
      price: 160,
      unit: "1 kg pack",
      image: "https://images.unsplash.com/photo-1547058881-aa0edd92aab3?w=120",
      rating: 4.7,
      reviewsCount: 215,
      calories: 343,
      protein: 22.0,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "A" as const,
      carbonEmission: 0.30,
      inventory: 35,
      deliveryTimeMins: 10,
      originalPrice: 190,
      description: "High-protein split pigeon pea. Unpolished, chemical-free, and rich in natural minerals, fibers, and iron."
    },
    {
      id: "p16",
      name: "Premium Daily Multivitamin",
      category: "medicine",
      price: 350,
      unit: "30 tablets",
      image: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=120",
      rating: 4.8,
      reviewsCount: 184,
      calories: 0,
      protein: 0.0,
      isHealthy: true,
      ecoScore: "B" as const,
      carbonEmission: 0.18,
      inventory: 18,
      deliveryTimeMins: 12,
      originalPrice: 420,
      description: "Enriched with 24 essential vitamins and minerals for daily immunity, heart health, and high clean metabolic energy."
    },
    {
      id: "p17",
      name: "Biodegradable Bamboo Baby Wipes",
      category: "baby",
      price: 220,
      unit: "80 wipes",
      image: "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=120",
      rating: 4.9,
      reviewsCount: 95,
      calories: 0,
      protein: 0.0,
      isOrganic: true,
      isHealthy: true,
      ecoScore: "A" as const,
      carbonEmission: 0.05,
      inventory: 22,
      deliveryTimeMins: 11,
      originalPrice: 280,
      description: "100% natural organic bamboo wipes infused with fresh aloe vera. Ultra-sensitive skin care with zero plastic fibers."
    }
  ] as Product[],
  cart: [] as any[],
  wishlist: [] as string[],
  activeOrder: null as any,
  orders: [] as any[],
  riderState: {
    id: 'r1',
    name: 'Suresh Kumar',
    phone: '+91 98765 43210',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120',
    lat: 12.9279,
    lng: 77.6250,
    bearing: 0,
    status: 'assigned',
    rating: 4.95
  },
  walletBalance: 1200,
  rewardPoints: 350,
  paymentTransactions: [
    {
      id: "PAY-90112",
      orderId: "FC-8821",
      userId: "u1",
      amount: 450.00,
      currency: "INR",
      paymentMethod: "UPI",
      provider: "GPay",
      status: "SUCCESS",
      transactionId: "TXN-GPAY-991201",
      idempotencyKey: "IDEM-8821-01",
      gatewayRef: "GREF-9812",
      riskScore: 0.05,
      isFlagged: false,
      createdAt: new Date(Date.now() - 86400000).toISOString(),
      updatedAt: new Date(Date.now() - 86400000).toISOString()
    },
    {
      id: "PAY-90113",
      orderId: "FC-8822",
      userId: "u1",
      amount: 120.00,
      currency: "INR",
      paymentMethod: "Wallet",
      provider: "FlashWallet",
      status: "SUCCESS",
      transactionId: "TXN-WALL-771202",
      idempotencyKey: "IDEM-8822-01",
      gatewayRef: "GREF-9813",
      riskScore: 0.02,
      isFlagged: false,
      createdAt: new Date(Date.now() - 43200000).toISOString(),
      updatedAt: new Date(Date.now() - 43200000).toISOString()
    }
  ] as any[],
  walletLedger: [
    {
      id: "wled_1",
      userId: "u1",
      type: "CREDIT",
      category: "TOPUP",
      amount: 1000.00,
      balanceAfter: 1200.00,
      referenceId: "PAY-TOPUP-01",
      description: "Wallet Auto Top Up via UPI",
      createdAt: new Date(Date.now() - 172800000).toISOString()
    },
    {
      id: "wled_2",
      userId: "u1",
      type: "DEBIT",
      category: "ORDER_PAYMENT",
      amount: 120.00,
      balanceAfter: 1080.00,
      referenceId: "FC-8822",
      description: "Payment for Express Order #FC-8822",
      createdAt: new Date(Date.now() - 43200000).toISOString()
    },
    {
      id: "wled_3",
      userId: "u1",
      type: "CREDIT",
      category: "CASHBACK",
      amount: 120.00,
      balanceAfter: 1200.00,
      referenceId: "CBK-8822",
      description: "10% Express Shopping Cashback",
      createdAt: new Date(Date.now() - 21600000).toISOString()
    }
  ] as any[],
  refundRecords: [] as any[],
  rewardLedger: [
    {
      id: "rw_1",
      userId: "u1",
      points: 250,
      type: "EARNED",
      reason: "Order FC-8821 Reward Reward Points",
      createdAt: new Date(Date.now() - 86400000).toISOString()
    },
    {
      id: "rw_2",
      userId: "u1",
      points: 100,
      type: "EARNED",
      reason: "Daily Shopping Streak Bonus",
      createdAt: new Date(Date.now() - 43200000).toISOString()
    }
  ] as any[],
  gatewayLogs: [
    {
      id: "gwlog_1",
      provider: "Razorpay",
      eventType: "payment.captured",
      payload: { paymentId: "PAY-90112", status: "captured" },
      signature: "sig_mock_razorpay_9921",
      status: "VERIFIED",
      createdAt: new Date(Date.now() - 86400000).toISOString()
    }
  ] as any[],
  addresses: [
    {
      id: "ad1",
      title: "Home",
      addressLine1: "Symphony Premium Apts, Koramangala 3rd Block",
      addressLine2: "Apartment 4B, Tower A",
      landmark: "Near Sony Signal",
      city: "Bangalore",
      state: "Karnataka",
      postalCode: "560034",
      latitude: 12.9348,
      longitude: 77.6189,
      isDefault: true
    }
  ],
  darkStores: [
    {
      id: "s1",
      name: "Koramangala Dark Store",
      code: "DS-BLR-01",
      latitude: 12.9279,
      longitude: 77.6250,
      address: "Block 3, Koramangala, Bangalore",
      isActive: true
    },
    {
      id: "s2",
      name: "Indiranagar Quick Hub",
      code: "DS-BLR-02",
      latitude: 12.9716,
      longitude: 77.6412,
      address: "100ft Road, Indiranagar, Bangalore",
      isActive: true
    },
    {
      id: "s3",
      name: "HSR Layout Depot",
      code: "DS-BLR-03",
      latitude: 12.9121,
      longitude: 77.6445,
      address: "Sector 1, HSR Layout, Bangalore",
      isActive: true
    }
  ],
  riders: [
    {
      id: "r1",
      name: "Suresh Kumar",
      phone: "+91 98765 43210",
      avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120",
      vehicleType: "Scooter",
      vehicleNumber: "KA-01-EQ-9041",
      isOnline: true,
      currentStoreId: "s1",
      activeDeliveryId: null as string | null,
      rating: 4.95,
      totalTrips: 142,
      totalEarnings: 12450,
      lat: 12.9279,
      lng: 77.6250,
      bearing: 0
    },
    {
      id: "r2",
      name: "Ramesh Patel",
      phone: "+91 98123 45678",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120",
      vehicleType: "E-Bike",
      vehicleNumber: "KA-01-EV-3312",
      isOnline: true,
      currentStoreId: "s1",
      activeDeliveryId: null as string | null,
      rating: 4.88,
      totalTrips: 98,
      totalEarnings: 8900,
      lat: 12.9300,
      lng: 77.6280,
      bearing: 0
    },
    {
      id: "r3",
      name: "Vikram Singh",
      phone: "+91 99887 76655",
      avatar: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=120",
      vehicleType: "EV Van",
      vehicleNumber: "KA-01-EV-8821",
      isOnline: false,
      currentStoreId: "s2",
      activeDeliveryId: null as string | null,
      rating: 4.90,
      totalTrips: 210,
      totalEarnings: 18900,
      lat: 12.9716,
      lng: 77.6412,
      bearing: 0
    }
  ],
  deliveryTracking: [] as any[],
  deliveryAssignments: [] as any[],
  gpsLocationHistory: [] as any[],
  deliveryAuditLogs: [] as any[],
  notifications: [
    {
      id: "n1",
      userId: "u1",
      role: "CUSTOMER",
      title: "Order FC-8821 Placed! 🛒",
      body: "Your express grocery order for ₹499 has been sent to Koramangala Dark Store.",
      category: "ORDER",
      channel: "IN_APP",
      read: false,
      metadata: { orderId: "FC-8821" },
      createdAt: new Date(Date.now() - 3600000).toISOString()
    },
    {
      id: "n2",
      userId: "u1",
      role: "CUSTOMER",
      title: "Flash Sale Alert! ⚡",
      body: "50% Off on Organic Fresh Fruits for the next 15 minutes. Use code FLASH50.",
      category: "PROMO",
      channel: "IN_APP",
      read: false,
      metadata: { couponCode: "FLASH50" },
      createdAt: new Date(Date.now() - 7200000).toISOString()
    },
    {
      id: "n3",
      userId: "r1",
      role: "RIDER",
      title: "Peak Hour Bonus Activated 🔥",
      body: "Complete 5 trips before 10 PM to earn an extra ₹250 surge bonus!",
      category: "DELIVERY",
      channel: "IN_APP",
      read: false,
      metadata: { bonusAmount: 250 },
      createdAt: new Date(Date.now() - 1800000).toISOString()
    },
    {
      id: "n4",
      userId: "store1",
      role: "STORE_MANAGER",
      title: "Low Inventory Alert ⚠️",
      body: "Fresh Organic Avocados are down to 4 units in Koramangala Dark Store.",
      category: "INVENTORY",
      channel: "IN_APP",
      read: false,
      metadata: { storeId: "s1", productId: "p5" },
      createdAt: new Date(Date.now() - 5400000).toISOString()
    }
  ] as any[],
  notificationTemplates: [
    { code: 'ORDER_PLACED', title: 'Order Placed Successfully! 🛒', bodyTemplate: 'Your order {{orderId}} for ₹{{amount}} has been received.', category: 'ORDER', channels: ['IN_APP', 'PUSH', 'EMAIL', 'SMS'], isActive: true },
    { code: 'RIDER_ASSIGNED', title: 'Rider Assigned 🛵', bodyTemplate: '{{riderName}} is assigned to deliver your order #{{orderId}}.', category: 'DELIVERY', channels: ['IN_APP', 'PUSH', 'SMS'], isActive: true },
    { code: 'OUT_FOR_DELIVERY', title: 'Out for Delivery 🚀', bodyTemplate: 'Your order #{{orderId}} is on its way with {{riderName}}. ETA: {{eta}} mins.', category: 'DELIVERY', channels: ['IN_APP', 'PUSH', 'SMS'], isActive: true },
    { code: 'RIDER_NEARBY', title: 'Rider Nearby 📍', bodyTemplate: '{{riderName}} is less than 500m away! Get ready with OTP: {{otpCode}}.', category: 'DELIVERY', channels: ['IN_APP', 'PUSH', 'SMS'], isActive: true },
    { code: 'DELIVERED', title: 'Order Delivered 🎉', bodyTemplate: 'Order #{{orderId}} was successfully delivered. Enjoy your fresh groceries!', category: 'ORDER', channels: ['IN_APP', 'PUSH', 'EMAIL'], isActive: true },
    { code: 'WALLET_CREDITED', title: 'Wallet Credited 💳', bodyTemplate: '₹{{amount}} has been credited to your FlashCart wallet.', category: 'WALLET', channels: ['IN_APP', 'PUSH', 'SMS'], isActive: true },
    { code: 'PEAK_HOUR_BONUS', title: 'Peak Hour Bonus Active 🔥', bodyTemplate: 'Earn 1.5x earnings per trip in Koramangala zone for the next 2 hours!', category: 'DELIVERY', channels: ['IN_APP', 'PUSH'], isActive: true },
    { code: 'NEW_DELIVERY_REQUEST', title: 'New Order Request 📦', bodyTemplate: 'Order #{{orderId}} available at {{storeName}}.', category: 'DELIVERY', channels: ['IN_APP', 'PUSH', 'SMS'], isActive: true },
    { code: 'STORE_NEW_ORDER', title: 'New Express Order 🔔', bodyTemplate: 'Order #{{orderId}} received. Start picking immediately!', category: 'INVENTORY', channels: ['IN_APP', 'PUSH'], isActive: true },
    { code: 'LOW_INVENTORY_ALERT', title: 'Low Stock Warning ⚠️', bodyTemplate: 'Item {{productName}} has reached low stock threshold at {{storeName}}.', category: 'INVENTORY', channels: ['IN_APP', 'EMAIL'], isActive: true },
    { code: 'FRAUD_ALERT', title: 'Security Fraud Alert 🚨', bodyTemplate: 'Suspicious activity detected for user {{userId}} on order #{{orderId}}.', category: 'SYSTEM', channels: ['IN_APP', 'EMAIL'], isActive: true },
    { code: 'SYSTEM_HEALTH_ALERT', title: 'System Health Alert 🖥️', bodyTemplate: 'Server API latency spike detected: {{latency}}ms.', category: 'SYSTEM', channels: ['IN_APP', 'EMAIL'], isActive: true }
  ] as any[],
  notificationPreferences: [
    {
      userId: "u1",
      role: "CUSTOMER",
      emailEnabled: true,
      smsEnabled: true,
      pushEnabled: true,
      inAppEnabled: true,
      categories: { ORDER: true, WALLET: true, PROMO: true, SYSTEM: true, DELIVERY: true, INVENTORY: true }
    },
    {
      userId: "r1",
      role: "RIDER",
      emailEnabled: true,
      smsEnabled: true,
      pushEnabled: true,
      inAppEnabled: true,
      categories: { ORDER: true, WALLET: true, PROMO: true, SYSTEM: true, DELIVERY: true, INVENTORY: true }
    }
  ] as any[],
  notificationLogs: [] as any[]
};

export function simulateAssistant(prompt: string) {
  const p = prompt.toLowerCase();

  let items: { productId: string; quantity: number }[] = [];
  let explanation = "";

  // Breakfast / morning
  if (
    p.includes("breakfast") ||
    p.includes("morning") ||
    p.includes("breakfast for")
  ) {
    items = [
      { productId: "p6", quantity: 2 }, // Eggs
      { productId: "p9", quantity: 2 }, // Brown Bread
      { productId: "p7", quantity: 3 }, // Milk
      { productId: "p4", quantity: 2 }  // Spinach
    ];

    explanation =
      "🍳 I created a high-protein breakfast bundle with organic eggs, whole wheat bread, fresh milk, and spinach.";
  }

  // Paneer / curry
  else if (
    p.includes("paneer") ||
    p.includes("curry") ||
    p.includes("butter paneer")
  ) {
    items = [
      { productId: "p5", quantity: 2 },
      { productId: "p2", quantity: 2 },
      { productId: "p1", quantity: 1 }
    ];

    explanation =
      "🍲 I created a paneer meal bundle with fresh paneer and tomatoes, plus bananas for a healthy side snack.";
  }

  // Health / fitness
  else if (
    p.includes("health") ||
    p.includes("gym") ||
    p.includes("diet") ||
    p.includes("protein") ||
    p.includes("low carb")
  ) {
    items = [
      { productId: "p6", quantity: 2 },
      { productId: "p3", quantity: 1 },
      { productId: "p4", quantity: 2 }
    ];

    explanation =
      "🥗 I created a health-focused bundle with protein-rich eggs and fresh vegetables.";
  }

  // Snacks
  else if (
    p.includes("snack") ||
    p.includes("evening snack")
  ) {
    items = [
      { productId: "p10", quantity: 1 },
      { productId: "p12", quantity: 1 }
    ];

    explanation =
      "🥜 I created a simple snack bundle with roasted cashews and sparkling spring water.";
  }

  // Shopping for bread
  else if (
    p.includes("bread") ||
    p.includes("sandwich")
  ) {
    items = [
      { productId: "p9", quantity: 1 },
      { productId: "p5", quantity: 1 },
      { productId: "p2", quantity: 1 }
    ];

    explanation =
      "🥪 I created a quick sandwich bundle with whole wheat bread, paneer, and fresh tomatoes.";
  }

  // Default
  else {
    items = [
      { productId: "p1", quantity: 1 },
      { productId: "p7", quantity: 2 },
      { productId: "p9", quantity: 1 }
    ];

    explanation =
      "🛍️ I created a balanced everyday shopping list with bananas, milk, and whole wheat bread.";
  }

  // Validate inventory
  const validation = validateItems(items);

  const validItems = validation
    .filter((item) => item.valid)
    .map(({ productId, quantity }) => ({
      productId,
      quantity
    }));

  // Calculate actual price dynamically
  const totalPrice = calculateItemsTotal(validItems);

  // Calculate total item count
  const totalItems = validItems.reduce(
    (sum, item) => sum + item.quantity,
    0
  );

  return {
    explanation,
    items: validItems,
    totalItems,
    totalPrice,
    currency: "INR",
    validation
  };
}

export function simulateMealPlanner(
  diet: string,
  cuisine: string,
  calories: number,
  budget: number
) {
  const normalizedDiet = diet.toLowerCase();
  const normalizedCuisine = cuisine.toLowerCase();

  const isVegetarian =
    normalizedDiet.includes("vegetarian") ||
    normalizedDiet.includes("veg");

  const isHighProtein =
    normalizedDiet.includes("protein") ||
    normalizedDiet.includes("gym") ||
    normalizedDiet.includes("fitness");

  let breakfast;
  let lunch;
  let dinner;

  if (isHighProtein) {
    breakfast = {
      name: "High-Protein Egg & Spinach Breakfast",
      items: [
        { productId: "p6", quantity: 1 },
        { productId: "p4", quantity: 1 },
        { productId: "p9", quantity: 1 }
      ],
      explanation:
        "A protein-rich breakfast with organic eggs, fresh spinach, and whole wheat bread."
    };

    lunch = {
      name: "Paneer Cucumber Protein Bowl",
      items: [
        { productId: "p5", quantity: 1 },
        { productId: "p3", quantity: 1 },
        { productId: "p2", quantity: 1 }
      ],
      explanation:
        "Fresh paneer combined with hydrating cucumber and tomatoes."
    };

    dinner = {
      name: "Arhar Dal Basmati Bowl",
      items: [
        { productId: "p14", quantity: 1 },
        { productId: "p15", quantity: 1 }
      ],
      explanation:
        "A balanced dinner with protein-rich arhar dal and aromatic basmati rice."
    };
  } else if (isVegetarian) {
    breakfast = {
      name: "Spinach & Brown Bread Breakfast",
      items: [
        { productId: "p4", quantity: 1 },
        { productId: "p9", quantity: 1 },
        { productId: "p7", quantity: 1 }
      ],
      explanation:
        "A simple vegetarian breakfast with spinach, whole wheat bread, and milk."
    };

    lunch = {
      name: "Fresh Paneer Tomato Bowl",
      items: [
        { productId: "p5", quantity: 1 },
        { productId: "p2", quantity: 1 },
        { productId: "p3", quantity: 1 }
      ],
      explanation:
        "A fresh vegetarian meal made with paneer, tomatoes, and cucumber."
    };

    dinner = {
      name: "Dal & Basmati Rice",
      items: [
        { productId: "p14", quantity: 1 },
        { productId: "p15", quantity: 1 }
      ],
      explanation:
        "A comforting vegetarian dinner with aromatic rice and protein-rich arhar dal."
    };
  } else {
    breakfast = {
      name: "Egg & Spinach Breakfast",
      items: [
        { productId: "p6", quantity: 1 },
        { productId: "p4", quantity: 1 }
      ],
      explanation:
        "Eggs with fresh spinach for a nutritious start to the day."
    };

    lunch = {
      name: "Paneer & Tomato Lunch",
      items: [
        { productId: "p5", quantity: 1 },
        { productId: "p2", quantity: 1 }
      ],
      explanation:
        "A simple paneer and tomato meal."
    };

    dinner = {
      name: "Dal Rice Dinner",
      items: [
        { productId: "p14", quantity: 1 },
        { productId: "p15", quantity: 1 }
      ],
      explanation:
        "A satisfying rice and dal dinner."
    };
  }

  const allItems = [
    ...breakfast.items,
    ...lunch.items,
    ...dinner.items
  ];

  const totalPrice = calculateItemsTotal(allItems);

  return {
    breakfast,
    lunch,
    dinner,
    preferences: {
      diet,
      cuisine,
      targetCalories: calories,
      budget
    },
    totalPrice,
    withinBudget: totalPrice <= budget,
    currency: "INR"
  };
}

export function simulateRecipe(recipeName: string) {
  const name = recipeName.toLowerCase();
  if (name.includes("paneer")) {
    return {
      title: "Quick Shahi Paneer Butter Masala",
      prepTime: "10 mins",
      cookTime: "15 mins",
      itemsToBuy: [
        { productId: "p5", quantity: 2 },
        { productId: "p2", quantity: 2 }
      ],
      steps: [
        "Cut the premium soft Paneer into medium-sized cubes.",
        "Blanch and puree the Fresh Red Tomatoes in a blender.",
        "Sauté pureed tomatoes in oil with mild ginger-garlic paste and butter.",
        "Add fresh cream, paneer cubes, and let simmer on low heat for 5 minutes.",
        "Garnish with dried fenugreek leaves (kasuri methi) and serve hot."
      ],
      chefTip: "Paneer becomes extremely soft if soaked in warm water for 5 minutes before cooking."
    };
  }

  return {
    title: `Classic ${recipeName}`,
    prepTime: "15 mins",
    cookTime: "20 mins",
    itemsToBuy: [
      { productId: "p1", quantity: 1 },
      { productId: "p7", quantity: 1 }
    ],
    steps: [
      "Prepare all farm fresh ingredients from FlashCart catalog.",
      "Boil or cook ingredients evenly on standard medium heat.",
      "Season carefully with spices and fresh herbs.",
      "Serve warm while enjoying the fresh, high-nutrition score flavor."
    ],
    chefTip: "Adding a pinch of fresh lemon juice at the end elevates all herbal aromatics."
  };
}

export function simulatePantryScan(presetIndex: number) {
  if (presetIndex === 0) {
    return {
      detectedItems: [
        { productId: "p1", name: "Organic Fresh Bananas", status: "Low", confidence: 0.98 },
        { productId: "p7", name: "Pasteurized Full Cream Milk", status: "Empty", confidence: 0.95 },
        { productId: "p6", name: "Organic Free-Range Eggs", status: "Low", confidence: 0.91 }
      ],
      recipeSuggestion: "You can make delicious Banana-Milk Pancakes or a soft French Toast scramble!",
      suggestedAdditions: [
        { productId: "p7", quantity: 2 }, // Replenish Milk
        { productId: "p6", quantity: 1 }, // Replenish Eggs
        { productId: "p8", quantity: 1 }  // Add Sourdough Bread
      ]
    };
  } else {
    return {
      detectedItems: [
        { productId: "p2", name: "Fresh Red Tomatoes", status: "Low", confidence: 0.94 },
        { productId: "p5", name: "Premium Fresh Paneer", status: "Full", confidence: 0.88 },
        { productId: "p4", name: "Fresh Spinach (Palak)", status: "Empty", confidence: 0.92 }
      ],
      recipeSuggestion: "You have plenty of Paneer! Add tomatoes and fresh spinach to make healthy Palak Paneer.",
      suggestedAdditions: [
        { productId: "p4", quantity: 2 }, // Spinach (Palak)
        { productId: "p2", quantity: 1 }  // Tomatoes
      ]
    };
  }
}

export function getProduct(productId: string): Product | undefined {
  return DB_STATE.products.find((product) => product.id === productId);
}

export function calculateItemsTotal(
  items: { productId: string; quantity: number }[]
): number {
  return items.reduce((total, item) => {
    const product = getProduct(item.productId);

    if (!product) {
      return total;
    }

    return total + product.price * item.quantity;
  }, 0);
}

export function validateItems(
  items: { productId: string; quantity: number }[]
) {
  return items.map((item) => {
    const product = getProduct(item.productId);

    if (!product) {
      return {
        ...item,
        valid: false,
        reason: "Product not found"
      };
    }

    if (item.quantity <= 0) {
      return {
        ...item,
        valid: false,
        reason: "Quantity must be greater than zero"
      };
    }

    if (item.quantity > product.inventory) {
      return {
        ...item,
        valid: false,
        reason: `Only ${product.inventory} units available`
      };
    }

    return {
      ...item,
      valid: true,
      reason: null
    };
  });
}



export function getPresetDescription(index: number): string {
  if (index === 0) {
    return "A fridge door showing mostly empty racks, a nearly finished bunch of bananas, empty milk pouch space, and 1-2 eggs remaining.";
  }
  return "A veggie drawer containing plenty of cottage cheese paneer blocks, but absolutely out of green spinach leaves and very few tomatoes left.";
}
