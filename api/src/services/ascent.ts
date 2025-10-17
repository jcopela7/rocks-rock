// src/services/ascents.ts
import { db } from "../db/index.js";
import { ascent } from "../db/schema.js";
import { z } from "zod";
import { eq } from "drizzle-orm";

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

  // Build a tiny dynamic WHERE
  const where: any[] = [eq(ascent.userId, params.userId)];
  if (params.style) where.push(eq(ascent.style, params.style));
  if (params.routeId) where.push(eq(ascent.routeId, params.routeId));
  if (params.locationId) where.push(eq(ascent.locationId, params.locationId));

  // Use raw SQL for date ranges (clear & indexed)
  const sql = `
    SELECT * FROM ascent
    WHERE user_id = $1
      ${params.style ? "AND style = $2" : ""}
      /* ${params.routeId ? "AND route_id = $3" : ""} */
      ${params.locationId ? "AND location_id = $4" : ""}
      ${params.after ? "AND climbed_at >= $5" : ""}
      ${params.before ? "AND climbed_at <= $6" : ""}
    ORDER BY climbed_at DESC
    LIMIT $7
  `;

  // For brevity, use `db.execute` here (typed results still work fine)
  const args = [
    params.userId,
    ...(params.style ? [params.style] as const : []),
    ...(params.routeId ? [params.routeId] as const : []),
    ...(params.locationId ? [params.locationId] as const : []),
    ...(params.after ? [params.after] as const : []),
    ...(params.before ? [params.before] as const : []),
    params.limit,
  ];

  const res = await db.execute(sql as string, args as unknown[]);
  return (res as unknown as { rows: unknown[] }).rows;
}
