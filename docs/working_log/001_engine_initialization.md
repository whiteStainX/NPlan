# Engine Development: Phase 1 - Initialization & Data Foundation
**Date:** 2025-12-05
**Status:** In Progress

## 1. Context & Motivation
The core value proposition of NPlan is its "Plan Generation Engine"—an algorithm that solves the complex constraint satisfaction problem of creating a periodized, scientifically valid workout routine. This is mathematically non-trivial (bordering on NP-Complete if brute-forced, NP complete and hence the name NPlan).

Instead of building the full UI shell first (Tabs, Settings, etc.), we adopted an **"Engine-First"** approach. We are treating the Engine as a pure function:
`F(User Profile, Exercise Library) -> Plan`

This isolates complexity and allows us to iterate on the "Brain" without UI noise.

## 2. Technical Strategy
We established a dedicated **Engine Development Environment**:
1.  **Bypassed Main UI:** `ContentView` now routes directly to `EngineDebugView` (a custom test bench). 
2.  **Robust Data Seeding:** We moved away from hardcoded mocks to a rich JSON-based Exercise Library (`exercises.json`) containing critical metadata like `muscle_pattern`, `compound_status`, and `secondary_muscle_factors`. But currently the content is still being directly copied to the `DataSeeder.swift` to avoid loading complexity and speed up iteration
3.  **Schema Refinement:** 
    *   Refined `Exercise` to support many-to-many-like relationships via `SecondaryMuscle`.
    *   Defined `WorkoutSession` and `WorkoutExercise` to act as the output container for the engine.

## 3. Current Progress
- [x] **Architecture Defined:** "Funnel" Architecture (Pruning -> Skeleton -> Filling -> Validation).
- [x] **Data Layer Ready:** SwiftData models (`Plan`, `Session`, `Exercise`, `SecondaryMuscle`) are active.
- [x] **Seeding System:** `DataSeeder` successfully loads 40+ exercises with detailed attributes.
- [x] **Test Bench:** `EngineDebugView` displays the mock profile and confirms data loading.
- [ ] **Engine Logic:** The `PlanGenerationService` is currently a stub. The next step is implementing the "Funnel" logic.

## 4. Next Steps (The Funnel)
We will now implement the `PlanGenerationService` logic layer by layer:
1.  **Hard Pruning:** Implement logic to select the correct Split Template based on User Inputs (Days/Goal).
2.  **Skeleton Generation:** Create the "Empty Slots" for the week.
3.  **Exercise Selection:** Implement the greedy algorithm to fill slots from the DB.
