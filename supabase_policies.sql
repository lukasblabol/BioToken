-- BioToken Supabase Row Level Security (RLS) Policies
-- This file contains all security policies for the BioToken application

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PROJECTS TABLE POLICIES
-- =====================================================

-- Policy: Users can view all projects (public read access)
-- This includes both user-owned projects and public projects (owner_id = null)
CREATE POLICY "Anyone can view projects" ON projects
    FOR SELECT USING (true);

-- Policy: Users can insert their own projects
CREATE POLICY "Users can insert their own projects" ON projects
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

-- Policy: Allow inserting public projects (for sample data and community projects)
CREATE POLICY "Allow inserting public projects" ON projects
    FOR INSERT WITH CHECK (owner_id IS NULL);

-- Policy: Users can update their own projects
CREATE POLICY "Users can update their own projects" ON projects
    FOR UPDATE USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Policy: Users can delete their own projects
CREATE POLICY "Users can delete their own projects" ON projects
    FOR DELETE USING (auth.uid() = owner_id);

-- =====================================================
-- PLANTS TABLE POLICIES
-- =====================================================

-- Policy: Anyone can view plants (public read access)
CREATE POLICY "Anyone can view plants" ON plants
    FOR SELECT USING (true);

-- Policy: Users can insert plants to their own projects
CREATE POLICY "Users can insert plants to their own projects" ON plants
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = plants.project_id 
            AND projects.owner_id = auth.uid()
        )
    );

-- Policy: Allow inserting plants to public projects (for sample data)
CREATE POLICY "Allow inserting plants to public projects" ON plants
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = plants.project_id 
            AND projects.owner_id IS NULL
        )
    );

-- Policy: Users can update plants in their own projects
CREATE POLICY "Users can update plants in their own projects" ON plants
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = plants.project_id 
            AND projects.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = plants.project_id 
            AND projects.owner_id = auth.uid()
        )
    );

-- Policy: Users can delete plants from their own projects
CREATE POLICY "Users can delete plants from their own projects" ON plants
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = plants.project_id 
            AND projects.owner_id = auth.uid()
        )
    );

-- =====================================================
-- USER PROFILES TABLE POLICIES
-- =====================================================

-- Policy: Users can view all profiles (public read access)
CREATE POLICY "Anyone can view user profiles" ON user_profiles
    FOR SELECT USING (true);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert their own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update their own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Policy: Users can delete their own profile
CREATE POLICY "Users can delete their own profile" ON user_profiles
    FOR DELETE USING (auth.uid() = id);

-- =====================================================
-- FUNCTIONS FOR AUTOMATIC PROFILE CREATION
-- =====================================================

-- Function to automatically create user profile when auth user is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, display_name, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email),
        NOW(),
        NOW()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create profile for new users
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- STORAGE POLICIES (for plant images)
-- =====================================================

-- Create storage bucket for plant images if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('plant-images', 'plant-images', true)
ON CONFLICT (id) DO NOTHING;

-- Policy: Anyone can view plant images
CREATE POLICY "Anyone can view plant images" ON storage.objects
    FOR SELECT USING (bucket_id = 'plant-images');

-- Policy: Authenticated users can upload plant images
CREATE POLICY "Authenticated users can upload plant images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'plant-images' 
        AND auth.role() = 'authenticated'
    );

-- Policy: Users can update their own plant images
CREATE POLICY "Users can update their own plant images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'plant-images' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Policy: Users can delete their own plant images
CREATE POLICY "Users can delete their own plant images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'plant-images' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );