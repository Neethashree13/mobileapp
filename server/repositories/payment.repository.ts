import { dbQuery, usePostgreSQL } from "../config/database";
import { DB_STATE } from "../config/dbState";

export type PaymentStatus = 
  | "CREATED"
  | "PENDING"
  | "PROCESSING"
  | "SUCCESS"
  | "FAILED"
  | "CANCELLED"
  | "REFUNDED"
  | "PARTIALLY_REFUNDED";

export interface PaymentRecord {
  id: string;
  orderId: string;
  userId?: string;

  amount: number;
  currency: string;

  paymentMethod: string;
  provider: string;

  status: PaymentStatus;

  transactionId: string;

  razorpayOrderId?: string;
  razorpayPaymentId?: string;
  razorpaySignature?: string;

  idempotencyKey?: string;
  gatewayRef?: string;

  errorMessage?: string;

  riskScore: number;
  isFlagged: boolean;

  createdAt: string;
  updatedAt: string;
}

export interface WalletLedgerEntry {
  id: string;
  userId: string;
  type: "CREDIT" | "DEBIT";
  category: "TOPUP" | "ORDER_PAYMENT" | "REFUND" | "CASHBACK" | "REWARD_REDEMPTION" | "ADMIN_ADJUSTMENT" | "WITHDRAWAL";
  amount: number;
  balanceAfter: number;
  referenceId: string;
  description: string;
  createdAt: string;
}

export interface RefundRecord {
  id: string;
  paymentId: string;
  orderId: string;
  userId: string;
  amount: number;
  refundType: "FULL" | "PARTIAL";
  reason: string;
  status: "REQUESTED" | "APPROVED" | "REJECTED" | "PROCESSED" | "FAILED";
  gatewayRefundId?: string;
  approvedBy?: string;
  createdAt: string;
}

export class PaymentRepository {
  // 1. Create Payment Transaction
  static async createPayment(data: {
    orderId: string;
    userId?: string;
    amount: number;
    paymentMethod: string;
    provider?: string;
    idempotencyKey?: string;
  }): Promise<PaymentRecord> {
    const paymentId = "PAY-" + Math.floor(100000 + Math.random() * 900000);
    const txnId = "TXN-" + (data.provider || "GATEWAY").toUpperCase() + "-" + Math.random().toString(36).substring(2, 8).toUpperCase();
    const providerName = data.provider || (data.paymentMethod === 'Wallet' ? 'FlashWallet' : 'Razorpay');
    
    // Simple Fraud Risk Scoring Rule
    const riskScore = data.amount > 10000 ? 0.75 : data.amount > 5000 ? 0.35 : 0.05;
    const isFlagged = riskScore >= 0.70;

    const newPayment: PaymentRecord = {
      id: paymentId,
      orderId: data.orderId,
      userId: data.userId || "u1",
      amount: Number(data.amount),
      currency: "INR",
      paymentMethod: data.paymentMethod,
      provider: providerName,
      status: "CREATED",
      transactionId: txnId,
      idempotencyKey: data.idempotencyKey || `IDEM-${Date.now()}`,
      gatewayRef: `GREF-${Math.floor(1000 + Math.random() * 9000)}`,
      riskScore,
      isFlagged,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO payment_transactions (id, order_id, user_id, amount, currency, payment_method, provider, status, transaction_id, idempotency_key, gateway_ref, risk_score, is_flagged)
        VALUES ($1, $2, (SELECT id FROM users WHERE firebase_uid = $3 OR id = $3 LIMIT 1), $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      `, [
        newPayment.id,
        newPayment.orderId,
        data.userId || "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
        newPayment.amount,
        newPayment.currency,
        newPayment.paymentMethod,
        newPayment.provider,
        newPayment.status,
        newPayment.transactionId,
        newPayment.idempotencyKey,
        newPayment.gatewayRef,
        newPayment.riskScore,
        newPayment.isFlagged
      ]);
      return newPayment;
    }

    if (!DB_STATE.paymentTransactions) DB_STATE.paymentTransactions = [];
    DB_STATE.paymentTransactions.unshift(newPayment as any);
    return newPayment;
  }

  // 2. Update Payment Status Machine
  static async updatePaymentStatus(
    id: string, 
    status: PaymentStatus, 
    errorMessage?: string
  ): Promise<PaymentRecord | null> {
    if (usePostgreSQL) {
      const res = await dbQuery(`
        UPDATE payment_transactions 
        SET status = $1, error_message = $2, updated_at = CURRENT_TIMESTAMP
        WHERE id = $3 OR transaction_id = $3
        RETURNING id, order_id as "orderId", user_id as "userId", amount, currency, 
                  payment_method as "paymentMethod", provider, status, transaction_id as "transactionId", 
                  idempotency_key as "idempotencyKey", gateway_ref as "gatewayRef", 
                  risk_score as "riskScore", is_flagged as "isFlagged", 
                  created_at as "createdAt", updated_at as "updatedAt"
      `, [status, errorMessage || null, id]);

      if (res.rows.length > 0) {
        const row = res.rows[0];
        return {
          ...row,
          amount: Number(row.amount),
          riskScore: Number(row.riskScore)
        };
      }
      return null;
    }

    const tx = (DB_STATE.paymentTransactions || []).find((t: any) => t.id === id || t.transactionId === id);
    if (tx) {
      tx.status = status;
      if (errorMessage) tx.errorMessage = errorMessage;
      tx.updatedAt = new Date().toISOString();
      return tx;
    }
    return null;
  }

  // 3. Get Payment By ID
  static async getPaymentById(id: string): Promise<PaymentRecord | null> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, order_id as "orderId", user_id as "userId", amount, currency, 
               payment_method as "paymentMethod", provider, status, transaction_id as "transactionId", 
               idempotency_key as "idempotencyKey", gateway_ref as "gatewayRef", error_message as "errorMessage",
               risk_score as "riskScore", is_flagged as "isFlagged", 
               created_at as "createdAt", updated_at as "updatedAt"
        FROM payment_transactions WHERE id = $1 OR transaction_id = $1 LIMIT 1
      `, [id]);

      if (rows.length > 0) {
        const row = rows[0];
        return {
          ...row,
          amount: Number(row.amount),
          riskScore: Number(row.riskScore)
        };
      }
      return null;
    }

    const tx = (DB_STATE.paymentTransactions || []).find((t: any) => t.id === id || t.transactionId === id);
    return tx || null;
  }

