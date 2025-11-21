ALTER TABLE "route" RENAME COLUMN "color" TO "description";--> statement-breakpoint
ALTER TABLE "location" ADD COLUMN "description" text;--> statement-breakpoint
ALTER TABLE "ascent" DROP COLUMN "is_outdoor";