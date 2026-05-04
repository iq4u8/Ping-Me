import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { WebSocketManager } from './manager.js';

export const handleConnection = (connection: any, request: any) => {
  const { socket } = connection;
  const url = new URL(request.url, `http://${request.headers.host}`);
  const token = url.searchParams.get('token');

  if (!token) {
    console.log('[WS] Connection rejected: No token provided');
    socket.close(1008, 'Token missing');
    return;
  }

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as { id: string; username: string };
    const userId = decoded.id;

    WebSocketManager.addConnection(userId, socket);

    socket.on('message', (message: any) => {
      try {
        const payload = JSON.parse(message.toString());
        console.log(`[WS] Received from ${userId}:`, payload);
        // Handle incoming events like 'typing:start' here if needed
      } catch (err) {
        console.error('[WS] Error parsing message:', err);
      }
    });

    socket.on('close', () => {
      WebSocketManager.removeConnection(userId, socket);
    });

    socket.on('error', (error: any) => {
      console.error(`[WS] Error for user ${userId}:`, error);
      WebSocketManager.removeConnection(userId, socket);
    });

  } catch (error) {
    console.log('[WS] Connection rejected: Invalid token');
    socket.close(1008, 'Invalid token');
  }
};
