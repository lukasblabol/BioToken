-- ============================================================================
-- ECHTE DATEN FÜR BIOTOKEN HINZUFÜGEN
-- ============================================================================
-- Diese SQL-Datei fügt echte Projektdaten mit Pflanzen hinzu
-- Führe sie in deinem Supabase SQL-Editor aus

-- ============================================================================
-- 1. PRÜFE AKTUELLE DATEN
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Aktuelle Anzahl Projekte: %', (SELECT COUNT(*) FROM public.projects);
    RAISE NOTICE 'Aktuelle Anzahl Pflanzen: %', (SELECT COUNT(*) FROM public.plants);
END $$;

-- ============================================================================
-- 2. FÜGE ECHTE PROJEKTE HINZU
-- ============================================================================

-- Berlin Tiergarten Biodiversitätsprojekt
INSERT INTO public.projects (
    id,
    title,
    description,
    owner_id,
    owner_email,
    location_name,
    latitude,
    longitude,
    geometry,
    biodiversity_rating,
    area,
    created_at,
    updated_at
) VALUES (
    'proj-1-berlin-tiergarten',
    'Tiergarten Biodiversitätsprojekt',
    'Umfassendes Projekt zur Erfassung und Förderung der Pflanzenvielfalt im Berliner Tiergarten. Fokus auf einheimische Arten und Bestäuber-freundliche Vegetation.',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'tiergarten@biotoken.app',
    'Tiergarten, Berlin',
    52.5145,
    13.3501,
    '{"type": "Polygon", "coordinates": [[[13.3490, 52.5140], [13.3512, 52.5140], [13.3512, 52.5150], [13.3490, 52.5150], [13.3490, 52.5140]]]}',
    85,
    2200.0,
    NOW() - INTERVAL '20 days',
    NOW() - INTERVAL '2 days'
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Tempelhofer Feld Ökosystem
INSERT INTO public.projects (
    id,
    title,
    description,
    owner_id,
    owner_email,
    location_name,
    latitude,
    longitude,
    geometry,
    biodiversity_rating,
    area,
    created_at,
    updated_at
) VALUES (
    'proj-2-berlin-tempelhofer',
    'Tempelhofer Feld Sukzessionsprojekt',
    'Langzeitstudie der natürlichen Pflanzenentwicklung auf dem ehemaligen Flughafen. Monitoring von Pionierarten und Sukzessionsprozessen in urbaner Umgebung.',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'tempelhofer@biotoken.app',
    'Tempelhofer Feld, Berlin',
    52.4732,
    13.4041,
    '{"type": "Polygon", "coordinates": [[[13.4020, 52.4720], [13.4062, 52.4720], [13.4062, 52.4744], [13.4020, 52.4744], [13.4020, 52.4720]]]}',
    92,
    8500.0,
    NOW() - INTERVAL '12 days',
    NOW() - INTERVAL '1 day'
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Volkspark Friedrichshain Flora
INSERT INTO public.projects (
    id,
    title,
    description,
    owner_id,
    owner_email,
    location_name,
    latitude,
    longitude,
    geometry,
    biodiversity_rating,
    area,
    created_at,
    updated_at
) VALUES (
    'proj-3-berlin-volkspark',
    'Volkspark Friedrichshain Flora-Kartierung',
    'Detaillierte Erfassung seltener und gefährdeter Pflanzenarten im historischen Volkspark. Schwerpunkt auf Erhaltung der ursprünglichen Parkvegetation.',
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'volkspark@biotoken.app',
    'Volkspark Friedrichshain, Berlin',
    52.5263,
    13.4317,
    '{"type": "Polygon", "coordinates": [[[13.4300, 52.5250], [13.4334, 52.5250], [13.4334, 52.5276], [13.4300, 52.5276], [13.4300, 52.5250]]]}',
    78,
    1800.0,
    NOW() - INTERVAL '5 days',
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    updated_at = NOW();

-- ============================================================================
-- 3. FÜGE PFLANZEN HINZU
-- ============================================================================

-- Pflanzen für Tiergarten Projekt
INSERT INTO public.plants (
    id,
    project_id,
    name,
    description,
    image_url,
    biodiversity_rating,
    percentage,
    is_native,
    pollinator_value,
    analysis_reasoning,
    created_at,
    updated_at
) VALUES 
(
    'plant-tiergarten-1',
    'proj-1-berlin-tiergarten',
    'Rotbuche (Fagus sylvatica)',
    'Majestätischer Laubbaum mit charakteristischen ovalen Blättern. Wichtiger Lebensraum für viele Insekten und Vögel.',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
    5,
    40.0,
    true,
    'High',
    'Rotbuchen sind Keystone-Arten in mitteleuropäischen Wäldern. Sie bieten Lebensraum für über 100 Insektenarten und ihre Früchte sind wichtige Nahrungsquelle für Vögel und Säugetiere.',
    NOW() - INTERVAL '18 days',
    NOW() - INTERVAL '2 days'
),
(
    'plant-tiergarten-2',
    'proj-1-berlin-tiergarten',
    'Waldmeister (Galium odoratum)',
    'Bodendecker mit weißen Blüten und charakteristischem Duft. Indikator für nährstoffreiche Böden.',
    'https://images.unsplash.com/photo-1516205651411-aef33a44f7c2?w=400',
    4,
    35.0,
    true,
    'Medium',
    'Waldmeister ist ein wichtiger Frühjahrsblüher für erste Bestäuber und zeigt intakte Waldökosysteme an. Seine Blüten sind besonders wertvoll für kleine Wildbienenarten.',
    NOW() - INTERVAL '18 days',
    NOW() - INTERVAL '2 days'
),
(
    'plant-tiergarten-3',
    'proj-1-berlin-tiergarten',
    'Stieleiche (Quercus robur)',
    'Jahrhundertealte Eiche, Habitat für über 500 Insektenarten. Einer der wertvollsten Bäume für die Biodiversität.',
    'https://images.unsplash.com/photo-1574263867128-aa3e3a52215c?w=400',
    6,
    25.0,
    true,
    'High',
    'Stieleichen sind die biodiversitätsreichsten Bäume Europas. Sie beherbergen über 500 Insektenarten und sind essentiell für das Ökosystem Wald.',
    NOW() - INTERVAL '18 days',
    NOW() - INTERVAL '2 days'
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Pflanzen für Tempelhofer Feld Projekt
INSERT INTO public.plants (
    id,
    project_id,
    name,
    description,
    image_url,
    biodiversity_rating,
    percentage,
    is_native,
    pollinator_value,
    analysis_reasoning,
    created_at,
    updated_at
) VALUES 
(
    'plant-tempelhofer-1',
    'proj-2-berlin-tempelhofer',
    'Wilde Möhre (Daucus carota)',
    'Pionierart auf trockenen Standorten. Wichtige Nahrungsquelle für Schmetterlinge und andere Bestäuber.',
    'https://images.unsplash.com/photo-1627728187858-43aa8c7a2b16?w=400',
    5,
    45.0,
    true,
    'High',
    'Wilde Möhre ist eine Schlüsselart für Ruderalstandorte. Ihre Doldenblüten sind extrem wertvoll für über 30 Wildbienenarten und zahlreiche Schmetterlinge.',
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '1 day'
),
(
    'plant-tempelhofer-2',
    'proj-2-berlin-tempelhofer',
    'Sandmohn (Papaver argemone)',
    'Seltene einjährige Art auf sandigen Böden. Charakteristisch für Ruderalstandorte und in Berlin gefährdet.',
    'https://images.unsplash.com/photo-1463320726281-696a485928c7?w=400',
    6,
    30.0,
    true,
    'Medium',
    'Sandmohn ist eine gefährdete Art der Roten Liste. Als Charakterart sandiger Ruderalfluren ist er besonders schützenswert und zeigt intakte Sukzession an.',
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '1 day'
),
(
    'plant-tempelhofer-3',
    'proj-2-berlin-tempelhofer',
    'Echtes Labkraut (Galium verum)',
    'Gelb blühende Staude, wichtig für Wildbienen. Zeigt magere, trockene Standorte an.',
    'https://images.unsplash.com/photo-1506142635592-a8f9e186de92?w=400',
    4,
    25.0,
    true,
    'High',
    'Echtes Labkraut ist ein wichtiger Indikator für Magerrasen und bietet Nektar für spezialisierte Wildbienenarten. Besonders wertvoll für die Lange Schmalbiene.',
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '1 day'
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Pflanzen für Volkspark Projekt  
INSERT INTO public.plants (
    id,
    project_id,
    name,
    description,
    image_url,
    biodiversity_rating,
    percentage,
    is_native,
    pollinator_value,
    analysis_reasoning,
    created_at,
    updated_at
) VALUES 
(
    'plant-volkspark-1',
    'proj-3-berlin-volkspark',
    'Buschwindröschen (Anemone nemorosa)',
    'Frühlingsblüher der Laubwälder. Zeigt alte, ungestörte Waldstandorte an.',
    'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400',
    5,
    40.0,
    true,
    'Medium',
    'Buschwindröschen ist ein wichtiger Frühjahrsgeophyt und Zeiger für alte Waldstandorte. Besonders wertvoll für frühe Bestäuber wie Sandbienen.',
    NOW() - INTERVAL '3 days',
    NOW()
),
(
    'plant-volkspark-2',
    'proj-3-berlin-volkspark',
    'Große Brennnessel (Urtica dioica)',
    'Nährstoffzeiger und wichtige Futterpflanze für Schmetterlingsraupen.',
    'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=400',
    3,
    35.0,
    true,
    'Low',
    'Brennnesseln sind essential für viele Schmetterlingsarten als Raupenfutter. Über 40 Schmetterlingsarten sind auf sie angewiesen, darunter Tagpfauenauge und Kleiner Fuchs.',
    NOW() - INTERVAL '3 days',
    NOW()
),
(
    'plant-volkspark-3',
    'proj-3-berlin-volkspark',
    'Gundermann (Glechoma hederacea)',
    'Kriechender Lippenblütler mit violetten Blüten. Wichtige Frühjahrsnahrung für Bienen.',
    'https://images.unsplash.com/photo-1469028961848-8e8d4a5fa2bf?w=400',
    4,
    25.0,
    true,
    'High',
    'Gundermann ist ein wichtiger Frühjahrsblüher mit hohem Nektarwert. Besonders geschätzt von Hummeln und Wildbienenarten, die früh im Jahr aktiv sind.',
    NOW() - INTERVAL '3 days',
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = NOW();

-- ============================================================================
-- 4. PRÜFE ENDERGEBNIS
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Finale Anzahl Projekte: %', (SELECT COUNT(*) FROM public.projects);
    RAISE NOTICE '✅ Finale Anzahl Pflanzen: %', (SELECT COUNT(*) FROM public.plants);
    RAISE NOTICE '🌱 Projekte mit Pflanzen: %', (
        SELECT COUNT(DISTINCT project_id) FROM public.plants
    );
END $$;

-- Zeige Übersicht der Projekte mit Pflanzenanzahl
SELECT 
    p.title,
    p.location_name,
    COUNT(pl.id) as plant_count,
    ROUND(AVG(pl.biodiversity_rating), 1) as avg_biodiversity,
    p.created_at::date as created_date
FROM public.projects p
LEFT JOIN public.plants pl ON p.id = pl.project_id
GROUP BY p.id, p.title, p.location_name, p.created_at
ORDER BY p.created_at DESC;

RAISE NOTICE '🎉 Echte Daten erfolgreich hinzugefügt!';