  // 4. Get Payments History
  static async getHistory(userId?: string): Promise<PaymentRecord[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, order_id as "orderId", user_id as "userId", amount, currency, 
               payment_method as "paymentMethod", provider, status, transaction_id as "transactionId", 
               idempotency_key as "idempotencyKey", gateway_ref as "gatewayRef", error_message as "errorMessage",
               risk_score as "riskScore", is_flagged as "isFlagged", 
               created_at as "createdAt", updated_at as "updatedAt"
        FROM payment_transactions 
        WHERE ($1::text IS NULL OR user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id = $1))
        ORDER BY created_at DESC LIMIT 50
      `, [userId || null]);

      return rows.map(r => ({
        ...r,
        amount: Number(r.amount),
        riskScore: Number(r.riskScore)
      }));
    }

    return DB_STATE.paymentTransactions || [];
  }

  // Legacy compatibility helper
  static async logPayment(
    orderId: string,
    amount: number,
    paymentMethod: string,
    transactionId: string
  ): Promise<void> {
    await this.createPayment({
      orderId,
      amount,
      paymentMethod,
      provider: paymentMethod.includes('Razorpay') ? 'Razorpay' : 'FlashWallet'
    });
  }

  // 5. Double-entry Wallet Ledger
  static async logWalletLedger(
    userId: string,
    type: "CREDIT" | "DEBIT",
    category: "TOPUP" | "ORDER_PAYMENT" | "REFUND" | "CASHBACK" | "REWARD_REDEMPTION" | "ADMIN_ADJUSTMENT" | "WITHDRAWAL",
    amount: number,
    balanceAfter: number,
    referenceId: string,
    description: string
  ): Promise<WalletLedgerEntry> {
    const entry: WalletLedgerEntry = {
      id: "wled_" + Math.random().toString(36).substring(2, 9),
      userId,
      type,
      category,
      amount,
      balanceAfter,
      referenceId,
      description,
      createdAt: new Date().toISOString()
    };

    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO wallet_ledger (user_id, type, category, amount, balance_after, reference_id, description)
        VALUES ((SELECT id FROM users WHERE firebase_uid = $1 OR id = $1 LIMIT 1), $2, $3, $4, $5, $6, $7)
      `, [userId, type, category, amount, balanceAfter, referenceId, description]);
      return entry;
    }

    if (!DB_STATE.walletLedger) DB_STATE.walletLedger = [];
    DB_STATE.walletLedger.unshift(entry as any);
    return entry;
  }

  // 6. Get Wallet Ledger
  static async getWalletLedger(userId?: string): Promise<WalletLedgerEntry[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, user_id as "userId", type, category, amount, balance_after as "balanceAfter",
               reference_id as "referenceId", description, created_at as "createdAt"
        FROM wallet_ledger 
        WHERE ($1::text IS NULL OR user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id = $1))
        ORDER BY created_at DESC LIMIT 50
      `, [userId || null]);

      return rows.map(r => ({
        ...r,
        amount: Number(r.amount),
        balanceAfter: Number(r.balanceAfter)
      }));
    }

    return DB_STATE.walletLedger || [];
  }

  // 7. Create Refund Record
  static async createRefund(
    paymentId: string,
    orderId: string,
    userId: string,
    amount: number,
    reason: string,
    isPartial: boolean = false
  ): Promise<RefundRecord> {
    const refundId = "REF-" + Math.floor(10000 + Math.random() * 90000);
    const refund: RefundRecord = {
      id: refundId,
      paymentId,
      orderId,
      userId,
      amount,
      refundType: isPartial ? "PARTIAL" : "FULL",
      reason,
      status: "PROCESSED",
      gatewayRefundId: "GW-REF-" + Math.random().toString(36).substring(2, 8).toUpperCase(),
      approvedBy: "System Auto-Refund Engine",
      createdAt: new Date().toISOString()
    };

    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO refund_records (id, payment_id, order_id, user_id, amount, refund_type, reason, status, gateway_refund_id, approved_by)
        VALUES ($1, $2, $3, (SELECT id FROM users WHERE firebase_uid = $4 OR id = $4 LIMIT 1), $5, $6, $7, $8, $9, $10)
      `, [
        refund.id,
        refund.paymentId,
        refund.orderId,
        userId,
        refund.amount,
        refund.refundType,
        refund.reason,
        refund.status,
        refund.gatewayRefundId,
        refund.approvedBy
      ]);
    } else {
      if (!DB_STATE.refundRecords) DB_STATE.refundRecords = [];
      DB_STATE.refundRecords.unshift(refund as any);
    }

    // Update payment status
    await this.updatePaymentStatus(paymentId, isPartial ? "PARTIALLY_REFUNDED" : "REFUNDED");
    return refund;
  }

  // 8. Get Refunds
  static async getRefunds(userId?: string): Promise<RefundRecord[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, payment_id as "paymentId", order_id as "orderId", user_id as "userId", 
               amount, refund_type as "refundType", reason, status, 
               gateway_refund_id as "gatewayRefundId", approved_by as "approvedBy", 
               created_at as "createdAt"
        FROM refund_records 
        WHERE ($1::text IS NULL OR user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id = $1))
        ORDER BY created_at DESC LIMIT 50
      `, [userId || null]);

      return rows.map(r => ({
        ...r,
        amount: Number(r.amount)
      }));
    }

    return DB_STATE.refundRecords || [];
  }

  // 9. Reward Points System
  static async logRewardPoints(
    userId: string,
    points: number,
    type: "EARNED" | "REDEEMED",
    reason: string
  ): Promise<number> {
    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO reward_ledger (user_id, points, type, reason, expiry_date)
        VALUES ((SELECT id FROM users WHERE firebase_uid = $1 OR id = $1 LIMIT 1), $2, $3, $4, CURRENT_TIMESTAMP + INTERVAL '90 days')
      `, [userId, points, type, reason]);

      const totalRes = await dbQuery(`
        SELECT 
          COALESCE(SUM(CASE WHEN type = 'EARNED' THEN points ELSE -points END), 0) as balance
        FROM reward_ledger WHERE user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id = $1)
      `, [userId]);

      return parseInt(totalRes.rows[0]?.balance || "0", 10);
    }

    if (!DB_STATE.rewardLedger) DB_STATE.rewardLedger = [];
    DB_STATE.rewardLedger.unshift({
      id: "rw_" + Math.random().toString(36).substring(2, 8),
      userId,
      points,
      type,
      reason,
      createdAt: new Date().toISOString()
    } as any);

    if (type === "EARNED") {
      DB_STATE.rewardPoints = (DB_STATE.rewardPoints || 0) + points;
    } else {
      DB_STATE.rewardPoints = Math.max(0, (DB_STATE.rewardPoints || 0) - points);
    }
    return DB_STATE.rewardPoints;
  }

  static async getRewardPointsSummary(userId?: string): Promise<{ points: number; history: any[] }> {
    if (usePostgreSQL) {
      const balanceRes = await dbQuery(`
        SELECT 
          COALESCE(SUM(CASE WHEN type = 'EARNED' THEN points ELSE -points END), 0) as balance
        FROM reward_ledger WHERE ($1::text IS NULL OR user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id = $1))
      `, [userId || null]);

      const historyRes = await dbQuery(`
        SELECT id, user_id as "userId", points, type, reason, created_at as "createdAt"
        FROM reward_ledger WHERE ($1::text IS NULL OR user_id IN (SELECT id FROM users WHERE firebase_uid = $1 OR id = $1))
        ORDER BY created_at DESC LIMIT 30
      `, [userId || null]);

      return {
        points: parseInt(balanceRes.rows[0]?.balance || "0", 10),
        history: historyRes.rows
      };
    }

    return {
      points: DB_STATE.rewardPoints || 350,
      history: DB_STATE.rewardLedger || []
    };
  }

  // 10. Webhook & Gateway Logs
  static async logGatewayWebhook(
    provider: string,
    eventType: string,
    payload: any,
    signature: string,
    status: string = "VERIFIED"
  ): Promise<void> {
    if (usePostgreSQL) {
      await dbQuery(`
        INSERT INTO gateway_logs (provider, event_type, payload, signature, status)
        VALUES ($1, $2, $3, $4, $5)
      `, [provider, eventType, JSON.stringify(payload), signature, status]);
      return;
    }

    if (!DB_STATE.gatewayLogs) DB_STATE.gatewayLogs = [];
    DB_STATE.gatewayLogs.unshift({
      id: "gwlog_" + Math.random().toString(36).substring(2, 8),
      provider,
      eventType,
      payload,
      signature,
      status,
      createdAt: new Date().toISOString()
    } as any);
  }

  static async getGatewayLogs(): Promise<any[]> {
    if (usePostgreSQL) {
      const { rows } = await dbQuery(`
        SELECT id, provider, event_type as "eventType", payload, signature, status, created_at as "createdAt"
        FROM gateway_logs ORDER BY created_at DESC LIMIT 50
      `);
      return rows;
    }
    return DB_STATE.gatewayLogs || [];
  }

  // 11. Admin Dashboard Stats
  static async getAdminDashboardStats(): Promise<any> {
    const payments = await this.getHistory();
    const refunds = await this.getRefunds();

    const totalVolume = payments
      .filter(p => p.status === 'SUCCESS' || p.status === 'REFUNDED')
      .reduce((sum, p) => sum + p.amount, 0);

    const successCount = payments.filter(p => p.status === 'SUCCESS').length;
    const failedCount = payments.filter(p => p.status === 'FAILED').length;
    const successRate = payments.length > 0 ? Math.round((successCount / payments.length) * 100) : 100;

    const gatewayBreakdown: Record<string, number> = {};
    payments.forEach(p => {
      const pvd = p.provider || p.paymentMethod;
      gatewayBreakdown[pvd] = (gatewayBreakdown[pvd] || 0) + p.amount;
    });

    const flaggedCount = payments.filter(p => p.isFlagged).length;

    return {
      totalVolume,
      totalTransactions: payments.length,
      successRate,
      failedCount,
      refundsCount: refunds.length,
      flaggedTransactionsCount: flaggedCount,
      gatewayBreakdown,
      recentPayments: payments.slice(0, 10),
      recentRefunds: refunds.slice(0, 10)
    };
  }
}
