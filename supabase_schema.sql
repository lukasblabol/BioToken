-- BioToken Supabase Database Schema
-- This file contains the complete database structure for the BioToken application

-- =====================================================
-- PROJECTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Owner reference to Supabase Auth users
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Project basic information
    title TEXT NOT NULL,
    description TEXT,
    
    -- Geographic data
    geometry JSONB NOT NULL, -- Store polygon coordinates as JSONB
    area NUMERIC(10,2), -- Area in square meters
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON projects(owner_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at);

-- =====================================================
-- PLANTS TABLE  
-- =====================================================
CREATE TABLE IF NOT EXISTS plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Foreign key to projects
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
    
    -- Plant information
    name TEXT NOT NULL,
    percentage NUMERIC(5,2) DEFAULT 0.0, -- Percentage coverage
    
    -- Optional plant metadata
    image_url TEXT,
    
    -- AI Analysis results (optional)
    analysis_reasoning TEXT,
    biodiversity_rating INT4 CHECK (biodiversity_rating >= 1 AND biodiversity_rating <= 5),
    pollinator_value INT4 CHECK (pollinator_value >= 1 AND pollinator_value <= 5),
    is_native BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_plants_project_id ON plants(project_id);
CREATE INDEX IF NOT EXISTS idx_plants_name ON plants(name);

-- =====================================================
-- USERS TABLE (Extended user profile)
-- =====================================================
-- Note: We don't create a separate users table since Supabase Auth handles this
-- We can add a user_profiles table if needed for additional user data

CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Additional user information
    display_name TEXT,
    bio TEXT,
    avatar_url TEXT,
    
    -- User preferences
    preferred_units TEXT DEFAULT 'metric', -- 'metric' or 'imperial'
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_projects_updated_at 
    BEFORE UPDATE ON projects 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plants_updated_at 
    BEFORE UPDATE ON plants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SAMPLE DATA (Optional - for development)
-- =====================================================

-- Create a sample user profile when needed
-- This would typically be handled by your application code

-- Note: Sample projects and plants should be created through your Flutter app
-- using the SampleDataService to ensure proper authentication and data consistency