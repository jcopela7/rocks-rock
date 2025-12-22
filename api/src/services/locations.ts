// src/services/ascents.ts
import { sql } from 'drizzle-orm';
import { z } from 'zod';
import { db } from '../db/index.js';
import { location } from '../db/schema.js';

export const CreateLocationInput = z.object({
  id: z.string(),
  name: z.string(),
  type: z.enum(['gym', 'crag']),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  createdBy: z.string(),
  description: z.string().optional(),
});

export type CreateLocationInput = z.infer<typeof CreateLocationInput>;

export async function createLocation(input: CreateLocationInput) {
  const data = CreateLocationInput.parse(input);

  const [row] = await db
    .insert(location)
    .values({
      id: data.id,
      name: data.name,
      type: data.type,
      latitude: data.latitude,
      longitude: data.longitude,
      createdBy: data.createdBy,
      description: data.description ?? null,
    })
    .returning();

  return row;
}

export const ListLocationsQuery = z.object({
  name: z.string().optional(),
  type: z.enum(['gym', 'crag']).optional(),
});

export type ListLocationsQueryType = z.infer<typeof ListLocationsQuery>;

export async function listLocations(query?: ListLocationsQueryType) {
  const params = query ? ListLocationsQuery.parse(query) : {};
  
  let querySql = sql`SELECT * FROM location WHERE deleted_at IS NULL`;
  
  if (params.name) {
    querySql = sql`${querySql} AND LOWER(name) LIKE LOWER(${`%${params.name}%`})`;
  }
  
  if (params.type) {
    querySql = sql`${querySql} AND type = ${params.type}`;
  }
  
  querySql = sql`${querySql} ORDER BY created_at DESC`;

  const res = await db.execute(querySql);
  return (res as unknown as { rows: unknown[] }).rows;
}
