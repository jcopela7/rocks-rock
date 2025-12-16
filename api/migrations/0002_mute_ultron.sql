-- Add auth0_sub column, allowing NULL initially for existing rows
ALTER TABLE "app_user" ADD COLUMN "auth0_sub" text;--> statement-breakpoint
-- Add unique constraint (NULL values are allowed and don't violate uniqueness)
ALTER TABLE "app_user" ADD CONSTRAINT "app_user_auth0_sub_unique" UNIQUE("auth0_sub");--> statement-breakpoint
-- For existing rows, set a temporary value (you may need to update these manually)
-- UPDATE "app_user" SET "auth0_sub" = 'legacy-' || id::text WHERE "auth0_sub" IS NULL;
-- After updating existing rows, make it NOT NULL
-- ALTER TABLE "app_user" ALTER COLUMN "auth0_sub" SET NOT NULL;