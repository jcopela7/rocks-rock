import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { createUserLocation, CreateUserLocationInput, deleteUserLocation, listMyLocations } from '../services/userLocation.js';
import { authenticateUser } from '../middleware/auth.js';
import { ListLocationsQuery } from '../services/locations.js';

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

  app.get('/user/location', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const query = ListLocationsQuery.parse(req.query);
    const rows = await listMyLocations(req.user.id, query);
    return reply.code(200).send({ data: rows });
  });

  app.delete('/user/location/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const deleted = await deleteUserLocation(id, req.user.id);
    if (!deleted) return reply.code(404).send({ error: 'Not Found' });
    return reply.code(200).send({ data: deleted });
  });
}