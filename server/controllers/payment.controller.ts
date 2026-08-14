import { Response, NextFunction } from "express";
import { PaymentService } from "../services/payment.service";
import { PaymentRepository } from "../repositories/payment.repository";
import { isProduction } from "../config/env";
import { usePostgreSQL } from "../config/database";
import { AuthenticatedRequest } from "../middleware/dbCheck";

function getFirebaseUid(req: AuthenticatedRequest): string {
  return (
    req.user?.uid ||
    (req.headers["x-user-id"] as string) ||
    (req.query.userId as string) ||
    ""
  );
}

/**
 * ============================================================
 * CREATE PAYMENT
 * ============================================================
 */
export async function createPayment(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const firebaseUid = getFirebaseUid(req);

    if (!firebaseUid) {
      res.status(401).json({
        error: "User authentication required",
      });
      return;
    }

    const {
      orderId,
      amount,
      paymentMethod,
      provider,
      idempotencyKey,
      isGiftCard,
      giftCardCode,
    } = req.body;

    if (!orderId) {
      res.status(400).json({
        error: "orderId is required",
      });
      return;
    }

    if (amount === undefined || amount === null) {
      res.status(400).json({
        error: "amount is required",
      });
      return;
    }

    if (Number(amount) <= 0) {
      res.status(400).json({
        error: "amount must be greater than zero",
      });
      return;
    }

    if (!paymentMethod) {
      res.status(400).json({
        error: "paymentMethod is required",
      });
      return;
    }

    const result = await PaymentService.createPayment(
      {
        orderId,
        amount: Number(amount),
        paymentMethod,
        provider,
        idempotencyKey,
        isGiftCard,
        giftCardCode,
      },
      firebaseUid
    );

    res.status(201).json(result);
  } catch (error: any) {
    console.error("CREATE PAYMENT ERROR:", error);

    res.status(400).json({
      error: error.message || "Could not create payment",
    });
  }
}

/**
 * ============================================================
 * VERIFY PAYMENT
 * ============================================================
 */
export async function verifyPayment(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const firebaseUid = getFirebaseUid(req);

    if (!firebaseUid) {
      res.status(401).json({
        error: "User authentication required",
      });
      return;
    }

    const {
      paymentId,
      transactionId,
      razorpayOrderId,
      gatewaySignature,
      simulateFailure,
    } = req.body;

    if (!paymentId) {
      res.status(400).json({
        error: "paymentId is required",
      });
      return;
    }

    if (!transactionId) {
      res.status(400).json({
        error: "transactionId is required",
      });
      return;
    }

    if (!razorpayOrderId) {
      res.status(400).json({
        error: "razorpayOrderId is required",
      });
      return;
    }

    if (!gatewaySignature) {
      res.status(400).json({
        error: "gatewaySignature is required",
      });
      return;
    }

    const result = await PaymentService.verifyPayment(
      {
        paymentId,
        transactionId,
        razorpayOrderId,
        gatewaySignature,
        simulateFailure,
      },
      firebaseUid
    );

    res.json(result);
  } catch (error: any) {
    console.error("VERIFY PAYMENT ERROR:", error);

    res.status(400).json({
      error: error.message || "Payment verification failed",
    });
  }
}

/**
 * ============================================================
 * WEBHOOK
 * ============================================================
 */
export async function handleWebhook(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const provider =
      (req.headers["x-gateway-provider"] as string) ||
      "Razorpay";

    const signature =
      (req.headers["x-razorpay-signature"] as string) ||
      (req.headers["x-signature"] as string) ||
      "";

    const eventType =
      req.body.event ||
      req.body.eventType ||
      "";

    if (!signature) {
      res.status(400).json({
        error: "Webhook signature missing",
      });
      return;
    }

    if (!eventType) {
      res.status(400).json({
        error: "Webhook event type missing",
      });
      return;
    }

    const result = await PaymentService.handleWebhook(
      provider,
      eventType,
      req.body,
      signature
    );

    res.json(result);
  } catch (error: any) {
    console.error("WEBHOOK ERROR:", error);

    res.status(400).json({
      error: error.message || "Webhook processing error",
    });
  }
}

/**
 * ============================================================
 * REFUND
 * ============================================================
 */
export async function processRefund(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const firebaseUid = getFirebaseUid(req);

    const {
      paymentId,
      orderId,
      amount,
      reason,
      isPartial,
    } = req.body;

    if (!paymentId || !orderId || amount === undefined) {
      res.status(400).json({
        error: "paymentId, orderId, and amount are required",
      });
      return;
    }

    if (Number(amount) <= 0) {
      res.status(400).json({
        error: "Refund amount must be greater than zero",
      });
      return;
    }

    const refund = await PaymentService.processRefund(
      {
        paymentId,
        orderId,
        amount: Number(amount),
        reason: reason || "Customer request",
        isPartial: Boolean(isPartial),
      },
      firebaseUid
    );

    res.json(refund);
  } catch (error: any) {
    console.error("REFUND ERROR:", error);

    res.status(400).json({
      error: error.message || "Could not process refund",
    });
  }
}

