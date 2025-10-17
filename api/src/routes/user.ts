// src/routes/ascents.ts
import { FastifyInstance } from "fastify";
import { createUser, CreateUserInput, listUsers } from "../services/users.js";

export async function userRoutes(app: FastifyInstance) {
  // Create user
  app.post("/user", async (req, reply) => {
    const body = CreateUserInput.parse(req.body);
    const created = await createUser(body);
    return reply.code(201).send(created);
  });

  // List users
  app.get("/user", async () => {
    const rows = await listUsers();
    return { data: rows };
  });
}