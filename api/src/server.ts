import cors from '@fastify/cors';
import dotenv from 'dotenv';
import { sql } from 'drizzle-orm';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import Fastify from 'fastify';
import { ZodError } from 'zod';
import { db } from './db/index.js';
import { ascentRoutes } from './routes/ascents.js';
import { userRoutes } from './routes/user.js';
import { locationRoutes } from './routes/location.js';
dotenv.config();

const app = Fastify();
app.register(cors, { origin: '*' });
app.register(ascentRoutes, { prefix: '/api/v1' });
app.register(userRoutes, { prefix: '/api/v1' });
app.register(locationRoutes, { prefix: '/api/v1' });
app.get('/', async () => ({ ok: true, service: 'jonrocks-api' }));

async function start() {
  const port = Number(process.env.PORT) || 3000;
  await migrate(db, { migrationsFolder: 'migrations' }); // ensures tables exist
  await app.listen({ host: '0.0.0.0', port });
  console.log(`🚀 Server running at http://localhost:${port}`);
}

start().catch((err) => {
  console.error(err);
  process.exit(1);
});

app.ready().then(() => console.log(app.printRoutes()));

app.get('/db/health', async () => {
  const version = await db.execute(sql`select version();`);
  return {
    ok: true,
    version:
      (version as unknown as { rows: { version: string }[] }).rows?.[0]?.version ?? 'unknown',
  };
});

app.setErrorHandler((err, req, reply) => {
  if (err instanceof ZodError) {
    return reply.code(400).send({
      error: 'Bad Request',
      issues: err.issues.map((i) => ({
        path: i.path.join('.'),
        message: i.message,
      })),
    });
  }

  // If it's a DB error, expose the important parts
  const pg: { detail?: string; code?: string; constraint?: string; message?: string } =
    err?.cause ?? err;
  req.log.error(pg);
  return reply.code(500).send({
    error: 'Internal Server Error',
    // Uncomment during dev to see details:
    detail: pg?.detail,
    code: pg?.code,
    constraint: pg?.constraint,
    message: pg?.message,
  });
});
