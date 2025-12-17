// src/middleware/auth.ts
import { FastifyRequest, FastifyReply } from 'fastify';
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';
import { getOrCreateUserByAuth0Sub } from '../services/users.js';

// Extend FastifyRequest to include user
declare module 'fastify' {
  interface FastifyRequest {
    user?: {
      id: string;
      auth0Sub: string;
      displayName: string;
    };
  }
}

// Initialize JWKS client lazily to avoid issues if AUTH0_DOMAIN is not set
function getJwksClient() {
  if (!process.env.AUTH0_DOMAIN) {
    throw new Error('AUTH0_DOMAIN environment variable is not set');
  }
  return jwksClient({
    jwksUri: `https://${process.env.AUTH0_DOMAIN}/.well-known/jwks.json`,
    cache: true,
    cacheMaxAge: 600000, // 10 minutes
  });
}

function getKey(header: jwt.JwtHeader, callback: jwt.SigningKeyCallback) {
  const client = getJwksClient();
  client.getSigningKey(header.kid, (err, key) => {
    if (err) {
      return callback(err);
    }
    const signingKey = key?.getPublicKey();
    callback(null, signingKey);
  });
}

export async function authenticateUser(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  try {
    // Check environment variables
    if (!process.env.AUTH0_DOMAIN) {
      request.log.error('AUTH0_DOMAIN environment variable is not set');
      return reply.code(500).send({ error: 'Server Configuration Error', message: 'AUTH0_DOMAIN not configured' });
    }
    if (!process.env.AUTH0_AUDIENCE) {
      request.log.error('AUTH0_AUDIENCE environment variable is not set');
      return reply.code(500).send({ error: 'Server Configuration Error', message: 'AUTH0_AUDIENCE not configured' });
    }

    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      request.log.warn('Missing or invalid authorization header');
      return reply.code(401).send({ error: 'Unauthorized', message: 'Missing or invalid authorization header' });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    if (!token || token.trim().length === 0) {
      request.log.warn('Empty token provided');
      return reply.code(401).send({ error: 'Unauthorized', message: 'Empty token' });
    }

    // Verify and decode the JWT token
    const decoded = await new Promise<jwt.JwtPayload>((resolve, reject) => {
      jwt.verify(
        token,
        getKey,
        {
          audience: process.env.AUTH0_AUDIENCE,
          issuer: `https://${process.env.AUTH0_DOMAIN}/`,
          algorithms: ['RS256'],
        },
        (err, decoded) => {
          if (err) {
            request.log.error({ err, tokenPreview: token.substring(0, 20) + '...' }, 'JWT verification failed');
            reject(err);
          } else {
            resolve(decoded as jwt.JwtPayload);
          }
        }
      );
    });

    // Extract the sub claim (Auth0 user ID)
    const auth0Sub = decoded.sub;
    if (!auth0Sub) {
      return reply.code(401).send({ error: 'Unauthorized', message: 'Token missing sub claim' });
    }

    // Get or create user in database
    const user = await getOrCreateUserByAuth0Sub(
      auth0Sub,
      decoded.name || decoded.email || decoded.nickname || 'User'
    );

    // Attach user to request
    request.user = {
      id: user.id,
      auth0Sub: user.auth0Sub,
      displayName: user.displayName,
    };
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      request.log.error({ error: error.message, name: error.name }, 'JWT validation error');
      return reply.code(401).send({ 
        error: 'Unauthorized', 
        message: `Invalid token: ${error.message}` 
      });
    }
    if (error instanceof jwt.TokenExpiredError) {
      request.log.warn('Token expired');
      return reply.code(401).send({ error: 'Unauthorized', message: 'Token expired' });
    }
    request.log.error({ error }, 'Authentication error');
    return reply.code(500).send({ error: 'Internal Server Error', message: 'Authentication failed' });
  }
}

