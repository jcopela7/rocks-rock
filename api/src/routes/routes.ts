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

export async function routeRoutes(app: FastifyInstance) {
  // Create route
  app.post('/route', async (req, reply) => {
    const body = CreateRouteInput.parse(req.body);
    const created = await createRoute(body);
    return reply.code(201).send(created);
  });

  // List routes
  app.get('/route', async () => {
    const rows = await listRoutes();
    return { data: rows };
  });

  // Get single route
  app.get('/route/:id', async (req, reply) => {
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const route = await getRouteDetail(id);
    if (!route) return reply.code(404).send({ error: 'Not Found' });
    return { data: route };
  });

  // Update route
  app.put('/route/:id', async (req, reply) => {
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const body = UpdateRouteInput.parse(req.body);
    const updated = await updateRoute(id, body);
    if (!updated) return reply.code(404).send({ error: 'Not Found' });
    return { data: updated };
  });

  // Delete route
  app.delete('/route/:id', async (req, reply) => {
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const deleted = await deleteRoute(id);
    if (!deleted) return reply.code(404).send({ error: 'Not Found' });
    return { data: deleted };
  });
}

