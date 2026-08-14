// import * as dotenv from "dotenv";
// import { z } from "zod";

// dotenv.config();

// const envSchema = z.object({
//   NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
//   PORT: z.string().default("3000").transform((val) => parseInt(val, 10)),
//   GEMINI_API_KEY: z.string().optional(),
//   // Database environment config with fallback support
//   PGHOST: z.string().optional(),
//   SQL_HOST: z.string().optional(),
//   PGUSER: z.string().optional(),
//   SQL_USER: z.string().optional(),
//   PGPASSWORD: z.string().optional(),
//   SQL_PASSWORD: z.string().optional(),
//   PGDATABASE: z.string().optional(),
//   SQL_DB_NAME: z.string().optional(),
//   PGPORT: z.string().default("5432").transform((val) => parseInt(val, 10)),
//   SQL_PORT: z.string().default("5432").transform((val) => parseInt(val, 10)),
// });

// // Run validation
// const parsedEnv = envSchema.safeParse(process.env);

// if (!parsedEnv.success) {
//   console.error("❌ Invalid environment variables:", parsedEnv.error.format());
//   process.exit(1);
// }

// export const env = parsedEnv.data;
// export const isProduction = env.NODE_ENV === "production";
// export const PORT = env.PORT;
// export const GEMINI_API_KEY = env.GEMINI_API_KEY;
// export const isTest = env.NODE_ENV === "test";


import * as dotenv from "dotenv";
import { z } from "zod";

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  PORT: z.string().default("3000").transform((val) => parseInt(val, 10)),
  GEMINI_API_KEY: z.string().optional(),
  // Database environment config with fallback support
  PGHOST: z.string().optional(),
  SQL_HOST: z.string().optional(),
  PGUSER: z.string().optional(),
  SQL_USER: z.string().optional(),
  PGPASSWORD: z.string().optional(),
  SQL_PASSWORD: z.string().optional(),
  PGDATABASE: z.string().optional(),
  SQL_DB_NAME: z.string().optional(),
  PGPORT: z.string().default("5432").transform((val) => parseInt(val, 10)),
  SQL_PORT: z.string().default("5432").transform((val) => parseInt(val, 10)),
  JWT_SECRET: z.string().default("super_secret_jwt_key_for_flashcart_ai"),
  JWT_REFRESH_SECRET: z.string().default("super_secret_jwt_refresh_key_for_flashcart_ai"),
});

// Run validation
const parsedEnv = envSchema.safeParse(process.env);

if (!parsedEnv.success) {
  console.error("❌ Invalid environment variables:", parsedEnv.error.format());
  process.exit(1);
}

export const env = parsedEnv.data;
export const isProduction = env.NODE_ENV === "production";
export const PORT = env.PORT;
export const GEMINI_API_KEY = env.GEMINI_API_KEY;
export const isTest = env.NODE_ENV === "test";
export const JWT_SECRET = env.JWT_SECRET;
export const JWT_REFRESH_SECRET = env.JWT_REFRESH_SECRET;
