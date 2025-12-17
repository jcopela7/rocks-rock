// src/services/users.ts
import { db } from '../db/index.js';
import { appUser } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import { z } from 'zod';

export const CreateUserInput = z.object({
  userId: z.string().uuid(),
  displayName: z.string(),
  email: z.string().email().optional(),
  firstName: z.string().optional(),
});

export type CreateUserInputType = z.infer<typeof CreateUserInput>;

export async function createUser(input: CreateUserInputType) {
  const data = CreateUserInput.parse(input);

  const [row] = await db
    .insert(appUser)
    .values({
      id: data.userId,
      auth0Sub: null, // Legacy support - this should not be used for new users
      displayName: data.displayName,
      email: data.email,
      firstName: data.firstName,
    })
    .returning();

  return row;
}

export const UpdateUserInput = z.object({
  displayName: z.string().min(1).optional(),
  firstName: z.string().min(1).optional(),
});

export type UpdateUserInputType = z.infer<typeof UpdateUserInput>;

export async function updateUser(input: UpdateUserInputType, userId: string) {
  const data = UpdateUserInput.parse(input);

  const [row] = await db
    .update(appUser)
    .set({
      ...(data.displayName !== undefined ? { displayName: data.displayName } : {}),
      ...(data.firstName !== undefined ? { firstName: data.firstName } : {}),
    })
    .where(eq(appUser.id, userId))
    .returning({
      id: appUser.id,
      displayName: appUser.displayName,
      firstName: appUser.firstName,
    });

  return row;
}

export async function getUser(userId: string) {
  const [row] = await db
    .select({
      id: appUser.id,
      displayName: appUser.displayName,
      firstName: appUser.firstName,
    })
    .from(appUser)
    .where(eq(appUser.id, userId))
    .limit(1);
  return row;
}

/**
 * Get user by Auth0 sub claim
 */
export async function getUserByAuth0Sub(auth0Sub: string) {
  const [user] = await db
    .select()
    .from(appUser)
    .where(eq(appUser.auth0Sub, auth0Sub))
    .limit(1);

  return user || null;
}

/**
 * Get or create user by Auth0 sub claim
 * If user doesn't exist, creates a new user with generated UUID
 */
export async function getOrCreateUserByAuth0Sub(
  auth0Sub: string,
  displayName: string
) {
  // Try to get existing user
  const existingUser = await getUserByAuth0Sub(auth0Sub);
  if (existingUser) {
    return existingUser;
  }

  // Create new user
  const [newUser] = await db
    .insert(appUser)
    .values({
      id: crypto.randomUUID(),
      auth0Sub: auth0Sub,
      displayName: displayName,
    })
    .returning();

  return newUser;
}
