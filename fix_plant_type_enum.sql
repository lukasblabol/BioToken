-- Fix plant_type ENUM to include all values the Flutter app uses
-- This recreates the ENUM with all necessary values

-- First drop the existing type (this will cascade to the table)
DROP TYPE IF EXISTS plant_type CASCADE;

-- Recreate the plants table without the ENUM first
DROP TABLE IF EXISTS plants;

-- Recreate the ENUM with all values
CREATE TYPE plant_type AS ENUM ('tree', 'shrub', 'perennial', 'flower', 'grass', 'fern', 'moss');

-- Recreate the plants table with the fixed ENUM
CREATE TABLE plants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type plant_type NOT NULL,
    image_url TEXT,
    area_percentage DECIMAL(5,2) DEFAULT 0,
    analysis_reasoning TEXT,
    biodiversity_rating INTEGER DEFAULT 0,
    pollinator_value INTEGER DEFAULT 0,
    is_native BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;

-- Create policies for plants table
CREATE POLICY "Users can view their own plants" ON plants
    FOR SELECT USING (project_id IN (
        SELECT id FROM projects WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Users can insert plants to their projects" ON plants
    FOR INSERT WITH CHECK (project_id IN (
        SELECT id FROM projects WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Users can update their own plants" ON plants
    FOR UPDATE USING (project_id IN (
        SELECT id FROM projects WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Users can delete their own plants" ON plants
    FOR DELETE USING (project_id IN (
        SELECT id FROM projects WHERE owner_id = auth.uid()
    ));

-- Create indexes for better performance
CREATE INDEX idx_plants_project_id ON plants(project_id);
CREATE INDEX idx_plants_type ON plants(type);
CREATE INDEX idx_plants_biodiversity_rating ON plants(biodiversity_rating);
CREATE INDEX idx_plants_pollinator_value ON plants(pollinator_value);