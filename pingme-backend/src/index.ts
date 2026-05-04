import Fastify from 'fastify';
import cors from '@fastify/cors';
import websocket from '@fastify/websocket';
import multipart from '@fastify/multipart';
import { env } from './config/env.js';
import { errorHandler } from './middlewares/errorHandler.js';
import authRoutes from './routes/auth.js';
import messageRoutes from './routes/messages.js';
import mediaRoutes from './routes/media.js';
import userRoutes from './routes/users.js';
import conversationRoutes from './routes/conversations.js';
import { handleConnection } from './websocket/handlers.js';

const fastify = Fastify({
  logger: true,
});

// Set global error handler
fastify.setErrorHandler(errorHandler);

// Register plugins
fastify.register(cors);
fastify.register(websocket);
fastify.register(multipart);

// Register WebSocket route
fastify.register(async (fastify) => {
  fastify.get('/ws', { websocket: true }, handleConnection);
});

// Register routes
fastify.register(authRoutes, { prefix: '/api/v1/auth' });
fastify.register(messageRoutes, { prefix: '/api/v1/messages' });
fastify.register(mediaRoutes, { prefix: '/api/v1/media' });
fastify.register(userRoutes, { prefix: '/api/v1/users' });
fastify.register(conversationRoutes, { prefix: '/api/v1/conversations' });

// Health check route
fastify.get('/health', async (request, reply) => {
  return { status: 'ok' };
});

// Start server
const start = async () => {
  try {
    await fastify.listen({ 
      port: parseInt(env.PORT), 
      host: '0.0.0.0' 
    });
    console.log(`Server listening on port ${env.PORT}`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
