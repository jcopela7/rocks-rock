// src/routes/ascents.ts
import { FastifyInstance } from "fastify";
import { createAscent, CreateAscentInput, listAscents, ListAscentsQuery } from "../services/ascent.js";

export async function ascentRoutes(app: FastifyInstance) {
  // Create ascent
  app.post("/ascent", async (req, reply) => {
    const body = CreateAscentInput.parse(req.body);
    const created = await createAscent(body);
    return reply.code(201).send(created);
  });

  // List ascents (basic filters)
  app.get("/ascent", async (req) => {
    // Fastify types `req.query` as unknown; validate with Zod
    const query = ListAscentsQuery.parse(req.query);
    const rows = await listAscents(query);
    return { data: rows };
  });
}