-- Fix pollinator_value column type to INTEGER
-- This migration converts the pollinator_value column from TEXT to INTEGER
-- High = 3, Medium = 2, Low = 1

-- Update existing text values to integer equivalents
UPDATE plants 
SET pollinator_value = CASE 
  WHEN LOWER(pollinator_value) = 'high' THEN '3'
  WHEN LOWER(pollinator_value) = 'medium' THEN '2'  
  WHEN LOWER(pollinator_value) = 'low' THEN '1'
  ELSE '2'
END;

-- Change column type to INTEGER
ALTER TABLE plants 
ALTER COLUMN pollinator_value TYPE INTEGER USING pollinator_value::INTEGER;

-- Set default value
ALTER TABLE plants 
ALTER COLUMN pollinator_value SET DEFAULT 2;