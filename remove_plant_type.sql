-- Remove plant_type column and enum from database
-- This removes the object type selection completely

-- Drop the enum type and column
DROP TYPE IF EXISTS plant_type CASCADE;
ALTER TABLE plants DROP COLUMN IF EXISTS plant_type;