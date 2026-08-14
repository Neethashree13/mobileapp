/**
 * Payment, Transaction & Wallet Domain Models
 */

import { BaseDomainModel } from '../types';
import { PaymentMethodType, PaymentStatus, TransactionType } from '../enums';

export interface Wallet extends BaseDomainModel {
  userId: string;
  balance: number;
  currency: string;
  cashbackEarned: number;
  isLocked: boolean;
}

export interface Transaction extends BaseDomainModel {
  userId: string;
  walletId?: string;
  orderId?: string;
  type: TransactionType;
  amount: number;
  currency: string;
  referenceNumber: string;
  description: string;
  status: 'SUCCESS' | 'PENDING' | 'FAILED';
  balanceAfter: number;
}

export interface Payment extends BaseDomainModel {
  orderId: string;
  userId: string;
  amount: number;
  currency: string;
  method: PaymentMethodType;
  status: PaymentStatus;
  gatewayTransactionId?: string;
  gatewayProvider?: string;
  failureReason?: string;
  paidAt?: string;
}
