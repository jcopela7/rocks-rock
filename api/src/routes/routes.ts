import { FastifyInstance } from 'fastify';
import z from 'zod';
import {
    createRoute,
    CreateRouteInput,
    deleteRoute,
    getRouteDetail,
    listRoutes,
    updateRoute,
    UpdateRouteInput,
} from '../services/routes.js';
import { authenticateUser } from '../middleware/auth.js';

export async function routeRoutes(app: FastifyInstance) {
  // Apply authentication to all route endpoints
  app.addHook('onRequest', authenticateUser);

  // Create route
  app.post('/route', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const body = CreateRouteInput.parse(req.body);
    const created = await createRoute(body);
    return reply.code(201).send(created);
  });

  // List routes
  app.get('/route', async (req) => {
    if (!req.user) {
      throw new Error('User not authenticated');
    }
    const rows = await listRoutes();
    return { data: rows };
  });

  // Get single route
  app.get('/route/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const route = await getRouteDetail(id);
    if (!route) return reply.code(404).send({ error: 'Not Found' });
    return { data: route };
  });

  // Update route
  app.put('/route/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const body = UpdateRouteInput.parse(req.body);
    const updated = await updateRoute(id, body);
    if (!updated) return reply.code(404).send({ error: 'Not Found' });
    return { data: updated };
  });

  // Delete route
  app.delete('/route/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const deleted = await deleteRoute(id);
    if (!deleted) return reply.code(404).send({ error: 'Not Found' });
    return { data: deleted };
  });
}

