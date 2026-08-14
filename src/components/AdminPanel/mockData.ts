import { Product as BaseProduct } from '../../types';

export interface Product extends BaseProduct {
  brand?: string;
}

export interface Category {
  id: string;
  name: string;
  parent?: string;
  icon: string;
  banner?: string;
  productCount: number;
}

export interface OrderItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

export interface Order {
  id: string;
  customerName: string;
  customerEmail: string;
  items: OrderItem[];
  total: number;
  status: 'Pending' | 'Packed' | 'Out for Delivery' | 'Delivered' | 'Cancelled' | 'Returned';
  createdAt: string;
  address: string;
  riderName?: string;
  paymentMethod: string;
  tax: number;
  discount: number;
}

export interface Customer {
  id: string;
  name: string;
  email: string;
  phone: string;
  avatar: string;
  addresses: string[];
  walletBalance: number;
  loyaltyPoints: number;
  joinDate: string;
  orderCount: number;
}

export interface Rider {
  id: string;
  name: string;
  phone: string;
  avatar: string;
  status: 'Online' | 'Offline' | 'In Delivery';
  activeAssignment?: string;
  rating: number;
  deliveriesCompleted: number;
  earnings: number;
  lat: number;
  lng: number;
}

export interface Coupon {
  id: string;
  code: string;
  type: 'percentage' | 'flat';
  value: number;
  expiry: string;
  usageLimit: number;
  usageCount: number;
  minOrderValue: number;
  status: 'Active' | 'Expired' | 'Disabled';
}

export interface AppBanner {
  id: string;
  title: string;
  type: 'Home' | 'Campaign' | 'Festival';
  imageUrl: string;
  linkTo: string;
  status: 'Active' | 'Scheduled' | 'Inactive';
}

