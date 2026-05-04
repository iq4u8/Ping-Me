import { FastifyInstance, FastifyError, FastifyRequest, FastifyReply } from 'fastify';

export const errorHandler = (
  error: FastifyError,
  request: FastifyRequest,
  reply: FastifyReply
) => {
  const statusCode = error.statusCode || 500;
  const isClientError = statusCode >= 400 && statusCode < 500;

  request.log.error(error);

  reply.status(statusCode).send({
    success: false,
    error: {
      message: isClientError ? error.message : 'Internal Server Error',
      code: error.code || 'INTERNAL_SERVER_ERROR',
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack }),
    },
  });
};
