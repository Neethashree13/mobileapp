import {
  PaymentRepository,
  PaymentRecord,
} from "../repositories/payment.repository";

import { UserRepository } from "../repositories/user.repository";
import { ActivityRepository } from "../repositories/activity.repository";
import { NotificationService } from "./notification.service";

import {
  createRazorpayOrder,
  verifyRazorpayPayment,
  getRazorpayKeyId,
} from "./razorpay.service";

export class PaymentService {

  // ============================================================
  // GET PAYMENT INFO
  // ============================================================

  static async getPaymentInfo(
    firebaseUid: string = ""
  ): Promise<{
    walletBalance: number;
    rewardPoints: number;
    payments: PaymentRecord[];
    ledger: any[];
  }> {

    const walletBalance =
      await UserRepository.getWalletBalance(firebaseUid);

    const payments =
      await PaymentRepository.getHistory(firebaseUid);

    const ledger =
      await PaymentRepository.getWalletLedger(firebaseUid);

    const rewardSummary =
      await PaymentRepository.getRewardPointsSummary(firebaseUid);

    return {
      walletBalance,
      rewardPoints: rewardSummary.points,
      payments,
      ledger,
    };
  }

  // ============================================================
  // CREATE PAYMENT
  // ============================================================

  static async createPayment(
    data: {
      orderId: string;
      amount: number;
      paymentMethod: string;
      provider?: string;
      idempotencyKey?: string;
      isGiftCard?: boolean;
      giftCardCode?: string;
    },
    firebaseUid: string = ""
  ): Promise<any> {

    if (!firebaseUid) {
      throw new Error("User authentication required");
    }

    if (!data.orderId) {
      throw new Error("Order ID is required");
    }

    if (!data.amount || data.amount <= 0) {
      throw new Error("Invalid payment amount");
    }

    const user =
      await UserRepository.getProfile(firebaseUid);

    if (!user) {
      throw new Error("User not found");
    }

    // ----------------------------------------------------------
    // GIFT CARD VALIDATION
    // ----------------------------------------------------------

    if (
      data.isGiftCard ||
      data.paymentMethod === "GiftCard"
    ) {
      if (
        !data.giftCardCode ||
        data.giftCardCode.trim().length === 0
      ) {
        throw new Error("Invalid Gift Card Code");
      }
    }

    // ----------------------------------------------------------
    // IDEMPOTENCY
    // ----------------------------------------------------------

    if (data.idempotencyKey) {

      const existing =
        await PaymentRepository.getPaymentByIdempotencyKey(
          data.idempotencyKey
        );

      if (existing) {

        return {
          ...existing,

          razorpayOrderId:
            existing.razorpayOrderId || null,

          razorpayKeyId:
            existing.razorpayKeyId ||
            getRazorpayKeyId(),
        };
      }
    }

    // ----------------------------------------------------------
    // ONLINE PAYMENT
    // ----------------------------------------------------------

    const isOnlinePayment =
      data.paymentMethod === "UPI (Paytm)" ||
      data.paymentMethod === "UPI (Google Pay)" ||
      data.paymentMethod === "Saved Credit Card" ||
      data.paymentMethod === "Razorpay";

    if (isOnlinePayment) {

      // Create Razorpay order FIRST
      const razorpayOrder =
        await createRazorpayOrder(
          data.amount,
          data.orderId
        );

      // Create internal payment record
      const payment =
        await PaymentRepository.createPayment({
          orderId: data.orderId,
          userId: user.id || firebaseUid,
          amount: data.amount,
          paymentMethod: data.paymentMethod,
          provider: "Razorpay",
          idempotencyKey: data.idempotencyKey,
        });

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "PENDING"
      );

      payment.status = "PENDING";

      return {
        payment,

        paymentId: payment.id,

        razorpayOrderId:
          razorpayOrder.id,

        razorpayKeyId:
          getRazorpayKeyId(),

        amount:
          data.amount,

        currency: "INR",
      };
    }

    // ----------------------------------------------------------
    // CASH ON DELIVERY
    // ----------------------------------------------------------

