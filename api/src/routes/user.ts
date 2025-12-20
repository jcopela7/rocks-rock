// src/routes/ascents.ts
import { FastifyInstance } from 'fastify';
import { createUser, CreateUserInput, UpdateUserInput, updateUser, getUser } from '../services/users.js';
import { authenticateUser } from '../middleware/auth.js';


export async function user(app: FastifyInstance) {
  app.addHook('onRequest', authenticateUser);
  
  // Create user
  app.post('/user', async (req, reply) => {
    const body = CreateUserInput.parse(req.body);
    const created = await createUser(body);
    return reply.code(201).send(created);
  });

  // Get user
  app.get('/user/me', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const user = await getUser(req.user.id);
    return reply.code(200).send({ data: user });
  });

  // Update user
  app.put('/user/me', async (req, reply) => {
    if (!req.user) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }
    const body = UpdateUserInput.parse(req.body);
    const updated = await updateUser(body, req.user.id);
    return reply.code(200).send({ data: updated });
  });
}
