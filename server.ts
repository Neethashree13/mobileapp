// import express from "express";
// import { createServer } from "http";
// import { Server as SocketIOServer } from "socket.io";
// import path from "path";
// import { createServer as createViteServer } from "vite";
// import * as dotenv from "dotenv";
// import cors from "cors";
// import helmet from "helmet";
// import rateLimit from "express-rate-limit";

// // Load configuration
// dotenv.config();

// // Import database utilities
// import { testConnectionAndBootstrap } from "./server/config/database";

// // Import custom utilities & middleware
// import { logger } from "./server/utils/logger";
// import { errorHandler } from "./server/middleware/errorHandler";
// import { SocketService } from "./server/services/socket.service";
// import { setupSocketHandlers } from "./server/sockets/socket.controller";

// // Import modular API routers
// import aiRouter from "./server/routes/ai.routes";
// import productRouter from "./server/routes/product.routes";
// import authRouter from "./server/routes/auth.routes";
// import userRouter from "./server/routes/user.routes";
// import cartRouter from "./server/routes/cart.routes";
// import wishlistRouter from "./server/routes/wishlist.routes";
// import paymentRouter from "./server/routes/payment.routes";
// import couponRouter from "./server/routes/coupon.routes";
// import orderRouter from "./server/routes/order.routes";
// import deliveryRouter from "./server/routes/delivery.routes";
// import reviewRouter from "./server/routes/review.routes";
// import adminRouter from "./server/routes/admin.routes";
// import checkoutRouter from "./server/routes/checkout.routes";
// import notificationRouter from "./server/routes/notification.routes";

// async function startServer() {
//   const app = express();
//   app.set("trust proxy", 1);
//   const server = createServer(app);
//   const io = new SocketIOServer(server, {
//     cors: {
//       origin: "*",
//       methods: ["GET", "POST"],
//     },
//   });

//   const PORT = 3000;

//   // Initialize SocketService & trigger handlers
//   SocketService.initialize(io);
//   setupSocketHandlers(io);

//   // 1. Security & Network Middlewares
//   app.use(cors({ origin: "*", credentials: true }));
//   app.use(
//     helmet({
//       contentSecurityPolicy: false, // Disabled to ensure AI Studio Iframe preview renders flawlessly
//       crossOriginEmbedderPolicy: false,
//     })
//   );

//   // Rate Limiting to prevent brute-force attacks
//   const limiter = rateLimit({
//     windowMs: 15 * 60 * 1000, // 15 minutes
//     max: 200, // Limit each IP to 200 requests per window
//     standardHeaders: true,
//     legacyHeaders: false,
//     message: "Too many requests from this IP, please try again later.",
//   });
//   app.use("/api/", limiter);

//   app.use(express.json({ limit: "10mb" }));

//   // HTTP Request Logging Middleware using Winston
//   app.use((req, _res, next) => {
//     logger.http(`${req.method} ${req.url} - IP: ${req.ip}`);
//     next();
//   });

//   // Initialize and bootstrap PostgreSQL Pool resiliently
//   await testConnectionAndBootstrap();

//   // Register modular application routes
//   app.use("/ai", aiRouter);
//   app.use("/api/ai", aiRouter);
//   app.use("/api/gemini", aiRouter);
//   app.use("/api/users", authRouter);
//   app.use("/api/auth", authRouter);
//   app.use("/auth", authRouter);
//   app.use("/api/v1", productRouter);
//   app.use("/api", userRouter);
//   app.use("/api/cart", cartRouter);
//   app.use("/cart", cartRouter);
//   app.use("/api/wishlist", wishlistRouter);
//   app.use("/wishlist", wishlistRouter);
//   app.use("/api", paymentRouter);
//   app.use("/payments", paymentRouter);
//   app.use("/wallet", paymentRouter);
//   app.use("/api/coupons", couponRouter);
//   app.use("/coupons", couponRouter);
//   app.use("/api/checkout", checkoutRouter);
//   app.use("/checkout", checkoutRouter);
//   app.use("/api/orders", orderRouter);
//   app.use("/orders", orderRouter);
//   app.use("/api/deliveries", deliveryRouter);
//   app.use("/api/delivery", deliveryRouter);
//   app.use("/delivery", deliveryRouter);
//   app.use("/api/notifications", notificationRouter);
//   app.use("/notifications", notificationRouter);
//   app.use("/api/reviews", reviewRouter);
//   app.use("/api", adminRouter);


//   // Global Error Handler registration (Must be after router bindings)
//   app.use(errorHandler);

