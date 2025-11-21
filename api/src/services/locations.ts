// src/services/ascents.ts
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

export async function listLocations() {
  const sql = `
  SELECT * FROM location
  ORDER BY created_at DESC
  `;

  const res = await db.execute(sql);
  return (res as unknown as { rows: unknown[] }).rows;
}
