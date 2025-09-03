# BioToken Mobile-First Web App Architecture

## Overview
A minimalistic, mobile-optimized web app for biotoken.com featuring interactive maps, project management, and plant tracking with clean Material 3 design.

## Core Features
1. **User Authentication** - Simple login/register with email/password
2. **Interactive Map** - Full-screen map showing project areas as markers/polygons
3. **Project Management** - Create, view, and edit biodiversity projects
4. **Plant Database** - Add plants with types, percentages, and images
5. **Local Storage** - Persistent project storage without external dependencies

## Technical Stack
- **Frontend**: Flutter (mobile-first responsive)
- **Storage**: SharedPreferences for local data persistence
- **Maps**: flutter_map with OpenStreetMap tiles
- **Images**: image_picker for plant photos

## File Structure (8 files)
1. `main.dart` - App entry point and routing
2. `theme.dart` - Material 3 theme with green nature colors
3. `models/project.dart` - Data models for projects and plants
4. `services/auth_service.dart` - Simple local authentication
5. `services/storage_service.dart` - Local data persistence
6. `screens/login_screen.dart` - Minimal login interface
7. `screens/home_screen.dart` - Map view with bottom navigation
8. `screens/project_detail_screen.dart` - Slide-up panel for project details

## Design Principles
- **Mobile-First**: Touch-friendly large elements, thumb-zone navigation
- **Minimalism**: White backgrounds, subtle shadows, icon-based navigation
- **Color Palette**: White, light grey (#F8F9F8), green accent (#2D5A27)
- **Typography**: Inter font family for clean readability
- **Navigation**: Bottom tab bar with 3 icons (Map, Add, Account)

## Data Models
- **Project**: id, name, coordinates, plants[], color, createdAt
- **Plant**: id, name, type (tree/shrub/herb), percentage, imageUrl
- **User**: email, password (hashed), projects[]

## Key Components
- **MapView**: Interactive flutter_map with project overlays
- **ProjectMarker**: Colored polygon/marker for each project area
- **PlantCard**: Visual card showing plant info with progress ring
- **SlideUpPanel**: Bottom sheet for project details
- **FAB**: Floating action button for new project creation

## Implementation Steps
1. Set up authentication service and login screen
2. Create data models and storage service
3. Build main map screen with flutter_map
4. Implement project creation with polygon drawing
5. Add plant management with image picker
6. Create project detail slide-up panel
7. Add bottom navigation between screens
8. Polish animations and responsive design