//   // Vite Integration / Single Page Application serving
//   if (process.env.NODE_ENV !== "production") {
//     const vite = await createViteServer({
//       server: { middlewareMode: true },
//       appType: "spa",
//     });
//     app.use(vite.middlewares);
//   } else {
//     const distPath = path.join(process.cwd(), "dist");
//     app.use(express.static(distPath));
//     app.get("*", (req, res) => {
//       res.sendFile(path.join(distPath, "index.html"));
//     });
//   }

//   server.listen(PORT, "0.0.0.0", () => {
//     logger.info(`🚀 Enterprise Production server running on http://0.0.0.0:${PORT}`);
//   });
// }

// startServer();


import express from "express";
import { createServer } from "http";
import { Server as SocketIOServer } from "socket.io";
import path from "path";
import { createServer as createViteServer } from "vite";
import * as dotenv from "dotenv";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";

// Load configuration
dotenv.config();

// Import database utilities
import { testConnectionAndBootstrap } from "./server/config/database";

// Import custom utilities & middleware
import { logger } from "./server/utils/logger";
import { errorHandler } from "./server/middleware/errorHandler";
import { SocketService } from "./server/services/socket.service";
import { setupSocketHandlers } from "./server/sockets/socket.controller";

// Import modular API routers
import aiRouter from "./server/routes/ai.routes";
import productRouter from "./server/routes/product.routes";
import authRouter from "./server/routes/auth.routes";
import userRouter from "./server/routes/user.routes";
import cartRouter from "./server/routes/cart.routes";
import wishlistRouter from "./server/routes/wishlist.routes";
import paymentRouter from "./server/routes/payment.routes";
import couponRouter from "./server/routes/coupon.routes";
import orderRouter from "./server/routes/order.routes";
import deliveryRouter from "./server/routes/delivery.routes";
import reviewRouter from "./server/routes/review.routes";
import adminRouter from "./server/routes/admin.routes";
import checkoutRouter from "./server/routes/checkout.routes";
import notificationRouter from "./server/routes/notification.routes";

async function startServer() {
  const app = express();
  app.set("trust proxy", 1);
  const server = createServer(app);
  const io = new SocketIOServer(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
    },
  });

  const PORT = 3000;

  // Initialize SocketService & trigger handlers
  SocketService.initialize(io);
  setupSocketHandlers(io);

  // 1. Security & Network Middlewares
  app.use(cors({ origin: "*", credentials: true }));
  app.use(
    helmet({
      contentSecurityPolicy: false, // Disabled to ensure AI Studio Iframe preview renders flawlessly
      crossOriginEmbedderPolicy: false,
    })
  );

  // Rate Limiting to prevent brute-force attacks
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 200, // Limit each IP to 200 requests per window
    standardHeaders: true,
    legacyHeaders: false,
    message: "Too many requests from this IP, please try again later.",
  });
  app.use("/api/", limiter);

  app.use(express.json({ limit: "10mb" }));

  // HTTP Request Logging Middleware using Winston
  app.use((req, _res, next) => {
    logger.http(`${req.method} ${req.url} - IP: ${req.ip}`);
    next();
  });

  // Initialize and bootstrap PostgreSQL Pool resiliently
  await testConnectionAndBootstrap();

  // Register modular application routes
  app.use("/ai", aiRouter);
  app.use("/api/ai", aiRouter);
  app.use("/api/gemini", aiRouter);
  app.use("/api/users", authRouter);
  app.use("/api/auth", authRouter);
  app.use("/auth", authRouter);
  app.use("/api/v1", productRouter);
  app.use("/api", userRouter);
  app.use("/api/cart", cartRouter);
  app.use("/cart", cartRouter);
  app.use("/api/wishlist", wishlistRouter);
  app.use("/wishlist", wishlistRouter);
  app.use("/api/payments", paymentRouter);
  app.use("/api/payment", paymentRouter);
  app.use("/payments", paymentRouter);
  app.use("/wallet", paymentRouter);
  app.use("/api/coupons", couponRouter);
  app.use("/coupons", couponRouter);
  app.use("/api/checkout", checkoutRouter);
  app.use("/checkout", checkoutRouter);
  app.use("/api/orders", orderRouter);
  app.use("/api/v1/orders", orderRouter);
  app.use("/orders", orderRouter);
  app.use("/api/deliveries", deliveryRouter);
  app.use("/api/delivery", deliveryRouter);
  app.use("/delivery", deliveryRouter);
  app.use("/api/notifications", notificationRouter);
  app.use("/notifications", notificationRouter);
  app.use("/api/reviews", reviewRouter);
  app.use("/api", adminRouter);


  // Global Error Handler registration (Must be after router bindings)
  app.use(errorHandler);

  // Vite Integration / Single Page Application serving
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  server.listen(PORT, "0.0.0.0", () => {
    logger.info(`🚀 Enterprise Production server running on http://0.0.0.0:${PORT}`);
  });
}

startServer();
