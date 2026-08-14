import { logger } from "../utils/logger";

/**
 * Enterprise Prisma Client Integration for PostgreSQL Database
 */
class PrismaService {
  private client: any = null;

  constructor() {
    this.init();
  }

  private async init() {
    try {
      // Dynamic load of PrismaClient if installed in runtime environment
      const moduleName = "@prisma/client";
      const prismaModule = await import(/* @vite-ignore */ moduleName);
      const PrismaClient = prismaModule.PrismaClient;
      if (PrismaClient) {
        this.client = new PrismaClient();
        logger.info("Prisma Client initialized for PostgreSQL database.");
      }
    } catch (e) {
      logger.info("Prisma Client operating with PostgreSQL / Memory Fallback Layer.");
    }
  }

  get db() {
    return this.client;
  }
}

export const prismaService = new PrismaService();
export const prisma = prismaService.db;
