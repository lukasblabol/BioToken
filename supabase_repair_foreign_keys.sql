-- =====================================================
-- SUPABASE FOREIGN KEYS REPARATUR SCRIPT
-- =====================================================
-- Dieses Script repariert die fehlenden Foreign Key Verknüpfungen
-- zwischen Projekten und Usern in der Supabase-Datenbank

-- =====================================================
-- 1. PRÜFE AKTUELLE TABELLEN-STRUKTUR
-- =====================================================

-- Zeige aktuelle Spalten der projects Tabelle
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'projects' 
ORDER BY ordinal_position;

-- =====================================================
-- 2. REPARIERE PROJECTS TABELLE
-- =====================================================

-- Ändere owner_id von TEXT zu UUID falls nötig
DO $$
BEGIN
    -- Prüfe ob owner_id als TEXT existiert
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' 
        AND column_name = 'owner_id' 
        AND data_type = 'text'
    ) THEN
        -- Entferne alte Foreign Key Constraint falls vorhanden
        ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_owner_id_fkey;
        
        -- Ändere Datentyp zu UUID
        ALTER TABLE projects ALTER COLUMN owner_id TYPE UUID USING owner_id::UUID;
        
        RAISE NOTICE 'owner_id Datentyp von TEXT zu UUID geändert';
    END IF;
    
    -- Füge Foreign Key Constraint hinzu
    ALTER TABLE projects 
    ADD CONSTRAINT projects_owner_id_fkey 
    FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE;
    
    RAISE NOTICE 'Foreign Key Constraint projects_owner_id_fkey hinzugefügt';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Fehler beim Reparieren der projects Tabelle: %', SQLERRM;
END;
$$;

-- =====================================================
-- 3. REPARIERE PLANTS TABELLE FOREIGN KEY
-- =====================================================

DO $$
BEGIN
    -- Entferne alte Foreign Key Constraint falls vorhanden
    ALTER TABLE plants DROP CONSTRAINT IF EXISTS plants_project_id_fkey;
    
    -- Füge korrekte Foreign Key Constraint hinzu
    ALTER TABLE plants 
    ADD CONSTRAINT plants_project_id_fkey 
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
    
    RAISE NOTICE 'Foreign Key Constraint plants_project_id_fkey hinzugefügt';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Fehler beim Reparieren der plants Tabelle: %', SQLERRM;
END;
$$;

-- =====================================================
-- 4. ERSTELLE FEHLENDE INDIZES
-- =====================================================

-- Index für bessere Performance bei owner_id Abfragen
CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON projects(owner_id);
CREATE INDEX IF NOT EXISTS idx_plants_project_id ON plants(project_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at);

-- =====================================================
-- 5. PRÜFE REPARATUR-ERGEBNIS
-- =====================================================

-- Zeige Foreign Key Constraints
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage ccu 
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_name IN ('projects', 'plants')
    AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, tc.constraint_name;

-- Zeige aktuelle Tabellen-Struktur
SELECT 
    t.table_name,
    c.column_name,
    c.data_type,
    c.is_nullable,
    CASE 
        WHEN tc.constraint_type = 'FOREIGN KEY' THEN 'FK -> ' || ccu.table_name || '(' || ccu.column_name || ')'
        WHEN tc.constraint_type = 'PRIMARY KEY' THEN 'PRIMARY KEY'
        ELSE ''
    END as constraint_info
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name
LEFT JOIN information_schema.key_column_usage kcu ON c.column_name = kcu.column_name AND c.table_name = kcu.table_name
LEFT JOIN information_schema.table_constraints tc ON kcu.constraint_name = tc.constraint_name
LEFT JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
WHERE t.table_name IN ('projects', 'plants', 'user_profiles')
    AND t.table_schema = 'public'
ORDER BY t.table_name, c.ordinal_position;

RAISE NOTICE '=== FOREIGN KEY REPARATUR ABGESCHLOSSEN ===';