// src/routes/ascents.ts
import { FastifyInstance } from 'fastify';
import z from 'zod';
import {
  createAscent,
  CreateAscentInput,
  deleteAscent,
  getAscentDetail,
  getCountOfAscentsByGrade,
  GetCountOfAscentsByGradeQuery,
  GetCountOfAscentsByLocationQuery,
  getCountOfAscentsGroupByLocation,
  getMaxGradeByDiscipline,
  GetMaxGradeByDisciplineQuery,
  listAscents,
  ListAscentsQuery,
} from '../services/ascent.js';
import { authenticateUser } from '../middleware/auth.js';

export async function ascentRoutes(app: FastifyInstance) {
  // Apply authentication to all ascent routes
  app.addHook('onRequest', authenticateUser);

  // Create ascent
  app.post('/ascent', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const body = CreateAscentInput.parse(req.body);
    const created = await createAscent(body, req.user.id);
    return reply.code(201).send(created);
  });

  app.get('/ascent', async (req) => {
    if (!req.user) {
      throw new Error('User not authenticated');
    }
    // Fastify types `req.query` as unknown; validate with Zod
    const query = ListAscentsQuery.parse(req.query);
    const rows = await listAscents(query, req.user.id);
    return { data: rows };
  });

  app.get('/ascent/count/grade', async (req) => {
    if (!req.user) {
      throw new Error('User not authenticated');
    }
    const query = GetCountOfAscentsByGradeQuery.parse(req.query);
    const count = await getCountOfAscentsByGrade(query, req.user.id);
    return { data: count };
  });

  app.get('/ascent/count/location', async (req) => {
    if (!req.user) {
      throw new Error('User not authenticated');
    }
    const query = GetCountOfAscentsByLocationQuery.parse(req.query);
    const count = await getCountOfAscentsGroupByLocation(req.user.id);
    return { data: count };
  });

  app.get('/ascent/max/grade', async (req) => {
    if (!req.user) {
      throw new Error('User not authenticated');
    }
    const query = GetMaxGradeByDisciplineQuery.parse(req.query);
    const maxGrade = await getMaxGradeByDiscipline(query, req.user.id);
    return { data: maxGrade };
  });
  
  app.get('/ascent/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string() }).parse(req.params);
    const ascent = await getAscentDetail(id, req.user.id);
    if (!ascent) return reply.code(404).send({ error: 'Not Found' });
    return { data: ascent };
  });

  app.delete('/ascent/:id', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const deleted = await deleteAscent(id, req.user.id);
    if (!deleted) return reply.code(404).send({ error: 'Not Found' });
    return { data: deleted };
  });
}
