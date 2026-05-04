import Fastify from 'fastify';
import cors from '@fastify/cors';
import websocket from '@fastify/websocket';
import { env } from './config/env.js';

const fastify = Fastify({
  logger: true,
});

// Register plugins
fastify.register(cors);
fastify.register(websocket);

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
