import { and, eq } from 'drizzle-orm';
import { z } from 'zod';
import { db } from '../db/index.js';
import { userLocation } from '../db/schema.js';

export const CreateUserLocationInput = z.object({
  id: z.string().uuid(),
  locationId: z.string().uuid(),
});

export type CreateUserLocationInput = z.infer<typeof CreateUserLocationInput>;

export async function createUserLocation(input: CreateUserLocationInput, userId: string) {
  const data = CreateUserLocationInput.parse(input);
  const [row] = await db
    .insert(userLocation)
    .values({
      id: data.id,
      userId,
      locationId: data.locationId,
    })
    .returning();
  return row;
}

export async function deleteUserLocation(
  id: string,
  userId: string
): Promise<{ id: string; userId: string; locationId: string } | null> {
  const [row] = await db
    .delete(userLocation)
    .where(and(eq(userLocation.id, id), eq(userLocation.userId, userId)))
    .returning();

  return row ?? null;
}