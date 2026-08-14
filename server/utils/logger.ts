import * as winston from "winston";
import { isProduction } from "../config/env";

const winstonModule: any = winston || {};
const winstonObj = winstonModule.default || winstonModule;

const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

const colors = {
  error: "red",
  warn: "yellow",
  info: "green",
  http: "magenta",
  debug: "white",
};

if (winstonObj.addColors) {
  winstonObj.addColors(colors);
}

// Resilient helper to retrieve winston format object safely
const formatObj = winstonObj.format || {};

const customFormat = typeof formatObj.combine === "function"
  ? formatObj.combine(
      formatObj.timestamp({ format: "YYYY-MM-DD HH:mm:ss:ms" }),
      formatObj.colorize({ all: true }),
      formatObj.printf(
        (info: any) => `[${info.timestamp}] [${info.level}]: ${info.message}`
      )
    )
  : undefined;

const transportsList = typeof winstonObj.transports?.Console === "function"
  ? [
      new winstonObj.transports.Console({
        format: isProduction
          ? formatObj.combine?.(formatObj.timestamp?.(), formatObj.json?.())
          : customFormat,
      }),
    ]
  : [];

// Standard fallback logger if winston creation fails (e.g. during specific Jest mock runs)
export const logger = typeof winstonObj.createLogger === "function"
  ? winstonObj.createLogger({
      level: isProduction ? "info" : "debug",
      levels,
      transports: transportsList,
    })
  : {
      error: (msg: string, ...args: any[]) => console.error(msg, ...args),
      warn: (msg: string, ...args: any[]) => console.warn(msg, ...args),
      info: (msg: string, ...args: any[]) => console.log(msg, ...args),
      http: (msg: string, ...args: any[]) => console.log(msg, ...args),
      debug: (msg: string, ...args: any[]) => console.log(msg, ...args),
    };
