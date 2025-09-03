-- ============================================================================
-- BIOTOKEN QUICK SETUP - NUR DIE WICHTIGSTEN SCHRITTE
-- ============================================================================
-- Falls du nur die essentiellen Tabellen brauchst, verwende dieses Script

-- Tabellen erstellen
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    owner_id UUID,
    location_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    geometry JSONB,
    biodiversity_rating INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    biodiversity_rating INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS aktivieren aber alle können lesen
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read projects" ON public.projects FOR SELECT TO public USING (true);
CREATE POLICY "Anyone can read plants" ON public.plants FOR SELECT TO public USING (true);

-- Ein Test-Projekt einfügen
INSERT INTO public.projects (
    title, description, location_name, latitude, longitude, 
    geometry, biodiversity_rating
) VALUES (
    'Berlin Test Projekt',
    'Test-Projekt für die App-Entwicklung',
    'Berlin, Deutschland',
    52.5200,
    13.4050,
    '{"type": "Point", "coordinates": [13.4050, 52.5200]}',
    80
) ON CONFLICT DO NOTHING;