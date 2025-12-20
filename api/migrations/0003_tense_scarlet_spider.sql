ALTER TABLE "app_user" ALTER COLUMN "auth0_sub" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "app_user" ADD COLUMN "email" text;--> statement-breakpoint
ALTER TABLE "app_user" ADD COLUMN "first_name" text;