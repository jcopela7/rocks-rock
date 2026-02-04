import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import {
  createLocation,
  CreateLocationInput,
  deleteLocation,
  listLocations,
  ListLocationsQuery,
} from '../services/locations.js';
import { authenticateUser } from '../middleware/auth.js';

export async function locationRoutes(app: FastifyInstance) {
  // Apply authentication to all location routes
  app.addHook('onRequest', authenticateUser);

  // Create location
  app.post('/location', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const body = CreateLocationInput.parse(req.body);
    const created = await createLocation(body);
    return reply.code(201).send(created);
  });

  // List locations
  app.get('/location', async (req) => {
    if (!req.user) {
      throw new Error('User not authenticated');
    }
    // Fastify types `req.query` as unknown; validate with Zod
    const query = ListLocationsQuery.parse(req.query);
    const rows = await listLocations(query);
    return { data: rows };
  });

  // Delete location
  app.delete('/location/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string() }).parse(req.params);
    const deleted = await deleteLocation(id);
    if (!deleted) return reply.code(404).send({ error: 'Not Found' });
    return { data: deleted };
  });
}
