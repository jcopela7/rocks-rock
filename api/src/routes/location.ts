import { FastifyInstance } from 'fastify';
import { createLocation, CreateLocationInput, listLocations } from '../services/locations.js';

export async function locationRoutes(app: FastifyInstance) {
  // Create location
  app.post('/location', async (req, reply) => {
    const body = CreateLocationInput.parse(req.body);
    const created = await createLocation(body);
    return reply.code(201).send(created);
  });

  // List users
  app.get('/location', async () => {
    const rows = await listLocations();
    return { data: rows };
  });
}
