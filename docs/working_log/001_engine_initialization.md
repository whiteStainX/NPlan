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
2.  **Robust Data Seeding:** We moved away from hardcoded mocks to a rich JSON-based Exercise Library (`exercises.json`) containing critical metadata like `muscle_pattern`, `compound_status`, and `secondary_muscle_factors`. The content is currently embedded directly into `DataSeeder.swift` to avoid file loading complexity during rapid iteration.
3.  **Schema Refinement:**
    *   Refined `Exercise` to support many-to-many-like relationships via `SecondaryMuscle`.
    *   Defined `WorkoutSession` and `WorkoutExercise` to act as the output container for the engine.
    *   Introduced `SlotType` enum in `EngineTypes.swift` for type safety in exercise categorization.

## 3. Current Progress
- [x] **Beads Workflow Aligned:** Using 'bd' for task tracking (Task NPlan-oyb for Stage 3 is now closed).
- [x] **Architecture Defined:** "Funnel" Architecture (Pruning -> Skeleton -> Filling -> Validation).
- [x] **Data Layer Ready:** SwiftData models (`Plan`, `WorkoutSession`, `WorkoutExercise`, `Exercise`, `SecondaryMuscle`) are active and related.
- [x] **Seeding System:** `DataSeeder` successfully loads 40+ exercises with detailed attributes from embedded JSON. `Exercise.type` now uses `SlotType`.
- [x] **Test Bench:** `EngineDebugView` displays the mock user profile, confirms exercise loading, and now shows a detailed breakdown of the generated plan (sessions and their assigned exercises) from Stage 3.
- [x] **Engine Logic - Stage 1 (Hard Pruning):** Implemented in `PlanGenerationService`, selecting `StrategyConfig` and `SplitTemplate`.
- [x] **Engine Logic - Stage 2 (Skeleton Generation):** Implemented in `PlanGenerationService`, creating `Plan` and `WorkoutSession` objects based on the template.
- [x] **Engine Logic - Stage 3 (Greedy Filling):** Implemented in `PlanGenerationService`, including `_findBestMatch` with hierarchical predicate matching to select and assign `Exercise`s to `WorkoutSession`s as `WorkoutExercise`s.

## 4. Known Issues & Next Steps

**Current Build Errors:**
*   `/Users/huangsong/Documents/projects/ios/NPlan/NPlan/App/Data/Models/Exercise.swift:3:8 No such module 'NPlan_App_Domain_Engines_EngineTypes'`
*   `/Users/huangsong/Documents/projects/ios/NPlan/NPlan/App/Data/Seeds/DataSeeder.swift:3:8 No such module 'NPlan_App_Domain_Engines_EngineTypes'`

**Cause:** These errors indicate an incorrect module import. All source files (`.swift`) in an Xcode target are typically part of a single module. Explicitly importing a subpath of the project as a module (`NPlan_App_Domain_Engines_EngineTypes`) is only necessary if "EngineTypes" were in a *separate* Swift module. Since `EngineTypes.swift` is in the same target/module as `Exercise.swift` and `DataSeeder.swift`, no explicit import statement (beyond standard Foundation/SwiftData) is needed for types defined within the same module.

**Resolution Plan:**
1.  Remove the incorrect `import NPlan_App_Domain_Engines_EngineTypes` line from both `Exercise.swift` and `DataSeeder.swift`.
2.  Ensure `SlotType` enum (defined in `EngineTypes.swift`) is `Codable` to ensure seamless integration with SwiftData's persistence and JSON decoding. (This was already done as part of the previous fix but ensuring it is logged here).

**Next Logical Engineering Step:**
Once build errors are resolved, the next stage of the Engine is **Stage 4: Soft Fitting & Reporting (Validation)**. This involves calculating volume per muscle group and comparing against targets defined by the `StrategyConfig`.
A new Beads task will be created for this.