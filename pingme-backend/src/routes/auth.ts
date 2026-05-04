import { FastifyInstance } from 'fastify';
import db from '../utils/db.js';
import { AuthService } from '../services/authService.js';
import { OtpService } from '../services/otpService.js';
import { authMiddleware } from '../middlewares/auth.js';

export default async function authRoutes(fastify: FastifyInstance) {
  // Register
  fastify.post('/register', async (request, reply) => {
    const { username, display_name, email, phone } = request.body as any;

    if (!username || username.length < 6) {
      return reply.status(400).send({ success: false, error: 'Username must be at least 6 characters' });
    }

    const reserved = ['admin', 'support', 'pingme', 'system', 'help', 'official'];
    if (reserved.includes(username.toLowerCase())) {
      return reply.status(400).send({ success: false, error: 'Username is reserved' });
    }

    try {
      const result = await AuthService.register({ username, display_name, email, phone });
      
      // Create session
      await AuthService.createSession(result.user.id, request.headers['user-agent'] || 'unknown', request.ip);
      
      return reply.send({ success: true, ...result });
    } catch (error: any) {
      return reply.status(400).send({ success: false, error: error.message });
    }
  });

  // Send OTP
  fastify.post('/otp/send', async (request, reply) => {
    const { identifier, method } = request.body as any; // method: 'email' | 'whatsapp'

    const lockError = await OtpService.checkRateLimit(identifier);
    if (lockError) {
      return reply.status(429).send({ success: false, error: lockError });
    }

    const otp = OtpService.generateOtp();
    await OtpService.storeOtp(identifier, otp);

    // MOCK SENDING
    console.log(`[MOCK OTP] Sending ${otp} to ${identifier} via ${method}`);
    
    // In a real app, use nodemailer or WhatsApp API here

    return reply.send({ success: true, expiresIn: 300 });
  });

  // Verify OTP & Login
  fastify.post('/otp/verify', async (request, reply) => {
    const { identifier, otp } = request.body as any;

    const isValid = await OtpService.verifyOtp(identifier, otp);

    if (!isValid) {
      await OtpService.recordFailedAttempt(identifier);
      return reply.status(401).send({ success: false, error: 'Invalid or expired OTP' });
    }

    await OtpService.resetAttempts(identifier);

    // Find user
    let user = await AuthService.getUserByUsernameOrIdentifier(identifier);

    if (!user) {
      return reply.send({ success: true, newUser: true, identifier });
    }

    // Cancel deletion if scheduled
    await db.execute({
      sql: 'UPDATE users SET deletion_scheduled_at = NULL WHERE id = ?',
      args: [user.id],
    });

    const tokens = await AuthService.generateTokens(user);
    await AuthService.createSession(user.id, request.headers['user-agent'] || 'unknown', request.ip);

    return reply.send({ success: true, user, ...tokens });
  });

  // Logout (Current session)
  fastify.post('/logout', { preHandler: [authMiddleware] }, async (request, reply) => {
    await AuthService.logout(request.user.id);
    return reply.send({ success: true });
  });

  // Get active sessions
  fastify.get('/sessions', { preHandler: [authMiddleware] }, async (request, reply) => {
    const sessions = await AuthService.getActiveSessions(request.user.id);
    return reply.send({ success: true, sessions });
  });

  // Revoke session
  fastify.delete('/sessions/:id', { preHandler: [authMiddleware] }, async (request, reply) => {
    const { id } = request.params as any;
    await AuthService.revokeSession(request.user.id, id);
    return reply.send({ success: true });
  });

  // Update FCM Token
  fastify.post('/fcm-token', { preHandler: [authMiddleware] }, async (request, reply) => {
    const { fcm_token } = request.body as any;
    if (!fcm_token) {
      return reply.status(400).send({ success: false, error: 'fcm_token required' });
    }

    await AuthService.updateFcmToken(request.user.id, request.ip, fcm_token);
    return reply.send({ success: true });
  });
}
