import { Router } from "express";
import * as paymentController from "../controllers/payment.controller";
import { checkDbConnection } from "../middleware/dbCheck";

const router = Router();

// Payment State Engine Endpoints
router.post("/create", checkDbConnection, paymentController.createPayment);
router.post("/verify", checkDbConnection, paymentController.verifyPayment);
router.post("/webhook", paymentController.handleWebhook);
router.post("/refund", checkDbConnection, paymentController.processRefund);

router.get("/history", checkDbConnection, paymentController.getPayments);
router.get("/:id", checkDbConnection, paymentController.getPaymentById);
router.get("/", checkDbConnection, paymentController.getPayments);

// Double-Entry Wallet Ledger Endpoints
router.get("/wallet/info", checkDbConnection, paymentController.getWallet);
router.get("/wallet/balance", checkDbConnection, paymentController.getWallet);
router.get("/wallet/transactions", checkDbConnection, paymentController.getWalletTransactions);
router.get("/wallet", checkDbConnection, paymentController.getWallet);

router.post("/wallet/topup", checkDbConnection, paymentController.topupWallet);
router.post("/wallet/refill", checkDbConnection, paymentController.topupWallet);
router.post("/wallet/withdraw", checkDbConnection, paymentController.withdrawWallet);
router.post("/wallet/reward", checkDbConnection, paymentController.rewardPointsAction);

// Admin Payment & Risk Control Endpoints
router.get("/admin/dashboard", checkDbConnection, paymentController.getAdminDashboard);
router.get("/admin/refunds", checkDbConnection, paymentController.getAdminRefunds);
router.get("/admin/logs", checkDbConnection, paymentController.getAdminGatewayLogs);
router.post("/admin/wallet-adjust", checkDbConnection, paymentController.adminAdjustWallet);

export default router;
