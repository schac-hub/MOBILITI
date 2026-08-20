# Project Plan

Design a complete mobile app called "Mobiliti" — a carpooling app for Abidjan, Côte d'Ivoire, built with FLUTTER. 

Target screen: iPhone 14 Pro (390×844px). 
Design language: clean white backgrounds, primary green #1B5E38 (dark), accent green #4CAF50 (light), Inter font, rounded corners 12-16px. 
All text in French.

Specific Requirements for the developer:
- Language: Dart (Flutter framework)
- UI: Flutter Material 3
- State Management: Provider or Riverpod (recommended)
- CI/CD: Include codemagic.yaml for APK build.
- Project Structure: Standard Flutter lib/ folder structure.
- pubspec.yaml: Include dependencies for Google Fonts, Icons, and State Management.

Create exactly 9 screens:
1. SPLASH SCREEN (input_file_8.png)
2. LOGIN SCREEN (input_file_7.png)
3. HOME PASSENGER (input_file_5.png)
4. RESULTS LIST (input_file_6.png)
5. TRIP DETAIL (input_file_4.png)
6. PAYMENT (input_file_3.png)
7. TRIP IN PROGRESS (input_file_1.png)
8. PROFILE (input_file_2.png)
9. APP ICON / LOGO (input_file_0.png)

Design Tokens:
Primary: #1B5E38, Accent: #4CAF50, Surface: #F0F7F0, White: #FFFFFF, Text primary: #1F2937, Text secondary: #9CA3AF, Border: #E5E7EB, Error: #EF4444, Success: #22C55E, Font: Inter, Corner radius cards: 12px, Corner radius buttons: 14px, Corner radius inputs: 12px, Button height: 52px, Screen padding: 20px horizontal, Shadow: 0 2px 8px rgba(0,0,0,0.08)

## Project Brief

# Project Brief: Mobiliti (Android MVP)

This document outlines the features and technical architecture for **Mobiliti**, a carpooling application specifically designed for the urban landscape of Abidjan, Côte d'Ivoire.

## Features
- **Authentification et Profil**: Connexion sécurisée et gestion du profil utilisateur (Passager/Conducteur) avec une interface entièrement en français.
- **Recherche de Trajets**: Système de recherche intuitif pour trouver des covoiturages disponibles à Abidjan, incluant des filtres par destination et horaire.
- **Réservation et Paiement**: Flux de réservation simplifié permettant de choisir un trajet et de procéder au paiement sécurisé.
- **Détails et Suivi du Trajet**: Affichage complet des informations du trajet (conducteur, véhicule, itinéraire) et suivi de la progression en temps réel.

## High-Level Technical Stack
- **Langage**: Kotlin
- **UI Framework**: Jetpack Compose (Material 3)
- **Navigation**: **Jetpack Navigation 3** (Modèle piloté par l'état / State-driven) pour une gestion fluide des transitions et de la pile de retour.
- **Stratégie Adaptative**: **Compose Material Adaptive Library** pour garantir une expérience utilisateur optimale sur tous les formats d'écran (téléphones, pliables, tablettes).
- **Concurrence**: Kotlin Coroutines & Flow pour la gestion des tâches asynchrones.
- **Design Tokens**: 
    - **Couleurs**: Primaire (#1B5E38), Accent (#4CAF50), Surface (#F0F7F0).
    - **Typographie**: Police Inter.
    - **Composants**: Coins arrondis (12-16px) et boutons de 52px de hauteur.

---
*Note: This brief focuses on the Android implementation using modern Jetpack libraries as requested, ensuring a robust and maintainable foundation for the Abidjan market.*

## Implementation Steps
**Total Duration:** 33h 1m 59s

### Task_1_FoundationsAndAuth: Initialize project theme and implement Splash, Login, and Profile screens with Navigation 3.
- **Status:** COMPLETED
- **Updates:** Task 1 completed for Flutter.
- **Acceptance Criteria:**
  - Design tokens (Primary #1B5E38, Accent #4CAF50, Inter font) are applied
  - Splash (input_file_8.png), Login (input_file_7.png), and Profile (input_file_2.png) screens are functional
  - Navigation 3 is implemented for the app flow
  - All text is in French
  - The implemented UI must match the design provided in input_file_8.png, input_file_7.png, and input_file_2.png.
- **Duration:** 5h 33m 16s

### Task_2_RideDiscovery: Implement the core ride search flow: Home Passenger, Results List, and Trip Detail screens.
- **Status:** COMPLETED
- **Updates:** Task 2 completed for Flutter.
- Implemented HomeScreen with search functionality and suggested trips.
- Implemented ResultsScreen with filter chips and trip cards.
- Implemented TripDetailScreen with map integration, bottom sheet, and price breakdown.
- Added MainScreen with 5-tab bottom navigation.
- **Acceptance Criteria:**
  - Home screen (input_file_5.png) supports ride search by origin and destination
  - Results List (input_file_6.png) displays rides with price and duration
  - Trip Detail (input_file_4.png) shows driver info and itinerary
  - Map API_KEY is integrated
  - The implemented UI must match the design provided in input_file_5.png, input_file_6.png, and input_file_4.png.
- **Duration:** 27h 28m 43s

### Task_3_PaymentAndTracking: Implement the Payment and Trip in Progress screens with adaptive UI support.
- **Status:** IN_PROGRESS
- **Acceptance Criteria:**
  - Payment screen (input_file_3.png) includes mobile money options (MTN, Orange, Wave)
  - Trip in Progress screen (input_file_1.png) shows real-time tracking and SOS
  - Compose Material Adaptive is used for responsive layouts
  - The implemented UI must match the design provided in input_file_3.png and input_file_1.png.
- **StartTime:** 2026-07-24 09:34:21 GMT

### Task_4_PolishAndVerify: Generate App Icon, configure Codemagic CI/CD, and perform final run and verify.
- **Status:** PENDING
- **Acceptance Criteria:**
  - App icon (input_file_0.png) is generated and set
  - codemagic.yaml is configured for APK build
  - Project builds successfully, all existing tests pass, and app does not crash
  - Critic_agent confirms stability and UI fidelity across all 9 screens
  - The implemented UI must match the design provided in input_file_0.png.

