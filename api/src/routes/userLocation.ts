import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { createUserLocation, CreateUserLocationInput, deleteUserLocation } from '../services/userLocation.js';
import { authenticateUser } from '../middleware/auth.js';

export async function userLocationRoutes(app: FastifyInstance) {
  app.addHook('onRequest', authenticateUser);

  app.post('/user/location', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const body = CreateUserLocationInput.parse(req.body);
    const created = await createUserLocation(body, req.user.id);
    return reply.code(201).send(created);
  });

  app.delete('/user/location/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const deleted = await deleteUserLocation(id, req.user.id);
    if (!deleted) return reply.code(404).send({ error: 'Not Found' });
    return { data: deleted };
  });
}