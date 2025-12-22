// src/services/ascents.ts
import { and, desc, ilike } from 'drizzle-orm';
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
});

export type ListLocationsQueryType = z.infer<typeof ListLocationsQuery>;

export async function listLocations(query?: ListLocationsQueryType) {
  const params = query ? ListLocationsQuery.parse(query) : {};

  const conditions = [];

  if (params.name) {
    conditions.push(ilike(location.name, `%${params.name}%`));
  }

  const queryBuilder = db
    .select()
    .from(location);

  const finalQuery = conditions.length > 0
    ? queryBuilder.where(and(...conditions))
    : queryBuilder;

  const rows = await finalQuery.orderBy(desc(location.createdAt));
  return rows;
}
