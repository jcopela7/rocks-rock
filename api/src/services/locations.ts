// src/services/locations.ts
import { and, desc, eq, ilike, isNull } from 'drizzle-orm';
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

export const updateLocationInput = z.object({
  id: z.string(),
  name: z.string().optional(),
  type: z.enum(['gym', 'crag']).optional(),
  description: z.string().optional(),
  latitude: z.number().optional(),
});

export type updateLocationInput = z.infer<typeof updateLocationInput>;

export async function updateLocation(id: string, input: updateLocationInput) {
  const data = updateLocationInput.parse(input);
  const [row] = await db
    .update(location)
    .set({
      ...data,
      updatedAt: new Date(),
    })
    .where(eq(location.id, id))
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

  const conditions = [isNull(location.deletedAt)];
  if (params.name) {
    conditions.push(ilike(location.name, `%${params.name}%`));
  }
  if (params.type) {
    conditions.push(eq(location.type, params.type));
  }

  const rows = await db
    .select()
    .from(location)
    .where(and(...conditions))
    .orderBy(desc(location.createdAt));

  return rows;
}

export async function deleteLocation(id: string) {
  const [row] = await db
    .update(location)
    .set({
      deletedAt: new Date(),
      updatedAt: new Date(),
    })
    .where(eq(location.id, id))
    .returning();

  return row;
}
