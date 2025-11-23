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
  listAscents,
  ListAscentsQuery,
} from '../services/ascent.js';

export async function ascentRoutes(app: FastifyInstance) {
  // Create ascent
  app.post('/ascent', async (req, reply) => {
    const body = CreateAscentInput.parse(req.body);
    const created = await createAscent(body);
    return reply.code(201).send(created);
  });
  app.get('/ascent', async (req) => {
    // Fastify types `req.query` as unknown; validate with Zod
    const query = ListAscentsQuery.parse(req.query);
    const rows = await listAscents(query);
    return { data: rows };
  });

  app.get('/ascent/count/grade', async (req) => {
    const query = GetCountOfAscentsByGradeQuery.parse(req.query);
    const count = await getCountOfAscentsByGrade(query);
    return { data: count };
  });

  app.get('/ascent/count/location', async (req) => {
    const query = GetCountOfAscentsByLocationQuery.parse(req.query);
    const count = await getCountOfAscentsGroupByLocation(query);
    return { data: count };
  });

  app.get('/ascnet/:id', async (req, reply) => {
    const { id } = z.object({ id: z.string() }).parse(req.params);
    const ascent = await getAscentDetail(id);
    if (!ascent) return reply.code(404).send({ error: 'Not Found' });
    return { data: ascent };
  });

  app.delete('/ascent/:id', async (req, reply) => {
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const deleted = await deleteAscent(id);
    if (!deleted) return reply.code(404).send({ error: 'Not Found' });
    return { data: deleted };
  });
}
