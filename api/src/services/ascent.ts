// src/services/ascents.ts
import { db } from "../db/index.js";
import { ascent } from "../db/schema.js";
import { z } from "zod";
import { eq, sql } from "drizzle-orm";

type UUID = string; // keep simple; you can add a UUID zod later

export const CreateAscentInput = z.object({
  userId: z.string(),
  // routeId: z.string().optional(),
  locationId: z.string().optional(),
  style: z.enum(["attempt", "send", "flash", "onsight", "project"]),
  attempts: z.number().int().min(1).default(1),
  isOutdoor: z.boolean().default(false),
  rating: z.number().int().min(1).max(5).optional(),
  notes: z.string().max(10_000).optional(),
  climbedAt: z.coerce.date(), // accepts ISO string
}).refine(
  // (v) => Boolean(v.routeId) || Boolean(v.locationId),
  (v) => Boolean(v.locationId),
  { message: "Either routeId or locationId is required." }
);

export type CreateAscentInput = z.infer<typeof CreateAscentInput>;

export async function createAscent(input: CreateAscentInput) {
  const data = CreateAscentInput.parse(input);

  // If both provided, we accept it (route + location). If only routeId is given,
  // location can still be derived later via a join.

  const [row] = await db
    .insert(ascent)
    .values({
      id: crypto.randomUUID(),
      userId: data.userId,
      // routeId: data.routeId ?? null,
      locationId: data.locationId ?? null,
      style: data.style,
      attempts: data.attempts,
      isOutdoor: data.isOutdoor,
      rating: data.rating ?? null,
      notes: data.notes ?? null,
      climbedAt: data.climbedAt,
    })
    .returning();

  return row;
}

/** Simple query helper: fetch latest ascents with optional filters */
export const ListAscentsQuery = z.object({
  userId: z.string(),
  limit: z.number().int().min(1).max(100).default(20),
  after: z.coerce.date().optional(),   // fetch ascents after this date
  before: z.coerce.date().optional(),  // or before this date
  style: z.enum(["attempt", "send", "flash", "onsight", "project"]).optional(),
  routeId: z.string().uuid().optional(),
  locationId: z.string().uuid().optional(),
});

export type ListAscentsQuery = z.infer<typeof ListAscentsQuery>;

export async function listAscents(q: ListAscentsQuery) {
  const params = ListAscentsQuery.parse(q);

  const query = db.select().from(ascent).where(eq(ascent.userId, params.userId));

  const rows = await query
    .orderBy(sql`climbed_at DESC`)
    .limit(params.limit);

  return rows;
}