export const initialProducts: Product[] = [
  { id: 'p1', name: 'Fresh Organic Bananas', category: 'Fruits & Vegetables', brand: 'NatureFresh', price: 69, unit: '1 kg', inventory: 15, image: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120&q=80', rating: 4.8, carbonEmission: 0.2, ecoScore: 'A', reviewsCount: 124, calories: 89, protein: 1.1, deliveryTimeMins: 10 },
  { id: 'p2', name: 'Fresh Avocado Pack', category: 'Fruits & Vegetables', brand: 'NatureFresh', price: 189, unit: '2 pcs', inventory: 42, image: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=120&q=80', rating: 4.7, carbonEmission: 0.8, ecoScore: 'B', reviewsCount: 85, calories: 160, protein: 2, deliveryTimeMins: 10 },
  { id: 'p3', name: 'Sourdough Whole Wheat Bread', category: 'Bakery & Dairy', brand: 'LaBoulangerie', price: 85, unit: '400g', inventory: 12, image: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=120&q=80', rating: 4.9, carbonEmission: 0.4, ecoScore: 'A', reviewsCount: 230, calories: 240, protein: 8, deliveryTimeMins: 12 },
  { id: 'p4', name: 'Farm Fresh Milk (Tone)', category: 'Bakery & Dairy', brand: 'MilkyWay', price: 32, unit: '500ml', inventory: 60, image: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=120&q=80', rating: 4.6, carbonEmission: 0.9, ecoScore: 'C', reviewsCount: 340, calories: 60, protein: 3.2, deliveryTimeMins: 8 },
  { id: 'p5', name: 'Greek Yogurt Blueberry', category: 'Bakery & Dairy', brand: 'MilkyWay', price: 45, unit: '150g', inventory: 25, image: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=120&q=80', rating: 4.7, carbonEmission: 0.5, ecoScore: 'B', reviewsCount: 190, calories: 120, protein: 10, deliveryTimeMins: 8 },
  { id: 'p6', name: 'Premium Coffee Beans', category: 'Beverages', brand: 'BrewCraft', price: 499, unit: '250g', inventory: 8, image: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=120&q=80', rating: 4.9, carbonEmission: 1.2, ecoScore: 'C', reviewsCount: 412, calories: 2, protein: 0.2, deliveryTimeMins: 15 },
  { id: 'p7', name: 'Sugar-free Oat Milk', category: 'Beverages', brand: 'BrewCraft', price: 210, unit: '1 Litre', inventory: 34, image: 'https://images.unsplash.com/photo-1553456558-aff63285bdd1?w=120&q=80', rating: 4.5, carbonEmission: 0.3, ecoScore: 'A', reviewsCount: 155, calories: 45, protein: 1, deliveryTimeMins: 10 },
  { id: 'p8', name: 'Crunchy Chocolate Granola', category: 'Snacks & Cereal', brand: 'FitMeal', price: 250, unit: '350g', inventory: 18, image: 'https://images.unsplash.com/photo-1517881917430-e70dfb3610aa?w=120&q=80', rating: 4.7, carbonEmission: 0.6, ecoScore: 'B', reviewsCount: 98, calories: 450, protein: 8, deliveryTimeMins: 10 },
];

export const initialCategories: Category[] = [
  { id: 'c1', name: 'Fruits & Vegetables', icon: 'Apple', productCount: 34, banner: 'https://images.unsplash.com/photo-1610348725531-843dff14722a?w=400&q=80' },
  { id: 'c2', name: 'Bakery & Dairy', icon: 'Milk', productCount: 48, banner: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80' },
  { id: 'c3', name: 'Beverages', icon: 'Coffee', productCount: 29, banner: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=400&q=80' },
  { id: 'c4', name: 'Snacks & Cereal', icon: 'Cookie', productCount: 56, banner: 'https://images.unsplash.com/photo-1599490659223-e1b22533e462?w=400&q=80' },
  { id: 'c5', name: 'Organic Greens', parent: 'Fruits & Vegetables', icon: 'Leaf', productCount: 12, banner: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80' },
];

export const initialOrders: Order[] = [
  {
    id: 'FC-8491A',
    customerName: 'Aravind K.',
    customerEmail: 'aravind@gmail.com',
    items: [
      { productId: 'p1', name: 'Fresh Organic Bananas', price: 69, quantity: 2 },
      { productId: 'p4', name: 'Farm Fresh Milk (Tone)', price: 32, quantity: 1 }
    ],
    total: 170,
    status: 'Pending',
    createdAt: '2026-07-21T09:30:00Z',
    address: 'Flat 402, Elite Heights, Sector-3, HSR Layout, Bangalore',
    paymentMethod: 'Wallet',
    tax: 12,
    discount: 10
  },
  {
    id: 'FC-9012C',
    customerName: 'Nisha Sharma',
    customerEmail: 'nisha.sharma@yahoo.com',
    items: [
      { productId: 'p3', name: 'Sourdough Whole Wheat Bread', price: 85, quantity: 1 },
      { productId: 'p5', name: 'Greek Yogurt Blueberry', price: 45, quantity: 3 }
    ],
    total: 220,
    status: 'Delivered',
    createdAt: '2026-07-21T08:15:00Z',
    address: 'Villa 15, Spring Fields, Sarjapur Road, Bangalore',
    riderName: 'Suresh Kumar',
    paymentMethod: 'UPI',
    tax: 18,
    discount: 18
  },
  {
    id: 'FC-7391B',
    customerName: 'Rahul Roy',
    customerEmail: 'rahul.roy@gmail.com',
    items: [
      { productId: 'p6', name: 'Premium Coffee Beans', price: 499, quantity: 1 }
    ],
    total: 499,
    status: 'Out for Delivery',
    createdAt: '2026-07-21T10:02:00Z',
    address: 'Cabin 3B, Tech Sparks, Indiranagar, Bangalore',
    riderName: 'Mahesh Patil',
    paymentMethod: 'Credit Card',
    tax: 42,
    discount: 42
  },
  {
    id: 'FC-4211D',
    customerName: 'Pooja Hegde',
    customerEmail: 'pooja@outlook.com',
    items: [
      { productId: 'p2', name: 'Fresh Avocado Pack', price: 189, quantity: 1 },
      { productId: 'p7', name: 'Sugar-free Oat Milk', price: 210, quantity: 1 }
    ],
    total: 399,
    status: 'Packed',
    createdAt: '2026-07-21T10:10:00Z',
    address: 'Apt 101, Green Glades, Koramangala 4th Block, Bangalore',
    paymentMethod: 'Netbanking',
    tax: 30,
    discount: 30
  }
];

export const initialCustomers: Customer[] = [
  {
    id: 'c_01',
    name: 'Aravind K.',
    email: 'aravind@gmail.com',
    phone: '+91 98450 12345',
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=120&q=80',
    addresses: ['Flat 402, Elite Heights, Sector-3, HSR Layout, Bangalore'],
    walletBalance: 1200,
    loyaltyPoints: 340,
    joinDate: '2025-10-15',
    orderCount: 42
  },
  {
    id: 'c_02',
    name: 'Nisha Sharma',
    email: 'nisha.sharma@yahoo.com',
    phone: '+91 91234 56789',
    avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&q=80',
    addresses: ['Villa 15, Spring Fields, Sarjapur Road, Bangalore'],
    walletBalance: 450,
    loyaltyPoints: 120,
    joinDate: '2026-01-20',
    orderCount: 15
  },
  {
    id: 'c_03',
    name: 'Rahul Roy',
    email: 'rahul.roy@gmail.com',
    phone: '+91 88776 55443',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&q=80',
    addresses: ['Cabin 3B, Tech Sparks, Indiranagar, Bangalore'],
    walletBalance: 0,
    loyaltyPoints: 85,
    joinDate: '2026-05-02',
    orderCount: 9
  }
];

export const initialRiders: Rider[] = [
  {
    id: 'r1',
    name: 'Suresh Kumar',
    phone: '+91 98765 43210',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
    status: 'In Delivery',
    activeAssignment: 'FC-9012C',
    rating: 4.9,
    deliveriesCompleted: 1420,
    earnings: 28400,
    lat: 12.9279,
    lng: 77.6250
  },
  {
    id: 'r2',
    name: 'Mahesh Patil',
    phone: '+91 94432 11009',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
    status: 'Online',
    activeAssignment: 'FC-7391B',
    rating: 4.75,
    deliveriesCompleted: 850,
    earnings: 17000,
    lat: 12.9320,
    lng: 77.6310
  },
  {
    id: 'r3',
    name: 'Vikram Singh',
    phone: '+91 77665 44332',
    avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=120&q=80',
    status: 'Offline',
    rating: 4.6,
    deliveriesCompleted: 420,
    earnings: 8400,
    lat: 12.9190,
    lng: 77.6180
  }
];

export const initialCoupons: Coupon[] = [
  { id: 'cp1', code: 'FLASH50', type: 'percentage', value: 50, expiry: '2026-08-31', usageLimit: 1000, usageCount: 425, minOrderValue: 200, status: 'Active' },
  { id: 'cp2', code: 'FREEDEL', type: 'flat', value: 30, expiry: '2026-07-31', usageLimit: 5000, usageCount: 1205, minOrderValue: 150, status: 'Active' },
  { id: 'cp3', code: 'SAVEMORE', type: 'flat', value: 100, expiry: '2026-06-30', usageLimit: 500, usageCount: 500, minOrderValue: 500, status: 'Expired' }
];

export const initialBanners: AppBanner[] = [
  { id: 'b1', title: 'Monsoon Quick Feast', type: 'Home', imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500&q=80', linkTo: '/categories/bakery', status: 'Active' },
  { id: 'b2', title: '50% Off Fresh Farm Veggies', type: 'Campaign', imageUrl: 'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=500&q=80', linkTo: '/categories/fruits', status: 'Active' },
  { id: 'b3', title: 'Independence Day Special', type: 'Festival', imageUrl: 'https://images.unsplash.com/photo-1532375810709-75b1da00537c?w=500&q=80', linkTo: '/campaign/independence', status: 'Scheduled' }
];

export const aiAnalytics = {
  popularSearches: [
    { query: 'high protein keto snack', count: 1240, change: '+18%' },
    { query: 'organic quick low glycemic veggies', count: 890, change: '+25%' },
    { query: 'allergen-free dairy substitutes', count: 650, change: '+5%' },
    { query: 'quick immunity booster foods', count: 520, change: '+12%' }
  ],
  recipeRequests: [
    { recipeName: 'Paneer Makhani (Eco-Friendly Ingredients)', count: 420, matchRate: '98%' },
    { recipeName: 'Gluten-Free Oats Chia Pudding', count: 350, matchRate: '94%' },
    { recipeName: 'Creamy Mushroom Sourdough Toast', count: 210, matchRate: '89%' }
  ],
  budgetPlannerUsage: [
    { bracket: '₹1000 - ₹2000 Weekly', users: 1840 },
    { bracket: '₹2000 - ₹4000 Weekly', users: 2450 },
    { bracket: '₹4000+ Weekly', users: 950 }
  ],
  aiRecommendations: [
    { trigger: 'Sourdough Bread Bread Bought', recommended: 'Fresh Avocado Pack', conversionRate: '42.5%' },
    { trigger: 'Organic Bananas Bought', recommended: 'Tone Milk (Tone)', conversionRate: '38.1%' },
    { trigger: 'Coffee Beans Bought', recommended: 'Oat Milk Sugar-Free', conversionRate: '29.4%' }
  ]
};

export const salesTrends = [
  { name: 'Mon', sales: 42000, orders: 120, customers: 98 },
  { name: 'Tue', sales: 48000, orders: 145, customers: 110 },
  { name: 'Wed', sales: 52000, orders: 160, customers: 135 },
  { name: 'Thu', sales: 49000, orders: 138, customers: 112 },
  { name: 'Fri', sales: 58000, orders: 180, customers: 154 },
  { name: 'Sat', sales: 74000, orders: 245, customers: 210 },
  { name: 'Sun', sales: 82000, orders: 280, customers: 242 },
];

export const categoryDistribution = [
  { name: 'Fruits & Veg', value: 34000 },
  { name: 'Bakery & Dairy', value: 28000 },
  { name: 'Beverages', value: 21000 },
  { name: 'Snacks & Cereal', value: 15000 },
];
