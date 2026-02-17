CREATE TABLE "user_location" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"location_id" uuid NOT NULL,
	CONSTRAINT "user_location_user_id_location_id_unique" UNIQUE("user_id","location_id")
);
--> statement-breakpoint
ALTER TABLE "user_location" ADD CONSTRAINT "user_location_user_id_app_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."app_user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_location" ADD CONSTRAINT "user_location_location_id_location_id_fk" FOREIGN KEY ("location_id") REFERENCES "public"."location"("id") ON DELETE no action ON UPDATE no action;