import { and, asc, eq, ilike, isNull } from 'drizzle-orm';
import { z } from 'zod';
import { db } from '../db/index.js';
import { location, userLocation } from '../db/schema.js';
import { ListLocationsQuery, ListLocationsQueryType } from './locations.js';

export const CreateUserLocationInput = z.object({
  locationId: z.string().uuid(),
});

export type CreateUserLocationInput = z.infer<typeof CreateUserLocationInput>;

export async function createUserLocation(input: CreateUserLocationInput, userId: string) {
  const data = CreateUserLocationInput.parse(input);
  const [row] = await db
    .insert(userLocation)
    .values({
      id: crypto.randomUUID(),
      userId,
      locationId: data.locationId,
    })
    .returning();
  return row;
}

export async function listMyLocations(userId: string, query?: ListLocationsQueryType) {
  const params = query ? ListLocationsQuery.parse(query) : {};

  const conditions = [isNull(location.deletedAt)];
  if (params.name) {
    conditions.push(ilike(location.name, `%${params.name}%`));
  }
  if (params.type) {
    conditions.push(eq(location.type, params.type));
  }

  const rows = await db
    .select({
      id: userLocation.id,
      locationId: location.id,
      name: location.name,
      type: location.type,
      description: location.description,
      latitude: location.latitude,
      longitude: location.longitude,
    })
    .from(location)
    .innerJoin(userLocation, eq(location.id, userLocation.locationId))
    .where(and(eq(userLocation.userId, userId), ...conditions))
    .orderBy(asc(location.name));

  return rows;
}

export async function deleteUserLocation( id: string, userId: string) {
  const [row] = await db
    .delete(userLocation)
    .where(and(eq(userLocation.id, id), eq(userLocation.userId, userId)))
    .returning();

  return row ?? null;
}