-- ============================================================================
-- BIOTOKEN SUPABASE COMPLETE SETUP (Updated for App Compatibility)
-- ============================================================================
-- Diese Datei enthält ALLE SQL-Commands zum kompletten Setup der BioToken-App
-- Kopiere und füge den gesamten Inhalt in den Supabase SQL-Editor ein

-- ============================================================================
-- 1. TABELLEN ERSTELLEN
-- ============================================================================

-- Users Tabelle (erweitert die auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects Tabelle (erweitert für App-Kompatibilität)
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    location_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    geometry JSONB,
    area DOUBLE PRECISION DEFAULT 0,
    biodiversity_rating INTEGER DEFAULT 0 CHECK (biodiversity_rating >= 0 AND biodiversity_rating <= 100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Plants Tabelle (erweitert für App-Kompatibilität)
CREATE TABLE IF NOT EXISTS public.plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    percentage DOUBLE PRECISION DEFAULT 0,
    biodiversity_rating INTEGER DEFAULT 0 CHECK (biodiversity_rating >= 0 AND biodiversity_rating <= 100),
    is_native BOOLEAN DEFAULT false,
    pollinator_value INTEGER DEFAULT 0,
    analysis_reasoning TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 2. INDIZES FÜR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON public.projects(owner_id);
CREATE INDEX IF NOT EXISTS idx_plants_project_id ON public.plants(project_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON public.projects(created_at);

-- ============================================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plants ENABLE ROW LEVEL SECURITY;

-- Users Policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Projects Policies
CREATE POLICY "Anyone can view projects" ON public.projects
    FOR SELECT USING (true);

CREATE POLICY "Users can create projects" ON public.projects
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own projects" ON public.projects
    FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete own projects" ON public.projects
    FOR DELETE USING (auth.uid() = owner_id);

-- Plants Policies
CREATE POLICY "Anyone can view plants" ON public.plants
    FOR SELECT USING (true);

CREATE POLICY "Users can create plants" ON public.plants
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.projects 
            WHERE id = project_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can update plants in own projects" ON public.plants
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.projects 
            WHERE id = project_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete plants in own projects" ON public.plants
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.projects 
            WHERE id = project_id AND owner_id = auth.uid()
        )
    );

-- ============================================================================
-- 4. FUNCTIONS & TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_projects
    BEFORE UPDATE ON public.projects
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_plants
    BEFORE UPDATE ON public.plants
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- 5. TEST USER ERSTELLEN
-- ============================================================================

-- Test-User wird automatisch erstellt wenn sich jemand mit test@biotoken.app registriert
-- Password: testpassword123

-- ============================================================================
-- 6. SAMPLE DATA (Optional)
-- ============================================================================

-- Sample Projekte mit Pflanzen (werden nur eingefügt wenn noch keine Projekte existieren)
DO $$
DECLARE
    test_user_id UUID;
    project1_id UUID := gen_random_uuid();
    project2_id UUID := gen_random_uuid();
    project3_id UUID := gen_random_uuid();
BEGIN
    -- Check if we have any projects already
    IF NOT EXISTS (SELECT 1 FROM public.projects LIMIT 1) THEN
        -- Create a test user first if auth allows
        INSERT INTO public.users (id, email, full_name)
        VALUES (gen_random_uuid(), 'demo@biotoken.app', 'Demo User')
        ON CONFLICT (email) DO NOTHING;
        
        SELECT id INTO test_user_id FROM public.users WHERE email = 'demo@biotoken.app' LIMIT 1;
        
        IF test_user_id IS NOT NULL THEN
            -- Insert sample projects
            INSERT INTO public.projects (id, title, description, owner_id, latitude, longitude, area, biodiversity_rating, geometry) VALUES
            (project1_id, 'Wildblumenwiese Tiergarten', 'Eine wunderschöne Wildblumenwiese im Herzen Berlins mit heimischen Pflanzen für Wildbienen', test_user_id, 52.5144, 13.3501, 2500.0, 85, '{"type":"Polygon","coordinates":[[[13.3490,52.5140],[13.3510,52.5140],[13.3510,52.5150],[13.3490,52.5150],[13.3490,52.5140]]]}'),
            (project2_id, 'Bestäuberparadies Mitte', 'Urbaner Lebensraum für Schmetterlinge und Bienen mit vielfältiger Pflanzenwelt', test_user_id, 52.5207, 13.4094, 1800.0, 78, '{"type":"Polygon","coordinates":[[[13.4084,52.5200],[13.4104,52.5200],[13.4104,52.5214],[13.4084,52.5214],[13.4084,52.5200]]]}'),
            (project3_id, 'Naturgarten Prenzlauer Berg', 'Nachhaltiger Garten mit regionalen Wildpflanzen und Kräutern für die lokale Tierwelt', test_user_id, 52.5482, 13.4205, 3200.0, 92, '{"type":"Polygon","coordinates":[[[13.4195,52.5475],[13.4215,52.5475],[13.4215,52.5489],[13.4195,52.5489],[13.4195,52.5475]]]}');
            
            -- Insert plants for project 1
            INSERT INTO public.plants (project_id, name, percentage, biodiversity_rating, is_native, image_url, pollinator_value, analysis_reasoning) VALUES
            (project1_id, 'Kornblume', 35.0, 8, true, 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=800&q=80', 9, 'Heimische Wildblume mit hohem Wert für Wildbienen und Schmetterlinge'),
            (project1_id, 'Wilde Malve', 25.0, 7, true, 'https://images.unsplash.com/photo-1595876924005-4b0b4b2e8b9e?auto=format&fit=crop&w=800&q=80', 8, 'Mehrjährige Staude mit langer Blütezeit, wichtig für Hummeln'),
            (project1_id, 'Gemeiner Natternkopf', 40.0, 9, true, 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=800&q=80', 10, 'Außergewöhnlich wertvoll für viele Wildbienenarten');
            
            -- Insert plants for project 2
            INSERT INTO public.plants (project_id, name, percentage, biodiversity_rating, is_native, image_url, pollinator_value, analysis_reasoning) VALUES
            (project2_id, 'Lavendel', 30.0, 6, false, 'https://images.unsplash.com/photo-1498654077810-12c21d4d6dc3?auto=format&fit=crop&w=800&q=80', 7, 'Mediterrane Pflanze, bei Bienen sehr beliebt'),
            (project2_id, 'Sonnenblume', 45.0, 8, false, 'https://images.unsplash.com/photo-1597848212624-e8d7fbd6b57c?auto=format&fit=crop&w=800&q=80', 9, 'Große Blüten bieten viel Nektar und Pollen'),
            (project2_id, 'Cosmeen', 25.0, 5, false, 'https://images.unsplash.com/photo-1576175018825-4f8c8a15e8d6?auto=format&fit=crop&w=800&q=80', 6, 'Bunte Sommerblumen mit moderatem Bestäuberwert');
            
            -- Insert plants for project 3
            INSERT INTO public.plants (project_id, name, percentage, biodiversity_rating, is_native, image_url, pollinator_value, analysis_reasoning) VALUES
            (project3_id, 'Wiesen-Salbei', 40.0, 9, true, 'https://images.unsplash.com/photo-1583844748377-3d9b8b5e7a6b?auto=format&fit=crop&w=800&q=80', 10, 'Heimischer Salbei mit hervorragendem Wert für Hummeln'),
            (project3_id, 'Echter Thymian', 35.0, 7, true, 'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?auto=format&fit=crop&w=800&q=80', 8, 'Aromatisches Kraut, wichtig für kleine Wildbienenarten'),
            (project3_id, 'Wilde Möhre', 25.0, 8, true, 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?auto=format&fit=crop&w=800&q=80', 9, 'Heimische Doldenblütler mit vielfältigem Insektenbesuch');
        END IF;
    END IF;
END $$;