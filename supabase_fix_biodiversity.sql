-- Biodiversitäts-Index und Pollinator-Value Felder in der plants Tabelle korrigieren
-- Diese werden als Text gespeichert, nicht als Integer

ALTER TABLE plants DROP COLUMN IF EXISTS biodiversity_rating;
ALTER TABLE plants DROP COLUMN IF EXISTS pollinator_value;

-- Biodiversitäts-Index als Text-Feld hinzufügen
ALTER TABLE plants ADD COLUMN biodiversity_rating TEXT;

-- Pollinator-Value als Text-Feld hinzufügen  
ALTER TABLE plants ADD COLUMN pollinator_value TEXT;

-- Analysis-Reasoning falls noch nicht vorhanden
ALTER TABLE plants ADD COLUMN IF NOT EXISTS analysis_reasoning TEXT;

-- Image URL falls noch nicht vorhanden
ALTER TABLE plants ADD COLUMN IF NOT EXISTS image_url TEXT;