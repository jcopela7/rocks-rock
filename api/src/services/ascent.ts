// src/services/ascents.ts
import { and, count, desc, eq, getTableColumns, gte, lte } from 'drizzle-orm';
import { z } from 'zod';
import { db } from '../db/index.js';
import { ascent, location, route } from '../db/schema.js';

type UUID = string; // keep simple; you can add a UUID zod later

export const CreateAscentInput = z
  .object({
    userId: z.string(),
    routeId: z.string().optional(),
    locationId: z.string().optional(),
    style: z.enum(['attempt', 'send', 'flash', 'onsight', 'redpoint']),
    attempts: z.number().int().min(1).default(1),
    rating: z.number().int().min(1).max(5).optional(),
    notes: z.string().max(10_000).optional(),
    climbedAt: z.coerce.date(),
  });

export type CreateAscentInputType = z.infer<typeof CreateAscentInput>;

export async function createAscent(input: CreateAscentInputType) {
  const data = CreateAscentInput.parse(input);

  // If both provided, we accept it (route + location). If only routeId is given,
  // location can still be derived later via a join.

  const [row] = await db
    .insert(ascent)
    .values({
      id: crypto.randomUUID(),
      userId: data.userId,
      routeId: data.routeId ?? null,
      locationId: data.locationId ?? null,
      style: data.style,
      attempts: data.attempts,
      rating: data.rating ?? null,
      notes: data.notes ?? null,
      climbedAt: data.climbedAt,
    })
    .returning();

  return row;
}

/** Simple query helper: fetch latest ascents with optional filters */
export const ListAscentsQuery = z.object({
  id: z.string().optional(),
  userId: z.string(),
  limit: z.number().int().min(1).max(100).default(20),
  after: z.coerce.date().optional(), // fetch ascents after this date
  before: z.coerce.date().optional(), // or before this date
  style: z.enum(['attempt', 'send', 'flash', 'onsight', 'project']).optional(),
  routeId: z.string().uuid().optional(),
  locationId: z.string().uuid().optional(),
  isOutdoor: z.boolean().optional(),
  minRating: z.number().optional(),
  maxRating: z.number().optional(),
});

export type ListAscentsQueryType = z.infer<typeof ListAscentsQuery>;

export async function listAscents(body: ListAscentsQueryType) {
  const params = ListAscentsQuery.parse(body);

  const conditions = [eq(ascent.userId, params.userId)];

  if (params.id) {
    conditions.push(eq(ascent.id, params.id));
  }
  if (params.after) {
    conditions.push(gte(ascent.climbedAt, params.after));
  }
  if (params.before) {
    conditions.push(lte(ascent.climbedAt, params.before));
  }
  if (params.style) {
    conditions.push(eq(ascent.style, params.style));
  }
  if (params.minRating) {
    conditions.push(gte(ascent.rating, params.minRating));
  }
  if (params.maxRating) {
    conditions.push(lte(ascent.rating, params.maxRating));
  }

  const query = db
    .select({
      ...getTableColumns(ascent),
      routeName: route.name,
      routeDiscipline: route.discipline,
      locationName: location.name,
    })
    .from(ascent)
    .leftJoin(route, eq(ascent.routeId, route.id))
    .leftJoin(location, eq(ascent.locationId, location.id))
    .where(and(...conditions))
    .orderBy(desc(ascent.climbedAt))
    .limit(params.limit);
  const rows = await query;
  return rows;
}

export async function getAscentDetail(id: string) {
  const query = db
   .select({
    ...getTableColumns(ascent),
    routeName: route.name,
    routeDiscipline: route.discipline,
    locationName: location.name,
   }).from(ascent)
   .leftJoin(route, eq(ascent.routeId, route.id))
   .leftJoin(location, eq(ascent.locationId, location.id))
   .where(eq(ascent.id, id!))
   .orderBy(desc(ascent.climbedAt));
  const rows = await query;
  return rows;
}

export const GetCountOfAscentsByLocationQuery = z.object({
  userId: z.string(),
});
export type GetCountOfAscentsByLocationQueryType = z.infer<typeof GetCountOfAscentsByLocationQuery>;

export async function getCountOfAscentsGroupByLocation(body: GetCountOfAscentsByLocationQueryType) {
  const query = db
  .select({
    locationName: location.name,
    totalAscents: count(ascent.id),
  }).from(ascent)
  .leftJoin(location, eq(ascent.locationId, location.id))
  .where(eq(ascent.userId, body.userId))
  .groupBy(location.name);

  const rows = await query;
  return rows;
}

export const GetCountOfAscentsByGradeQuery = z.object({
  userId: z.string(),
  discipline: z.enum(['boulder', 'sport', 'trad', 'board']),
});
export type GetCountOfAscentsByGradeQueryType = z.infer<typeof GetCountOfAscentsByGradeQuery>;

export async function getCountOfAscentsByGrade(body: GetCountOfAscentsByGradeQueryType) {
  const query = db
  .select({
    routeDiscipline: route.discipline,
    gradeSystem: route.gradeSystem,
    gradeValue: route.gradeValue,
    gradeRank: route.gradeRank,
    totalAscents: count(ascent.id),
  }).from(ascent)
  .leftJoin(route, eq(ascent.routeId, route.id))
  .where(and(eq(ascent.userId, body.userId), eq(route.discipline, body.discipline)))
  .groupBy(route.discipline, route.gradeSystem, route.gradeValue, route.gradeRank);

  const rows = await query;
  return rows;
}

export async function deleteAscent(id: string) {
  const [row] = await db.delete(ascent).where(eq(ascent.id, id)).returning();
  return row;
}
