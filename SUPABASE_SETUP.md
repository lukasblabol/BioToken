# BioToken Supabase Setup Guide

## 🚀 Datenbankstruktur einrichten

### 1. Schema erstellen
Führen Sie die folgenden SQL-Dateien in Ihrer Supabase-Instanz aus:

1. **Zuerst**: `supabase_schema.sql` - Erstellt die komplette Datenbankstruktur
2. **Danach**: `supabase_policies.sql` - Richtet die Sicherheitsrichtlinien ein

### 2. Wichtige Tabellen-Beziehungen

```
auth.users (Supabase Auth)
    ↓ (owner_id foreign key)
projects
    ↓ (project_id foreign key) 
plants
```

### 3. Tabellen-Übersicht

#### `projects` Tabelle
- `id` (UUID, Primary Key)
- `owner_id` (UUID, Foreign Key zu `auth.users.id`)
- `title` (TEXT)
- `description` (TEXT)
- `geometry` (JSONB) - Speichert Polygon-Koordinaten
- `area` (NUMERIC) - Fläche in Quadratmetern
- `created_at`, `updated_at` (TIMESTAMPTZ)

#### `plants` Tabelle
- `id` (UUID, Primary Key)
- `project_id` (UUID, Foreign Key zu `projects.id`)
- `name` (TEXT)
- `percentage` (NUMERIC) - Abdeckung in Prozent
- `image_url` (TEXT)
- `analysis_reasoning` (TEXT) - KI-Analyse
- `biodiversity_rating` (INT4, 1-5)
- `pollinator_value` (INT4, 1-5)
- `is_native` (BOOLEAN)
- `created_at`, `updated_at` (TIMESTAMPTZ)

#### `user_profiles` Tabelle (Optional)
- `id` (UUID, Foreign Key zu `auth.users.id`)
- `display_name` (TEXT)
- `bio` (TEXT)
- `avatar_url` (TEXT)
- `preferred_units` (TEXT)

### 4. Row Level Security (RLS)

Die Sicherheitsrichtlinien stellen sicher, dass:

- **Projekte**: Alle können lesen, nur Eigentümer können ihre Projekte erstellen/bearbeiten/löschen
- **Pflanzen**: Alle können lesen, nur Projekteigentümer können Pflanzen ihrer Projekte verwalten
- **Profile**: Alle können lesen, nur Eigentümer können ihr Profil bearbeiten

### 5. Storage für Pflanzenbilder

Ein `plant-images` Bucket wird automatisch erstellt mit:
- Öffentlicher Lesezugriff für alle Bilder
- Authenticated users können Bilder hochladen
- Users können nur ihre eigenen Bilder verwalten

## 🔄 Migration von altem Schema

Falls Sie bereits Daten haben:

1. **Backup erstellen**: Exportieren Sie Ihre bestehenden Daten
2. **Schema ausführen**: Führen Sie `supabase_schema.sql` aus
3. **Policies einrichten**: Führen Sie `supabase_policies.sql` aus
4. **Daten migrieren**: 
   - Stellen Sie sicher, dass `projects.owner_id` auf gültige `auth.users.id` verweist
   - Überprüfen Sie Foreign Key Beziehungen zwischen `plants.project_id` und `projects.id`

## 🔧 Flutter App Konfiguration

### 1. Service aktualisieren

Ersetzen Sie den aktuellen `BioTokenSupabaseService` mit der neuen Version:

```dart
// In lib/services/biotoken_supabase_service.dart
// Verwenden Sie die neue biotoken_supabase_service_fixed.dart
```

### 2. Authentifizierung

Der Service funktioniert sowohl mit als auch ohne Authentifizierung:
- **Ohne Auth**: Zeigt alle Projekte (nur lesen)
- **Mit Auth**: Zeigt alle Projekte + kann eigene Projekte erstellen/bearbeiten

### 3. Fehlerbehandlung

Der neue Service hat verbesserte Fehlerbehandlung:
- Automatische Timeouts für alle Datenbankoperationen
- Graceful fallbacks bei Netzwerkproblemen
- Detailliertes Logging für Debugging

## 🎯 Vorteile der neuen Struktur

1. **Echte User-Verknüpfung**: Projekte sind korrekt mit Supabase Auth Users verknüpft
2. **Bessere Performance**: Optimierte Abfragen vermeiden N+1 Probleme
3. **Sicherheit**: Row Level Security schützt Benutzerdaten
4. **Skalierbarkeit**: Proper Foreign Keys und Indizes
5. **Flexibility**: Unterstützt sowohl öffentliche als auch private Projekte

## 🔍 Troubleshooting

### Häufige Probleme:

1. **"Foreign key constraint fails"**
   - Stellen Sie sicher, dass `owner_id` auf existierende `auth.users.id` verweist

2. **"RLS policy violation"** 
   - Überprüfen Sie, ob der User authentifiziert ist für schreibende Operationen

3. **"plants not loading"**
   - Kontrollieren Sie, ob `project_id` in plants table korrekt gesetzt ist

4. **Langsame Abfragen**
   - Indizes sollten automatisch erstellt werden durch das Schema

### Debug-Modus aktivieren:

In der Flutter App sind ausführliche Logs aktiviert:
```dart
// Schauen Sie in die Debug-Konsole für:
// 📊 [BioTokenService] ... - Normale Operationen  
// ❌ [BioTokenService] ... - Fehler
// ✅ [BioTokenService] ... - Erfolg
```