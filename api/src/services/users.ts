// src/services/ascents.ts
import { db } from "../db/index.js";
import { appUser } from "../db/schema.js";
import { z } from "zod";

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
      displayName: data.displayName,
    })
    .returning();

  return row;
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