    if (
      data.paymentMethod ===
      "Cash on Delivery (COD)"
    ) {

      const payment =
        await PaymentRepository.createPayment({
          orderId: data.orderId,
          userId: user.id || firebaseUid,
          amount: data.amount,
          paymentMethod: data.paymentMethod,
          provider: "COD",
          idempotencyKey: data.idempotencyKey,
        });

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "PENDING"
      );

      payment.status = "PENDING";

      return payment;
    }

    // ----------------------------------------------------------
    // WALLET
    // ----------------------------------------------------------

    if (
      data.paymentMethod === "Wallet" ||
      data.paymentMethod ===
        "Shared Wallet (Family)"
    ) {

      const payment =
        await PaymentRepository.createPayment({
          orderId: data.orderId,
          userId: user.id || firebaseUid,
          amount: data.amount,
          paymentMethod: data.paymentMethod,
          provider: data.provider || "Wallet",
          idempotencyKey: data.idempotencyKey,
        });

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "PENDING"
      );

      const currentBalance =
        await UserRepository.getWalletBalance(
          firebaseUid
        );

      if (currentBalance < data.amount) {

        await PaymentRepository.updatePaymentStatus(
          payment.id,
          "FAILED",
          "Insufficient wallet balance"
        );

        throw new Error(
          `Insufficient wallet balance. Available: ₹${currentBalance}, Required: ₹${data.amount}`
        );
      }

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "PROCESSING"
      );

      const newBalance =
        await UserRepository.updateWalletBalance(
          firebaseUid,
          -data.amount
        );

      await PaymentRepository.logWalletLedger(
        user.id || firebaseUid,
        "DEBIT",
        "ORDER_PAYMENT",
        data.amount,
        newBalance,
        data.orderId,
        `Payment for Order #${data.orderId}`
      );

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "SUCCESS"
      );

      payment.status = "SUCCESS";

      await this.grantRewards(
        data.amount,
        firebaseUid,
        data.orderId
      );

      await ActivityRepository.log(
        user.id,
        "payment_success",
        `Paid ₹${data.amount} for order #${data.orderId} via FlashWallet`
      );

      return payment;
    }

    throw new Error(
      `Unsupported payment method: ${data.paymentMethod}`
    );
  }

  // ============================================================
  // VERIFY RAZORPAY PAYMENT
  // ============================================================

  static async verifyPayment(
    data: {
      paymentId: string;
      transactionId?: string;
      razorpayOrderId?: string;
      gatewaySignature?: string;
      simulateFailure?: boolean;
    },
    firebaseUid: string = ""
  ): Promise<{
    status: string;
    payment: PaymentRecord;
  }> {

    if (!firebaseUid) {
      throw new Error("User authentication required");
    }

    const payment =
      await PaymentRepository.getPaymentById(
        data.paymentId
      );

    if (!payment) {
      throw new Error(
        "Payment record not found"
      );
    }

    // ----------------------------------------------------------
    // ALREADY SUCCESSFUL
    // ----------------------------------------------------------

    if (payment.status === "SUCCESS") {
      return {
        status: "SUCCESS",
        payment,
      };
    }

    // ----------------------------------------------------------
    // TEST FAILURE
    // ----------------------------------------------------------

    if (data.simulateFailure) {

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "FAILED",
        "Simulated payment gateway decline"
      );

      payment.status = "FAILED";

      return {
        status: "FAILED",
        payment,
      };
    }

    // ----------------------------------------------------------
    // REQUIRED RAZORPAY DATA
    // ----------------------------------------------------------

    if (!data.transactionId) {
      throw new Error(
        "Razorpay payment ID is missing"
      );
    }

    if (!data.razorpayOrderId) {
      throw new Error(
        "Razorpay order ID is missing"
      );
    }

    if (!data.gatewaySignature) {
      throw new Error(
        "Razorpay signature is missing"
      );
    }

    // ----------------------------------------------------------
    // VERIFY SIGNATURE
    // ----------------------------------------------------------

    const valid =
      verifyRazorpayPayment(
        data.razorpayOrderId,
        data.transactionId,
        data.gatewaySignature
      );

    if (!valid) {

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "FAILED",
        "Invalid Razorpay payment signature"
      );

      payment.status = "FAILED";

      throw new Error(
        "Invalid Razorpay payment signature"
      );
    }

    // ----------------------------------------------------------
    // STORE TRANSACTION ID
    // ----------------------------------------------------------

    await PaymentRepository.updatePaymentTransaction(
      payment.id,
      data.transactionId,
      data.razorpayOrderId,
      data.gatewaySignature
    );

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------

    await PaymentRepository.updatePaymentStatus(
      payment.id,
      "SUCCESS"
    );

    payment.status = "SUCCESS";

    payment.transactionId =
      data.transactionId;

    // ----------------------------------------------------------
    // CASHBACK + REWARD POINTS
    // ----------------------------------------------------------

    await this.grantRewards(
      payment.amount,
      firebaseUid,
      payment.orderId
    );

    // ----------------------------------------------------------
    // ACTIVITY
    // ----------------------------------------------------------

    const user =
      await UserRepository.getProfile(
        firebaseUid
      );

    if (user) {
      await ActivityRepository.log(
        user.id,
        "payment_success",
        `Paid ₹${payment.amount} for order #${payment.orderId} via Razorpay`
      );
    }

    return {
      status: "SUCCESS",
      payment,
    };
  }

  // ============================================================
  // GRANT CASHBACK + REWARD POINTS
  // ============================================================

  private static async grantRewards(
    amount: number,
    firebaseUid: string,
    orderId: string
  ) {

    if (!firebaseUid) {
      return;
    }

    const user =
      await UserRepository.getProfile(
        firebaseUid
      );

    if (!user) {
      return;
    }

    // ----------------------------------------------------------
    // CASHBACK
    // ----------------------------------------------------------

    if (amount >= 300) {

      const cashbackAmount =
        Math.min(
          50,
          Math.round(amount * 0.05)
        );

      if (cashbackAmount > 0) {

        const cashbackBalance =
          await UserRepository.updateWalletBalance(
            firebaseUid,
            cashbackAmount
          );

        await PaymentRepository.logWalletLedger(
          user.id || firebaseUid,
          "CREDIT",
          "CASHBACK",
          cashbackAmount,
          cashbackBalance,
          orderId,
          `₹${cashbackAmount} Order Cashback`
        );
      }
    }

    // ----------------------------------------------------------
    // REWARD POINTS
    // ----------------------------------------------------------

    const pointsEarned =
      Math.floor(amount / 10);

    if (pointsEarned > 0) {

      await PaymentRepository.logRewardPoints(
        user.id || firebaseUid,
        pointsEarned,
        "EARNED",
        `Points earned for Order #${orderId}`
      );
    }
  }

  // ============================================================
  // WEBHOOK
  // ============================================================

  static async handleWebhook(
    provider: string,
    eventType: string,
    payload: any,
    signature: string
  ): Promise<{
    status: string;
    message: string;
  }> {

    if (!signature) {

      await PaymentRepository.logGatewayWebhook(
        provider,
        eventType,
        payload,
        signature,
        "INVALID_SIGNATURE"
      );

      return {
        status: "REJECTED",
        message: "Invalid webhook signature",
      };
    }

    await PaymentRepository.logGatewayWebhook(
      provider,
      eventType,
      payload,
      signature,
      "RECEIVED"
    );

    const paymentEntity =
      payload?.payload?.payment?.entity;

    const paymentId =
      paymentEntity?.id ||
      payload?.paymentId ||
      payload?.id;

    const razorpayOrderId =
      paymentEntity?.order_id ||
      payload?.order_id;

    if (!paymentId) {

      return {
        status: "ACCEPTED",
        message: "Webhook received without payment ID",
      };
    }

    const payment =
      await PaymentRepository.getPaymentByTransactionId(
        paymentId
      );

    if (!payment) {

      return {
        status: "ACCEPTED",
        message: "Payment not found yet; webhook logged",
      };
    }

    if (
      eventType === "payment.captured" ||
      eventType === "payment.authorized"
    ) {

      if (payment.status !== "SUCCESS") {

        await PaymentRepository.updatePaymentStatus(
          payment.id,
          "SUCCESS"
        );
      }

      return {
        status: "ACCEPTED",
        message: "Payment marked successful",
      };
    }

    if (
      eventType === "payment.failed"
    ) {

      await PaymentRepository.updatePaymentStatus(
        payment.id,
        "FAILED",
        paymentEntity?.error_description ||
          payload?.error ||
          "Payment failed"
      );

      return {
        status: "ACCEPTED",
        message: "Payment marked failed",
      };
    }

    return {
      status: "ACCEPTED",
      message: "Webhook received",
    };
  }

  // ============================================================
  // REFUND
  // ============================================================

  static async processRefund(
    data: {
      paymentId: string;
      orderId: string;
      amount: number;
      reason: string;
      isPartial?: boolean;
    },
    firebaseUid: string = ""
  ): Promise<any> {

    const payment =
      await PaymentRepository.getPaymentById(
        data.paymentId
      );

    if (!payment) {
      throw new Error(
        "Payment record not found for refund"
      );
    }

    if (payment.status !== "SUCCESS") {
      throw new Error(
        "Only successful payments can be refunded"
      );
    }

    if (data.amount <= 0) {
      throw new Error(
        "Invalid refund amount"
      );
    }

    if (data.amount > payment.amount) {
      throw new Error(
        "Refund amount cannot exceed payment amount"
      );
    }

    const refund =
      await PaymentRepository.createRefund(
        payment.id,
        data.orderId,
        firebaseUid,
        data.amount,
        data.reason,
        data.isPartial || false
      );

    const newBalance =
      await UserRepository.updateWalletBalance(
        firebaseUid,
        data.amount
      );

    await PaymentRepository.logWalletLedger(
      firebaseUid,
      "CREDIT",
      "REFUND",
      data.amount,
      newBalance,
      data.orderId,
      `Refund for Order #${data.orderId}: ${data.reason}`
    );

    await NotificationService.send({
      userId: firebaseUid,
      role: "CUSTOMER",
      templateCode: "WALLET_CREDITED",
      category: "WALLET",
      params: {
        amount: data.amount,
        reason:
          `Refund for Order #${data.orderId}`,
      },
      metadata: {
        orderId: data.orderId,
        amount: data.amount,
        newBalance,
      },
    });

    return refund;
  }

  // ============================================================
  // WALLET TOPUP
  // ============================================================

  static async topupWallet(
    amount: number,
    paymentMethod: string = "UPI (GPay)",
    firebaseUid: string = ""
  ): Promise<{
    balance: number;
    transaction: PaymentRecord;
  }> {

    if (!amount || amount <= 0) {
      throw new Error(
        "Invalid top-up amount"
      );
    }

    const user =
      await UserRepository.getProfile(
        firebaseUid
      );

    if (!user) {
      throw new Error("User not found");
    }

    const payment =
      await PaymentRepository.createPayment({
        orderId: "TOPUP-" + Date.now(),
        userId: user.id || firebaseUid,
        amount,
        paymentMethod,
        provider: "Razorpay",
      });

    await PaymentRepository.updatePaymentStatus(
      payment.id,
      "SUCCESS"
    );

    payment.status = "SUCCESS";

    const newBalance =
      await UserRepository.updateWalletBalance(
        firebaseUid,
        amount
      );

    await PaymentRepository.logWalletLedger(
      user.id || firebaseUid,
      "CREDIT",
      "TOPUP",
      amount,
      newBalance,
      payment.id,
      `Wallet Refill via ${paymentMethod}`
    );

    await ActivityRepository.log(
      user.id,
      "wallet_topup",
      `Refilled ₹${amount} into FlashWallet. New Balance: ₹${newBalance}`
    );

    return {
      balance: newBalance,
      transaction: payment,
    };
  }

  // ============================================================
  // WITHDRAW
  // ============================================================

  static async withdrawWallet(
    amount: number,
    bankAccount?: string,
    upiId?: string,
    firebaseUid: string = ""
  ): Promise<{
    balance: number;
    referenceId: string;
  }> {

    if (!amount || amount <= 0) {
      throw new Error(
        "Invalid withdrawal amount"
      );
    }

    const currentBalance =
      await UserRepository.getWalletBalance(
        firebaseUid
      );

    if (currentBalance < amount) {
      throw new Error(
        `Insufficient wallet balance. Current: ₹${currentBalance}`
      );
    }

    const user =
      await UserRepository.getProfile(
        firebaseUid
      );

    const newBalance =
      await UserRepository.updateWalletBalance(
        firebaseUid,
        -amount
      );

    const referenceId =
      "WITHDRAW-" +
      Math.floor(
        10000 + Math.random() * 90000
      );

    const description = upiId
      ? `Withdrawal to UPI ID: ${upiId}`
      : `Withdrawal to Bank: ${
          bankAccount || "Linked Account"
        }`;

    await PaymentRepository.logWalletLedger(
      user.id || firebaseUid,
      "DEBIT",
      "WITHDRAWAL",
      amount,
      newBalance,
      referenceId,
      description
    );

    return {
      balance: newBalance,
      referenceId,
    };
  }

  // ============================================================
  // REWARD POINTS
  // ============================================================

  static async rewardPointsAction(
    pointsToRedeem: number,
    action: "redeem" | "claim",
    firebaseUid: string = ""
  ): Promise<{
    pointsRemaining: number;
    walletCredit: number;
    newBalance: number;
  }> {

    if (pointsToRedeem <= 0) {
      throw new Error(
        "Invalid reward points amount"
      );
    }

    const summary =
      await PaymentRepository.getRewardPointsSummary(
        firebaseUid
      );

    if (summary.points < pointsToRedeem) {
      throw new Error(
        `Insufficient reward points. Available: ${summary.points}`
      );
    }

    const walletCredit =
      Math.floor(pointsToRedeem / 10);

    if (walletCredit <= 0) {
      throw new Error(
        "Minimum 10 points required"
      );
    }

    const user =
      await UserRepository.getProfile(
        firebaseUid
      );

    const pointsRemaining =
      await PaymentRepository.logRewardPoints(
        user.id || firebaseUid,
        pointsToRedeem,
        "REDEEMED",
        `Converted ${pointsToRedeem} points into ₹${walletCredit}`
      );

    const newBalance =
      await UserRepository.updateWalletBalance(
        firebaseUid,
        walletCredit
      );

    await PaymentRepository.logWalletLedger(
      user.id || firebaseUid,
      "CREDIT",
      "REWARD_REDEMPTION",
      walletCredit,
      newBalance,
      "REW-" + Date.now(),
      `Reward Points Conversion (${pointsToRedeem} pts)`
    );

    return {
      pointsRemaining,
      walletCredit,
      newBalance,
    };
  }

  // ============================================================
  // ADMIN WALLET
  // ============================================================

  static async adminWalletAdjust(
    userId: string,
    amount: number,
    type: "CREDIT" | "DEBIT",
    reason: string
  ): Promise<number> {

    if (!userId) {
      throw new Error(
        "User ID is required"
      );
    }

    if (!amount || amount <= 0) {
      throw new Error(
        "Invalid amount"
      );
    }

    const delta =
      type === "CREDIT"
        ? Math.abs(amount)
        : -Math.abs(amount);

    const newBalance =
      await UserRepository.updateWalletBalance(
        userId,
        delta
      );

    await PaymentRepository.logWalletLedger(
      userId,
      type,
      "ADMIN_ADJUSTMENT",
      Math.abs(amount),
      newBalance,
      "ADM-" + Date.now(),
      `Admin adjustment: ${reason}`
    );

    return newBalance;
  }
}