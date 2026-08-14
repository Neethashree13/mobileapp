import { Server as SocketIOServer } from "socket.io";
import { logger } from "../utils/logger";

export class SocketService {
  private static io: SocketIOServer | null = null;

  static initialize(ioInstance: SocketIOServer): void {
    this.io = ioInstance;
    logger.info("SocketService initialized with Socket.IO Server instance");
  }

  static emitToAll(event: string, data: any): void {
    if (this.io) {
      logger.info(`[SocketService] Emitting event: "${event}" to all connected clients.`);
      this.io.emit(event, data);
    } else {
      logger.warn(`[SocketService] Tried to emit "${event}" but Socket.IO is not initialized yet.`);
    }
  }

  static emitToRoom(room: string, event: string, data: any): void {
    if (this.io) {
      logger.info(`[SocketService] Emitting event: "${event}" to room: "${room}".`);
      this.io.to(room).emit(event, data);
    } else {
      logger.warn(`[SocketService] Tried to emit "${event}" to room "${room}" but Socket.IO is not initialized yet.`);
    }
  }
}
