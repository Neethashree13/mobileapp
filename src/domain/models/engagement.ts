/**
 * Engagement, Support & Communication Models
 */

import { BaseDomainModel } from '../types';
import { NotificationType, TicketPriority, TicketStatus } from '../enums';

export interface Notification extends BaseDomainModel {
  userId: string;
  title: string;
  body: string;
  type: NotificationType;
  isRead: boolean;
  actionUrl?: string;
  metadata?: Record<string, unknown>;
}

export interface Rating {
  averageRating: number;
  totalRatings: number;
  fiveStarCount: number;
  fourStarCount: number;
  threeStarCount: number;
  twoStarCount: number;
  oneStarCount: number;
}

export interface Review extends BaseDomainModel {
  userId: string;
  userName: string;
  userAvatar?: string;
  productId: string;
  orderId?: string;
  ratingScore: number; // 1-5
  comment: string;
  images?: string[];
  isVerifiedPurchase: boolean;
  likeCount: number;
}

export interface SupportTicket extends BaseDomainModel {
  ticketNumber: string;
  userId: string;
  orderId?: string;
  subject: string;
  description: string;
  category: 'ORDER_ISSUE' | 'REFUND' | 'DELIVERY' | 'APP_BUG' | 'OTHER';
  status: TicketStatus;
  priority: TicketPriority;
  assignedAgentId?: string;
  closedAt?: string;
}

export interface ChatMessage extends BaseDomainModel {
  ticketId?: string;
  orderId?: string;
  senderId: string;
  senderRole: 'CUSTOMER' | 'SUPPORT' | 'DELIVERY_PARTNER' | 'AI_BOT';
  senderName: string;
  messageText: string;
  attachmentUrls?: string[];
  isRead: boolean;
}

export interface Referral extends BaseDomainModel {
  referrerUserId: string;
  referredUserId: string;
  referralCode: string;
  status: 'PENDING' | 'QUALIFIED' | 'REWARDED';
  rewardAmount: number;
  rewardClaimedAt?: string;
}