/**
 * ============================================================
 * GET PAYMENT
 * ============================================================
 */
export async function getPaymentById(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const { id } = req.params;

    const payment =
      await PaymentRepository.getPaymentById(id);

    if (!payment) {
      res.status(404).json({
        error: "Payment not found",
      });
      return;
    }

    res.json(payment);
  } catch (error: any) {
    next(error);
  }
}

/**
 * ============================================================
 * GET PAYMENTS
 * ============================================================
 */
export async function getPayments(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const firebaseUid = getFirebaseUid(req);

    const info =
      await PaymentService.getPaymentInfo(firebaseUid);

    res.json(info.payments);
  } catch (error: any) {
    next(error);
  }
}

/**
 * ============================================================
 * GET WALLET
 * ============================================================
 */
export async function getWallet(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const firebaseUid = getFirebaseUid(req);

    const info =
      await PaymentService.getPaymentInfo(firebaseUid);

    res.json({
      balance: info.walletBalance,
      rewardPoints: info.rewardPoints,
    });
  } catch (error: any) {
    next(error);
  }
}

/**
 * ============================================================
 * WALLET TRANSACTIONS
 * ============================================================
 */
export async function getWalletTransactions(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const firebaseUid = getFirebaseUid(req);

    const info =
      await PaymentService.getPaymentInfo(firebaseUid);

    res.json(info.ledger);
  } catch (error: any) {
    next(error);
  }
}

/**
 * ============================================================
 * WALLET TOPUP
 * ============================================================
 */
export async function topupWallet(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const {
      amount,
      paymentMethod,
    } = req.body;

    const firebaseUid = getFirebaseUid(req);

    const refillAmount = Number(amount);

    if (!refillAmount || refillAmount <= 0) {
      res.status(400).json({
        error: "Invalid top-up amount",
      });
      return;
    }

    const result =
      await PaymentService.topupWallet(
        refillAmount,
        paymentMethod || "UPI (GPay)",
        firebaseUid
      );

    res.json({
      status: "success",
      balance: result.balance,
      transaction: result.transaction,
    });
  } catch (error: any) {
    res.status(400).json({
      error: error.message || "Topup failed",
    });
  }
}

/**
 * ============================================================
 * WITHDRAW WALLET
 * ============================================================
 */
export async function withdrawWallet(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const {
      amount,
      bankAccount,
      upiId,
    } = req.body;

    const firebaseUid = getFirebaseUid(req);

    const result =
      await PaymentService.withdrawWallet(
        Number(amount),
        bankAccount,
        upiId,
        firebaseUid
      );

    res.json({
      status: "success",
      balance: result.balance,
      referenceId: result.referenceId,
    });
  } catch (error: any) {
    res.status(400).json({
      error: error.message || "Withdrawal failed",
    });
  }
}

/**
 * ============================================================
 * REWARD POINTS
 * ============================================================
 */
export async function rewardPointsAction(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    if (isProduction && !usePostgreSQL) {
      res.status(503).json({
        error: "PostgreSQL is not active or connected in production",
      });
      return;
    }

    const {
      points,
      action,
    } = req.body;

    const firebaseUid = getFirebaseUid(req);

    const result =
      await PaymentService.rewardPointsAction(
        Number(points || 100),
        action || "redeem",
        firebaseUid
      );

    res.json({
      status: "success",
      ...result,
    });
  } catch (error: any) {
    res.status(400).json({
      error: error.message || "Reward redemption failed",
    });
  }
}

/**
 * ============================================================
 * ADMIN
 * ============================================================
 */

export async function getAdminDashboard(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const stats =
      await PaymentRepository.getAdminDashboardStats();

    res.json(stats);
  } catch (error: any) {
    next(error);
  }
}

export async function getAdminRefunds(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const refunds =
      await PaymentRepository.getRefunds();

    res.json(refunds);
  } catch (error: any) {
    next(error);
  }
}

export async function getAdminGatewayLogs(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const logs =
      await PaymentRepository.getGatewayLogs();

    res.json(logs);
  } catch (error: any) {
    next(error);
  }
}

export async function adminAdjustWallet(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const {
      userId,
      amount,
      type,
      reason,
    } = req.body;

    if (!userId || !amount || !type) {
      res.status(400).json({
        error: "userId, amount, and type are required",
      });
      return;
    }

    if (type !== "CREDIT" && type !== "DEBIT") {
      res.status(400).json({
        error: "type must be CREDIT or DEBIT",
      });
      return;
    }

    const newBalance =
      await PaymentService.adminWalletAdjust(
        userId,
        Number(amount),
        type,
        reason || "Admin Manual Credit"
      );

    res.json({
      status: "success",
      userId,
      newBalance,
    });
  } catch (error: any) {
    res.status(400).json({
      error: error.message || "Wallet adjustment failed",
    });
  }
}