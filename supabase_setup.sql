-- ============================================================================
-- BIOTOKEN SUPABASE COMPLETE SETUP
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

-- Projects Tabelle
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    location_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    geometry JSONB,
    biodiversity_rating INTEGER DEFAULT 0 CHECK (biodiversity_rating >= 0 AND biodiversity_rating <= 100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Plants Tabelle
CREATE TABLE IF NOT EXISTS public.plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    biodiversity_rating INTEGER DEFAULT 0 CHECK (biodiversity_rating >= 0 AND biodiversity_rating <= 100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 2. INDIZES FÜR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON public.projects(owner_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON public.projects(created_at);
CREATE INDEX IF NOT EXISTS idx_plants_project_id ON public.plants(project_id);
CREATE INDEX IF NOT EXISTS idx_plants_created_at ON public.plants(created_at);

-- ============================================================================
-- 3. ROW LEVEL SECURITY (RLS) AKTIVIEREN
-- ============================================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plants ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. SECURITY POLICIES
-- ============================================================================

-- Users Policies
DROP POLICY IF EXISTS "Users can read their own profile" ON public.users;
CREATE POLICY "Users can read their own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
CREATE POLICY "Users can insert their own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Projects Policies
DROP POLICY IF EXISTS "Anyone can read projects" ON public.projects;
CREATE POLICY "Anyone can read projects"
    ON public.projects FOR SELECT
    TO public
    USING (true);

DROP POLICY IF EXISTS "Authenticated users can create projects" ON public.projects;
CREATE POLICY "Authenticated users can create projects"
    ON public.projects FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can update their own projects" ON public.projects;
CREATE POLICY "Users can update their own projects"
    ON public.projects FOR UPDATE
    TO authenticated
    USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can delete their own projects" ON public.projects;
CREATE POLICY "Users can delete their own projects"
    ON public.projects FOR DELETE
    TO authenticated
    USING (auth.uid() = owner_id);

-- Plants Policies
DROP POLICY IF EXISTS "Anyone can read plants" ON public.plants;
CREATE POLICY "Anyone can read plants"
    ON public.plants FOR SELECT
    TO public
    USING (true);

DROP POLICY IF EXISTS "Project owners can manage plants" ON public.plants;
CREATE POLICY "Project owners can manage plants"
    ON public.plants FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.projects
            WHERE projects.id = plants.project_id
            AND projects.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.projects
            WHERE projects.id = plants.project_id
            AND projects.owner_id = auth.uid()
        )
    );

-- ============================================================================
-- 5. FUNKTIONEN FÜR AUTOMATISCHE TIMESTAMPS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers für automatische updated_at Felder
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_projects_updated_at ON public.projects;
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON public.projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_plants_updated_at ON public.plants;
CREATE TRIGGER update_plants_updated_at
    BEFORE UPDATE ON public.plants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. TEST-USER ERSTELLEN
-- ============================================================================

-- Erstelle einen Test-User (nur wenn er noch nicht existiert)
DO $$
DECLARE
    test_user_id UUID := 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
BEGIN
    -- Prüfe ob User bereits existiert
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = test_user_id) THEN
        -- Erstelle User in auth.users
        INSERT INTO auth.users (
            id, 
            email, 
            encrypted_password,
            email_confirmed_at,
            created_at, 
            updated_at,
            role
        ) VALUES (
            test_user_id,
            'test@biotoken.app',
            crypt('testpassword123', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            'authenticated'
        );
        
        -- Erstelle entsprechenden Eintrag in public.users
        INSERT INTO public.users (id, email, full_name) 
        VALUES (test_user_id, 'test@biotoken.app', 'Test User');
        
        RAISE NOTICE 'Test user created with email: test@biotoken.app and password: testpassword123';
    ELSE
        RAISE NOTICE 'Test user already exists';
    END IF;
END $$;

-- ============================================================================
-- 7. DEMO-PROJEKTE EINFÜGEN
-- ============================================================================

-- Berlin Biodiversität Projekte
INSERT INTO public.projects (
    id,
    title,
    description,
    owner_id,
    location_name,
    latitude,
    longitude,
    geometry,
    biodiversity_rating
) VALUES 
(
    'proj-1-berlin-tiergarten',
    'Tiergarten Biodiversität',
    'Erfassung der Pflanzenvielfalt im Berliner Tiergarten. Ein umfassendes Projekt zur Dokumentation der urbanen Biodiversität.',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Tiergarten, Berlin',
    52.5145,
    13.3501,
    '{"type": "Point", "coordinates": [13.3501, 52.5145]}',
    85
),
(
    'proj-2-berlin-tempelhofer',
    'Tempelhofer Feld Ökosystem',
    'Monitoring der natürlichen Entwicklung auf dem ehemaligen Flughafen. Fokus auf Spontanvegetation und Sukzession.',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Tempelhofer Feld, Berlin',
    52.4732,
    13.4041,
    '{"type": "Point", "coordinates": [13.4041, 52.4732]}',
    92
),
(
    'proj-3-berlin-volkspark',
    'Volkspark Friedrichshain Flora',
    'Kartierung seltener Pflanzenarten im historischen Volkspark. Schwerpunkt auf einheimische und gefährdete Arten.',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Volkspark Friedrichshain, Berlin',
    52.5263,
    13.4317,
    '{"type": "Point", "coordinates": [13.4317, 52.5263]}',
    78
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 8. DEMO-PFLANZEN EINFÜGEN
-- ============================================================================

-- Pflanzen für Tiergarten Projekt
INSERT INTO public.plants (
    project_id,
    name,
    description,
    image_url,
    biodiversity_rating
) VALUES 
(
    'proj-1-berlin-tiergarten',
    'Rotbuche (Fagus sylvatica)',
    'Majestätischer Laubbaum mit charakteristischen ovalen Blättern. Wichtiger Lebensraum für viele Insekten und Vögel.',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
    88
),
(
    'proj-1-berlin-tiergarten',
    'Waldmeister (Galium odoratum)',
    'Bodendecker mit weißen Blüten und charakteristischem Duft. Indikator für nährstoffreiche Böden.',
    'https://images.unsplash.com/photo-1516205651411-aef33a44f7c2?w=400',
    75
),
(
    'proj-1-berlin-tiergarten',
    'Eiche (Quercus robur)',
    'Jahrhundertealte Stieleiche, Habitat für über 500 Insektenarten. Einer der wertvollsten Bäume für die Biodiversität.',
    'https://images.unsplash.com/photo-1574263867128-aa3e3a52215c?w=400',
    95
);

-- Pflanzen für Tempelhofer Feld Projekt
INSERT INTO public.plants (
    project_id,
    name,
    description,
    image_url,
    biodiversity_rating
) VALUES 
(
    'proj-2-berlin-tempelhofer',
    'Wilde Möhre (Daucus carota)',
    'Pionierart auf trockenen Standorten. Wichtige Nahrungsquelle für Schmetterlinge und andere Bestäuber.',
    'https://images.unsplash.com/photo-1627728187858-43aa8c7a2b16?w=400',
    82
),
(
    'proj-2-berlin-tempelhofer',
    'Sandmohn (Papaver argemone)',
    'Seltene einjährige Art auf sandigen Böden. Charakteristisch für Ruderalstandorte.',
    'https://images.unsplash.com/photo-1463320726281-696a485928c7?w=400',
    90
),
(
    'proj-2-berlin-tempelhofer',
    'Echtes Labkraut (Galium verum)',
    'Gelb blühende Staude, wichtig für Wildbienen. Zeigt magere, trockene Standorte an.',
    'https://images.unsplash.com/photo-1506142635592-a8f9e186de92?w=400',
    78
);

-- Pflanzen für Volkspark Projekt  
INSERT INTO public.plants (
    project_id,
    name,
    description,
    image_url,
    biodiversity_rating
) VALUES 
(
    'proj-3-berlin-volkspark',
    'Buschwindröschen (Anemone nemorosa)',
    'Frühlingsblüher der Laubwälder. Zeigt alte, ungestörte Waldstandorte an.',
    'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400',
    85
),
(
    'proj-3-berlin-volkspark',
    'Große Brennnessel (Urtica dioica)',
    'Nährstoffzeiger und wichtige Futterpflanze für Schmetterlingsraupen.',
    'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=400',
    72
),
(
    'proj-3-berlin-volkspark',
    'Gundermann (Glechoma hederacea)',
    'Kriechender Lippenblütler mit violetten Blüten. Wichtige Frühjahrsnahrung für Bienen.',
    'https://images.unsplash.com/photo-1469028961848-8e8d4a5fa2bf?w=400',
    80
);

-- ============================================================================
-- 9. BERECHTIGUNGEN SETZEN
-- ============================================================================

-- Stelle sicher, dass die Tabellen für authenticated und anon users zugänglich sind
GRANT SELECT ON public.users TO anon, authenticated;
GRANT ALL ON public.users TO authenticated;

GRANT SELECT ON public.projects TO anon, authenticated;
GRANT ALL ON public.projects TO authenticated;

GRANT SELECT ON public.plants TO anon, authenticated;
GRANT ALL ON public.plants TO authenticated;

-- Stelle sicher, dass Sequenzen verwendet werden können
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- ============================================================================
-- SETUP ABGESCHLOSSEN
-- ============================================================================

-- Zeige Zusammenfassung
DO $$
BEGIN
    RAISE NOTICE '✅ BioToken Supabase Setup abgeschlossen!';
    RAISE NOTICE '📊 % Projekte erstellt', (SELECT COUNT(*) FROM public.projects);
    RAISE NOTICE '🌱 % Pflanzen erstellt', (SELECT COUNT(*) FROM public.plants);
    RAISE NOTICE '👤 Test-Login: test@biotoken.app / testpassword123';
END $$;