-- Fix plants table: Add missing columns for biodiversity analysis
-- This migration adds all the columns that the Flutter app expects

ALTER TABLE plants 
ADD COLUMN IF NOT EXISTS analysis_reasoning TEXT,
ADD COLUMN IF NOT EXISTS biodiversity_rating INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS pollinator_value INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_native BOOLEAN DEFAULT false;