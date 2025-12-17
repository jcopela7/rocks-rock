import { FastifyInstance } from 'fastify';
import { createLocation, CreateLocationInput, listLocations } from '../services/locations.js';
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
    const rows = await listLocations();
    return { data: rows };
  });
}
