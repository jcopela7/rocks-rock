ALTER TABLE "ascent" ADD COLUMN "custom_climb_name" text;--> statement-breakpoint
ALTER TABLE "ascent" ADD COLUMN "custom_grade_value" text;--> statement-breakpoint
ALTER TABLE "ascent" ADD COLUMN "custom_grade_rank" integer;--> statement-breakpoint
ALTER TABLE "ascent" ADD COLUMN "custom_discipline" text;--> statement-breakpoint
INSERT INTO "location" ("id", "name", "type", "created_at", "updated_at") VALUES
  ('4b684938-4925-4947-9b1a-1ef168384efe', 'Moon Board',    'board', NOW(), NOW()),
  ('3db8f6b3-f211-4cf9-8f9c-7fed9149b14a', 'Kilter Board',  'board', NOW(), NOW()),
  ('5a181b97-5e40-4477-ba77-d3989875d995', 'Tension Board', 'board', NOW(), NOW()),
  ('6f2d984c-c47e-4533-9a66-2273a9d5d1b5', 'Spray Wall',    'board', NOW(), NOW());
