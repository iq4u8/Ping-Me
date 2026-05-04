import { FastifyRequest, FastifyReply } from 'fastify';
import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';

interface JwtPayload {
  id: string;
  username: string;
}

declare module 'fastify' {
  interface FastifyRequest {
    user: JwtPayload;
  }
}

export const authMiddleware = async (request: FastifyRequest, reply: FastifyReply) => {
  try {
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return reply.status(401).send({
        success: false,
        error: {
          message: 'Unauthorized: Token missing',
          code: 'UNAUTHORIZED',
        },
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, env.JWT_SECRET) as JwtPayload;

    request.user = {
      id: decoded.id,
      username: decoded.username,
    };
  } catch (error) {
    return reply.status(401).send({
      success: false,
      error: {
        message: 'Unauthorized: Invalid or expired token',
        code: 'UNAUTHORIZED',
      },
    });
  }
};
