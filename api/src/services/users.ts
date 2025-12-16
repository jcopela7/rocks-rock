// src/services/users.ts
import { db } from '../db/index.js';
import { appUser } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import { z } from 'zod';

export const CreateUserInput = z.object({
  userId: z.string().uuid(),
  displayName: z.string(),
});

export type CreateUserInput = z.infer<typeof CreateUserInput>;

export async function createUser(input: CreateUserInput) {
  const data = CreateUserInput.parse(input);

  const [row] = await db
    .insert(appUser)
    .values({
      id: data.userId,
      auth0Sub: null, // Legacy support - this should not be used for new users
      displayName: data.displayName,
    })
    .returning();

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

export async function listUsers() {
  // Use raw SQL for date ranges (clear & indexed)
  const sql = `
    SELECT * FROM app_user
    ORDER BY created_at DESC
  `;

  // For brevity, use `db.execute` here (typed results still work fine)
  const res = await db.execute(sql);
  return (res as unknown as { rows: unknown[] }).rows;
}
