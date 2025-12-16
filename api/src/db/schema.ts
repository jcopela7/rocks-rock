// src/db/schema.ts
import {
  doublePrecision,
  integer,
  pgTable,
  text,
  timestamp,
  uuid
} from 'drizzle-orm/pg-core';

/** Core user profile mirrored from your auth provider */
export const appUser = pgTable('app_user', {
  id: uuid('id').primaryKey(), // use your auth/user UUID
  auth0Sub: text('auth0_sub').unique(), // Auth0 sub claim (e.g., "auth0|...") - nullable for legacy users
  displayName: text('display_name').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
});

/** Gyms & crags */
export const location = pgTable('location', {
  id: uuid('id').primaryKey(),
  name: text('name').notNull(),
  type: text('type').notNull(), // 'gym' | 'crag'
  description: text('description'),
  latitude: doublePrecision('latitude'),
  longitude: doublePrecision('longitude'),
  createdBy: uuid('created_by').references(() => appUser.id),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

/** Routes / problems */
export const route = pgTable('route', {
  id: uuid('id').primaryKey(),
  locationId: uuid('location_id')
    .references(() => location.id)
    .notNull(),
  name: text('name'),
  discipline: text('discipline').notNull(), // 'boulder' | 'sport' | 'trad' | 'board
  description: text('description'),
  gradeSystem: text('grade_system').notNull(), // 'V' | 'YDS' | 'Font'
  gradeValue: text('grade_value').notNull(), // 'V5' | '5.12a' | 8a+
  gradeRank: integer('grade_rank').notNull(), // numeric for filters
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

/**
 * Ascents: each climb attempt/send is recorded directly (no session).
 * You can attach to a route (preferred) and/or a location (for “unlisted” problems).
 */
export const ascent = pgTable('ascent', {
  id: uuid('id').primaryKey(),
  userId: uuid('user_id')
    .references(() => appUser.id)
    .notNull(),

  // Either link to an existing route or keep null if it's an ad-hoc climb
  routeId: uuid('route_id').references(() => route.id),

  // Optional explicit location (useful if routeId is null or for quicker filters)
  locationId: uuid('location_id').references(() => location.id),

  style: text('style').notNull(), // 'attempt' | 'send' | 'flash' | 'onsight' | 'project'
  attempts: integer('attempts').default(1),
  rating: integer('rating'),
  notes: text('notes'),

  // When the climb happened (use this for timeline & filters)
  climbedAt: timestamp('climbed_at', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

/** Photos/videos tied to an ascent (preferred) or directly to a route */
export const media = pgTable('media', {
  id: uuid('id').primaryKey(),
  userId: uuid('user_id')
    .references(() => appUser.id)
    .notNull(),
  ascentId: uuid('ascent_id').references(() => ascent.id),
  routeId: uuid('route_id').references(() => route.id),
  s3Key: text('s3_key').notNull(),
  mimeType: text('mime_type').notNull(),
  takenAt: timestamp('taken_at', { withTimezone: true }),
  width: integer('width'),
  height: integer('height'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
});
