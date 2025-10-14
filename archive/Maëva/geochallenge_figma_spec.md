# GeoChallenge Tracker - Spécification Figma AI Complète

## 🎯 Guide d'utilisation avec Figma AI

### Méthode recommandée
1. **Utiliser First Draft (Figma AI)** - Fonction native dans Actions > First Draft
2. **Utiliser les prompts optimisés** ci-dessous pour chaque page
3. **Compléter avec les interactions** via le nouveau système d'auto-wiring
4. **Affiner avec les spécifications détaillées** fournies

---

## 📱 Structure de l'application

### Pages principales
1. **Dashboard** (page d'accueil)
2. **Mes Challenges** (liste et gestion)
3. **Créer un Challenge** (formulaire)
4. **Détail Challenge** (suivi individuel)
5. **Import GPX** (upload et traitement)
6. **Carte Interactive** (visualisation OpenStreetMap)
7. **Statistiques** (analytics et projections)
8. **Profil Utilisateur** (paramètres)

---

## 🤖 Prompts Figma AI optimisés

### 1. Dashboard - Prompt First Draft
```
Design a modern dashboard for a geocaching challenge tracking app called "GeoChallenge Tracker". Include:
- Header with logo, search bar, and profile avatar
- Welcome section with user stats (challenges active, completed, total caches found)
- Grid of active challenges cards with progress bars
- Quick action buttons for "New Challenge", "Import GPX", "View Map"
- Recent activity feed on the right sidebar
- Clean, modern design with outdoor/adventure theme
- Use green and blue color scheme
- Mobile-first responsive layout
```

### 2. Mes Challenges - Prompt First Draft
```
Design a challenge management page for geocaching app. Include:
- Page header with "Mes Challenges" title and filter/sort options
- Challenge cards in a grid layout showing:
  - Challenge name and description
  - Progress bar with completion percentage
  - Target number vs current count
  - Map thumbnail
  - Edit/Delete action buttons
- Floating action button to create new challenge
- Empty state illustration for when no challenges exist
- Search and filter bar at the top
- Pagination at bottom
- Use green accent color and clean modern UI
```

### 3. Créer un Challenge - Prompt First Draft
```
Design a multi-step form for creating a geocaching challenge. Include:
- Step indicator (1/3, 2/3, 3/3)
- Form fields for:
  - Challenge name (text input)
  - Description (textarea)
  - Challenge type (dropdown: distance, difficulty, theme, etc.)
  - Target number (number input)
  - Geographic zone (map picker)
  - Difficulty range (slider)
  - Time limit (date picker)
- Map integration for zone selection
- Progress save indicator
- Back/Next/Save buttons
- Modern form design with validation states
- Green primary buttons
```

### 4. Détail Challenge - Prompt First Draft
```
Design a detailed challenge tracking page showing:
- Challenge header with name, progress bar, and stats
- Interactive map showing found vs remaining geocaches
- List view toggle showing cache details (name, difficulty, date found)
- Progress visualization chart
- Achievement badges/milestones
- Share challenge button
- Edit challenge settings
- Activity timeline
- Projection estimate for completion
- Export progress option
- Responsive layout with map taking 60% width on desktop
```

### 5. Import GPX - Prompt First Draft
```
Design a GPX file import interface including:
- Drag and drop upload zone with file icon
- File browse button alternative
- Upload progress indicator
- File validation feedback
- Preview of imported data (number of caches, date range)
- Map preview showing imported points
- Import options (merge with existing, replace, new dataset)
- Import history list
- Error handling states
- Success confirmation with import summary
- Clean, user-friendly upload experience
```

### 6. Carte Interactive - Prompt First Draft
```
Design a full-screen interactive map interface for geocaching:
- OpenStreetMap integration placeholder
- Map controls (zoom, layers, fullscreen)
- Legend showing different cache types and statuses
- Filter panel on left side (difficulty, terrain, size, status)
- Search bar for locations
- Mini profile cards on hover for caches
- Current location button
- Route planning tools
- Export visible area option
- Mobile-optimized touch controls
- Dark/light theme toggle
```

### 7. Statistiques - Prompt First Draft
```
Design an analytics dashboard for geocaching stats:
- Key metrics cards at top (total finds, completion rate, streak)
- Interactive charts showing:
  - Finds over time (line chart)
  - Difficulty distribution (bar chart)
  - Cache types found (pie chart)
  - Geographic distribution (heatmap)
- Leaderboard section
- Achievement showcase
- Export/share statistics
- Comparison with community averages
- Projection models for goals
- Time period selectors (week, month, year, all time)
```

### 8. Profil Utilisateur - Prompt First Draft
```
Design a user profile and settings page:
- Profile header with avatar, username, and stats
- Tabs for: Account Info, Preferences, Privacy, Notifications
- Form fields for personal information
- Privacy controls for data sharing
- Notification preferences (email, push, in-app)
- Data export options
- Account deletion option
- Theme selection (light/dark/auto)
- Language selection
- Connected apps/services
- Support links and feedback form
```

---

## 🎨 Design System

### Couleurs principales
```
Primary Green: #2E8B57 (Sea Green)
Secondary Blue: #1E90FF (Dodger Blue)
Accent Orange: #FF6B35 (Orange Red)
Background: #F8F9FA (Light Gray)
Text Primary: #2C3E50 (Dark Blue Gray)
Text Secondary: #6C757D (Gray)
Success: #28A745 (Green)
Warning: #FFC107 (Yellow)
Error: #DC3545 (Red)
```

### Typographie
```
Headings: Inter Bold (24px, 20px, 18px, 16px)
Body: Inter Regular (16px, 14px)
Caption: Inter Light (12px, 10px)
Line Height: 1.5
```

### Espacements
```
Base Unit: 8px
Margins: 8px, 16px, 24px, 32px, 48px
Padding: 8px, 12px, 16px, 20px, 24px
Border Radius: 4px (small), 8px (medium), 16px (large)
```

### Iconographie
```
Style: Outline icons (Heroicons, Lucide)
Sizes: 16px, 20px, 24px, 32px
Theme: Outdoor/Adventure (map, location, compass, mountain)
```

---

## 🔗 Interactions et Prototypage

### Navigation principale
```
Type: Bottom tabs (mobile) + Top navigation (desktop)
Animations: Smooth slide transitions (300ms ease-out)
States: Default, Active, Disabled
Micro-interactions: Haptic feedback on mobile
```

### Actions utilisateur
```
Buttons:
- Primary: Solid background, white text, hover lift
- Secondary: Outline, colored text, hover fill
- Ghost: No background, colored text, hover background

Forms:
- Focus states with colored borders
- Real-time validation
- Loading states with spinners
- Success/Error feedback with icons
```

### Cartes et conteneurs
```
Shadow: 0 2px 8px rgba(0,0,0,0.1)
Hover: Lift effect with deeper shadow
Animations: Scale (1.02) on hover
Border: 1px solid #E9ECEF
```

### Map interactions
```
Zoom: Smooth transitions with easing
Markers: Bounce animation on click
Popups: Fade in/out with scale
Clustering: Animated grouping/ungrouping
```

---

## 📐 Layout et Responsive

### Breakpoints
```
Mobile: 320px - 768px
Tablet: 769px - 1024px
Desktop: 1025px - 1440px
Large: 1441px+
```

### Grid System
```
Mobile: 1 column, full width
Tablet: 2-3 columns with gutters
Desktop: 3-4 columns, max-width 1200px
Sidebar: 300px fixed width (desktop)
```

### Components responsive
```
Cards: Stack on mobile, grid on larger screens
Navigation: Bottom tabs → Top navigation
Map: Full screen option on mobile
Forms: Single column → Multi-column layout
```

---

## 🔧 Guide d'implémentation Figma

### Étape 1: Setup initial
1. Créer un nouveau fichier Figma
2. Installer les plugins recommandés:
   - Codia AI DesignGen
   - Text to Design AI Assistant
   - Auto Layout
3. Créer la page "Design System" avec composants de base

### Étape 2: Utilisation de First Draft
1. Aller dans Actions > First Draft
2. Utiliser les prompts fournis ci-dessus pour chaque page
3. Générer les designs de base
4. Itérer avec des prompts de raffinement

### Étape 3: Création du Design System
```
Composants à créer:
- Buttons (Primary, Secondary, Ghost)
- Input Fields (Text, Number, Dropdown, File)
- Cards (Challenge, Cache, Stat)
- Navigation (Tab Bar, Header)
- Map Container
- Progress Bars
- Modal/Dialog
- Toast Notifications
```

### Étape 4: Prototypage
1. Utiliser la nouvelle fonction "Add Interactions" AI
2. Créer les flows principaux:
   - Onboarding → Dashboard
   - Create Challenge → Challenge Detail
   - Import GPX → Map View
   - Dashboard → Statistics

### Étape 5: États et variations
```
États à créer pour chaque composant:
- Default, Hover, Active, Disabled
- Loading, Success, Error
- Empty states
- Mobile/Desktop variations
```

---

## 🚀 Prompts de raffinement

### Pour améliorer les designs générés
```
"Make this design more modern with subtle shadows and better spacing"
"Add micro-interactions and hover states to all interactive elements"
"Improve the visual hierarchy with better typography contrast"
"Make this mobile-first and fully responsive"
"Add empty states and loading indicators"
"Apply the geocaching theme with outdoor-inspired colors and icons"
```

### Pour les interactions
```
"Add smooth page transitions between all screens"
"Create a floating action button that morphs into a menu"
"Add pull-to-refresh gesture on the challenges list"
"Create an overlay tutorial for first-time users"
"Add confirmation modals for destructive actions"
```

---

## 📋 Checklist final

### Avant de finaliser
- [ ] Tous les états de composants sont créés
- [ ] Navigation cohérente entre toutes les pages
- [ ] Design system complet et appliqué
- [ ] Responsive design testé sur tous breakpoints
- [ ] Interactions et animations définies
- [ ] Accessibility considérée (contrastes, focus states)
- [ ] Loading states et error handling
- [ ] Empty states et onboarding
- [ ] Cohérence avec l'identité geocaching

### Export et livraison
- [ ] Spécifications développeur exportées
- [ ] Assets optimisés (SVG, PNG)
- [ ] Prototype interactif partagé
- [ ] Documentation des composants
- [ ] Guide d'implémentation technique

---

## 💡 Conseils d'optimisation Figma AI

1. **Prompts itératifs**: Commencez simple, puis ajoutez des détails
2. **Références visuelles**: Utilisez des mots-clés comme "modern", "clean", "outdoor"
3. **Composants modulaires**: Créez d'abord les éléments de base
4. **Test et itération**: Générez plusieurs versions et combinez les meilleures parties
5. **Validation utilisateur**: Testez les prototypes avec de vrais géocacheurs

Cette spécification vous permettra de créer une application GeoChallenge Tracker complète et professionnelle en utilisant au maximum les capacités de Figma AI !