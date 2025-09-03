# Supabase Data Display Fix

## Problem
After redeploying the Supabase schema with Row Level Security (RLS), the sample projects were not displaying because:

1. **Sample projects were created with `owner_id = null`** (public/community projects)
2. **RLS policies only allowed access to user-owned projects** (where `auth.uid() = owner_id`)
3. **No policy existed to allow insertion of public projects**

## Solution Applied

### 1. Updated RLS Policies (`supabase_policies.sql`)

#### Projects Table:
- ✅ **Added policy for inserting public projects:**
```sql
CREATE POLICY "Allow inserting public projects" ON projects
    FOR INSERT WITH CHECK (owner_id IS NULL);
```

#### Plants Table:
- ✅ **Added policy for inserting plants to public projects:**
```sql
CREATE POLICY "Allow inserting plants to public projects" ON plants
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = plants.project_id 
            AND projects.owner_id IS NULL
        )
    );
```

### 2. Improved Sample Data Service (`sample_data_service.dart`)
- ✅ **Added better logging** for project and plant insertion
- ✅ **Added `.select()` calls** to verify successful insertions
- ✅ **Enhanced error handling** with detailed debug output

### 3. Force Recreate Sample Data (`main.dart`)
- ✅ **Changed `forceRecreate: false` to `forceRecreate: true`** to regenerate sample data after schema changes

## To Apply These Changes in Supabase Dashboard:

1. **Run the updated SQL policies** in your Supabase SQL editor
2. **Delete existing sample data** (if any) that might have wrong permissions
3. **Restart the Flutter app** to trigger sample data recreation

## Verification Steps:

1. Check Supabase logs for sample project creation
2. Verify projects table has entries with `owner_id = null`
3. Verify plants table has corresponding entries
4. Confirm project list and map screens display data

## Result
- ✅ **Public projects (sample data) can now be inserted** without authentication
- ✅ **All users can view public projects** (owner_id = null)
- ✅ **Authenticated users can still manage their own projects**
- ✅ **Sample data will be recreated** on next app startup