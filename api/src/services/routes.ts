// src/services/routes.ts
import { and, desc, eq, isNull } from 'drizzle-orm';
import { z } from 'zod';
import { db } from '../db/index.js';
import { route } from '../db/schema.js';

export const CreateRouteInput = z.object({
  id: z.string().optional(), // optional, will generate if not provided
  locationId: z.string(),
  name: z.string().optional(),
  discipline: z.enum(['boulder', 'sport', 'trad']),
  gradeSystem: z.enum(['V', 'YDS', 'Font']),
  gradeValue: z.string(),
  gradeRank: z.number().int(),
  color: z.string().optional(),
});

export type CreateRouteInput = z.infer<typeof CreateRouteInput>;

export const UpdateRouteInput = z.object({
  locationId: z.string().optional(),
  name: z.string().optional(),
  discipline: z.enum(['boulder', 'sport', 'trad']).optional(),
  gradeSystem: z.enum(['V', 'YDS', 'Font']).optional(),
  gradeValue: z.string().optional(),
  gradeRank: z.number().int().optional(),
  color: z.string().optional(),
});

export type UpdateRouteInput = z.infer<typeof UpdateRouteInput>;

export async function createRoute(input: CreateRouteInput) {
  const data = CreateRouteInput.parse(input);

  const [row] = await db
    .insert(route)
    .values({
      id: data.id || crypto.randomUUID(),
      locationId: data.locationId,
      name: data.name ?? null,
      discipline: data.discipline,
      gradeSystem: data.gradeSystem,
      gradeValue: data.gradeValue,
      gradeRank: data.gradeRank,
      color: data.color ?? null,
    })
    .returning();

  return row;
}

export async function listRoutes() {
  const rows = await db
    .select()
    .from(route)
    .where(isNull(route.deletedAt))
    .orderBy(desc(route.createdAt));

  return rows;
}

export async function getRouteDetail(id: string) {
  const [row] = await db
    .select()
    .from(route)
    .where(and(eq(route.id, id), isNull(route.deletedAt)));

  return row;
}

export async function updateRoute(id: string, input: UpdateRouteInput) {
  const data = UpdateRouteInput.parse(input);

  const [row] = await db
    .update(route)
    .set({
      ...data,
      updatedAt: new Date(),
    })
    .where(eq(route.id, id))
    .returning();

  return row;
}

export async function deleteRoute(id: string) {
  // Soft delete by setting deletedAt
  const [row] = await db
    .update(route)
    .set({
      deletedAt: new Date(),
      updatedAt: new Date(),
    })
    .where(eq(route.id, id))
    .returning();

  return row;
}

