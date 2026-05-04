import { WebSocket } from 'ws';

export class WebSocketManager {
  // Map of userId -> Set of WebSocket connections (supporting multi-device)
  private static connections = new Map<string, Set<WebSocket>>();

  static addConnection(userId: string, ws: WebSocket) {
    if (!this.connections.has(userId)) {
      this.connections.set(userId, new Set());
    }
    this.connections.get(userId)!.add(ws);
    console.log(`[WS] Connection added for user ${userId}. Total devices: ${this.connections.get(userId)!.size}`);
  }

  static removeConnection(userId: string, ws: WebSocket) {
    const userConns = this.connections.get(userId);
    if (userConns) {
      userConns.delete(ws);
      if (userConns.size === 0) {
        this.connections.delete(userId);
      }
      console.log(`[WS] Connection removed for user ${userId}.`);
    }
  }

  static isUserOnline(userId: string): boolean {
    return this.connections.has(userId) && this.connections.get(userId)!.size > 0;
  }

  static sendToUser(userId: string, event: string, data: any) {
    const userConns = this.connections.get(userId);
    if (userConns) {
      const payload = JSON.stringify({ event, data });
      userConns.forEach((ws) => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(payload);
        }
      });
    }
  }

  static async broadcastToConversation(conversationId: string, event: string, data: any, excludeUserId?: string) {
    // In a real app, you'd fetch members from DB.
    // For now, this logic will be called from services that know the members.
  }
}
