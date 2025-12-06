# Overall Plan & Implementation Strategy

This document serves as the master plan for evolving the NPlan generation engine from a single-week prototype to a fully constraint-based, multi-week mesocycle generator.

## 1. Theoretical to Practical Mapping

We are converting the formal definition in `@docs/algorithm/problem_generalization_multiweek.md` into concrete Swift implementation structures.

### 1.1 The Dimensional Grid (W, D, S) & The Consolidated Input Model

Currently, the inputs defining the grid ($W, D, S$) are scattered across `UserProfile`, `StrategyRepository`, and `TemplateRepository`. To make the architecture robust and testable, we will consolidate these into a single **Input Context** before generation begins.

**The Consolidated Input Model (`MesocycleBlueprint`):**

```swift
struct MesocycleBlueprint {
    // 1. Grid Dimensions
    let totalWeeks: Int                  // W (from Strategy)
    let daysPerWeek: Int                 // D (from User)
    
    // 2. The Structural Definition
    let splitDefinition: SplitTemplate   // Contains the Slots (S)
    
    // 3. The Rules of the Game
    let strategy: StrategyConfig         // Periodization rules
    
    // 4. The Constraints
    let userProfile: UserProfile         // User constraints/history
}
```

This ensures the `PlanGenerationService` receives a purely functional input package: `Blueprint -> Plan`.

| Formal Concept | Swift Implementation | Source in Blueprint |
| :--- | :--- | :--- |
| **Weeks ($W$)** | `Int` | `blueprint.totalWeeks` |
| **Days ($D$)** | `Int` | `blueprint.daysPerWeek` |
| **Slots ($S$)** | `[DailySlot]` | `blueprint.splitDefinition.days[d].slots` |
| **Grid Point $(w, d, s)$** | `WorkoutExercise` | Unique coordinate in the generated `Plan` |

### 1.2 Decision Variables as Persisted Records

The outcome of the plan generation is a collection of `WorkoutSession` records, each uniquely identified by its `weekIndex` and `dayIndex`. Within each `WorkoutSession`, there are `WorkoutExercise` records, each corresponding to a specific slot. Thus, a `WorkoutExercise` record effectively represents a `(w, d, s)` coordinate in the generated plan.

| Variable | Represents in Database View | Generation Logic / Flow |
| :--- | :--- | :--- |
| **$X[w,d,s]$**<br>(Exercise Assignment) | The `exercise` relationship within a `WorkoutExercise` record. | **Two-Phase Generation:**<br>1. **Skeleton Phase (Mesocycle-wide):** A `Map<DayIndex, Map<SlotIndex, Exercise>>` is determined once. This ensures that for a specific slot, the *same* base `Exercise` is chosen across all weeks ($w$) unless explicitly designed for variation. <br>2. **Instantiation Phase (Per week $w$):** When creating `WorkoutExercise` records for each week, this pre-selected `Exercise` is assigned. |
| **$Sets[w,d,s]$** | The `sets` property of a `WorkoutExercise` record. | **ProgressionEngine:** Function `getSets(week: Int, strategy: Strategy, slotType: SlotType)` (or similar granular input) will calculate this value for *each* `WorkoutExercise` record based on its week. |
| **$Reps[w,d,s]$** | The `reps` property (String, e.g., "5-7") of a `WorkoutExercise` record. | **ProgressionEngine:** Function `getReps(week: Int, strategy: Strategy, exerciseType: SlotType)` will calculate this value for *each* `WorkoutExercise` record based on its week and the exercise's type. |
| **$Intensity[w,d,s]$** | The `loadInstruction` property (String, e.g., "RPE 7") of a `WorkoutExercise` record. | **ProgressionEngine:** Function `getLoadInstruction(week: Int, strategy: Strategy)` will determine the instruction for *each* `WorkoutExercise` record based on its week. |
| **$Phase[w]$**<br>(Block Periodization) | Can be a property of the `Plan` (e.g., `currentPhase: PeriodizationPhase`), or derived from `weekIndex` against a `StrategyConfig` definition. | **Strategy Configuration:** `StrategyConfig` will hold a schedule (e.g., `[PeriodizationPhase]`) allowing `PlanGenerationService` to determine the phase for a given week. |

### 1.3 Exercise Selection Strategy ("Common Sense" Heuristics)

The current "First Match" greedy algorithm is insufficient for producing high-quality plans. We will adopt a **Filter -> Score -> Pick** strategy to balance Hard Constraints (validity) with Soft Constraints (quality/preference).

**The Algorithm:**
1.  **Filter (Hard Constraints):** Select all exercises that strictly match the Slot's requirements:
    *   Pattern (e.g., Squat)
    *   Type (e.g., Compound)
    *   Muscle (e.g., Quads)
    *   **[NEW] Equipment** (e.g., User has access to Barbell?)
2.  **Score (Soft Constraints):** Assign a numeric score to each candidate:
    *   **Tier Match:** Does the exercise difficulty align with the slot? (e.g., Slot 1 = Tier 1/Main Lift).
    *   **User History:** Bonus for "Favorite", Penalty for "Disliked" or "Recently Used" (to encourage rotation).
    *   **Synergy:** Penalty if too similar to another exercise already selected in the same session.
3.  **Pick:** Select the candidate with the highest score.

**Data Requirements:**
To support this, the `Exercise` model needs:
*   `equipment: [EquipmentType]` (e.g., `.barbell`, `.dumbbell`, `.machine`)
*   `tier: ExerciseTier` (e.g., `.tier1_primary`, `.tier2_secondary`, `.tier3_isolation`)

---

## 2. Gap Analysis

Comparing the formal definition to the current codebase state.

### 2.1 Data Models (`Models/`)
-   **[CRITICAL] Missing `weekIndex`**: `WorkoutSession` is currently flat. It needs to know which week of the mesocycle it belongs to.
-   **[MISSING] `MesocycleBlueprint`**: No current structure exists to consolidate all inputs for the generation engine.
-   **[MISSING] Exercise Metadata**: `Exercise` model lacks `equipment` and `tier` properties essential for intelligent heuristic selection.
-   **[MISSING] Phase Definition**: No enum or struct to define "Accumulation", "Deload", etc., for the `StrategyConfig`.

### 2.2 Domain Logic (`Engines/`)
-   **[MISSING] `ProgressionEngine`**: Currently an empty class. This is the brain for $Sets, Reps, Intensity$ variables across weeks.
-   **[WEAK] `PlanGenerationService`**:
    *   Currently loops `template.days` only (generates 1 week).
    *   Relies on a "first match" greedy approach for exercise selection, lacking heuristic scoring.
    *   Needs to separate "Exercise Selection" (Skeleton) from "Session Creation" (Instantiation).

### 2.3 Configuration (`Repositories/`)
-   **[PARTIAL] `StrategyRepository`**: Has basic volume/reps but lacks the fine-grained per-week progression rules (the "Wave" logic, phase schedules).

---

## 3. Implementation Roadmap

### Phase 1: Foundation & Data Model Updates
*Focus: Ensuring the persistence layer and input models support the multi-week, constraint-based requirements.*

- [ ] **Task 1.1: Update `WorkoutSession` Model**
  - **Action:** Add `weekIndex: Int` property to `WorkoutSession`. Update initializer.
  - **Validation:** Verify `WorkoutSession` initializes correctly with a week index.

- [ ] **Task 1.2: Enhance `Exercise` Model**
  - **Action:**
    - Define `EquipmentType` (enum: barbell, dumbbell, cable, machine, bodyweight).
    - Define `ExerciseTier` (enum: tier1, tier2, tier3).
    - Add `equipment: [EquipmentType]` and `tier: ExerciseTier` properties to `Exercise` class.
    - Update `DataSeeder` to handle these new fields (with default fallbacks if JSON is missing them initially).
  - **Validation:** Inspect `Exercise` objects in the DB; verify they have tiers and equipment lists.

- [ ] **Task 1.3: Define Periodization Structures**
  - **Action:**
    - Define `PeriodizationPhase` enum (accumulation, intensification, realization, deload).
    - Update `StrategyConfig` to include `phaseSchedule: [PeriodizationPhase]` and `cycleDurationWeeks`.
  - **Validation:** Verify `StrategyRepository` returns strategies with correct phase schedules (e.g., Intermediate = Wave pattern).

- [ ] **Task 1.4: Define `MesocycleBlueprint`**
  - **Action:** Create the `MesocycleBlueprint` struct to consolidate `UserProfile`, `StrategyConfig`, `SplitTemplate`, and `totalWeeks` into a single context object.
  - **Validation:** Compile check; confirm `PlanGenerationService` can be updated to accept this struct.

### Phase 2: The Progression Engine (Logic Core)
*Focus: Implementing the math for "Sets, Reps, Load" based on Strategy and Week.*

- [ ] **Task 2.1: Implement `ProgressionEngine` Interface**
  - **Action:** Create methods:
    - `getSets(week: Int, strategy: Strategy, slotType: SlotType) -> Int`
    - `getReps(week: Int, strategy: Strategy, slotType: SlotType) -> String`
    - `getLoadInstruction(week: Int, strategy: Strategy) -> String`
  - **Validation:** Unit test with a mock Strategy. Verify outputs change correctly for Week 1 vs Week 2.

- [ ] **Task 2.2: Implement Wave & Linear Logic**
  - **Action:** Fill out the body of the above methods to handle `Linear` (Novice) and `Wave` (Intermediate) logic branches.
  - **Validation:** Verify Intermediate strategy produces `10-12` reps in W1 and `8-10` in W2.

### Phase 3: The Multi-Week Generator (Service Refactoring)
*Focus: Wiring it all together—Skeleton Generation + Instantiation.*

- [ ] **Task 3.1: Implement Heuristic Exercise Selector**
  - **Action:** Create `ExerciseSelector` helper. Implement the "Filter -> Score -> Pick" logic using the new `tier` and `equipment` data.
  - **Validation:** Test with a specific Slot (e.g., Tier 1 Squat). Ensure it picks a Barbell Squat over a Leg Press if available.

- [ ] **Task 3.2: Refactor `PlanGenerationService` - Step 1 (Skeleton)**
  - **Action:** Update service to generate a `Skeleton` (Map of `Day -> Slot -> Exercise`) *before* creating sessions.
  - **Validation:** Verify that the selected exercises are consistent for the entire block.

- [ ] **Task 3.3: Refactor `PlanGenerationService` - Step 2 (Instantiation Loop)**
  - **Action:** Implement the `1...W` loop. Inside the loop, create `WorkoutSession`s using the Skeleton exercises and `ProgressionEngine` parameters.
  - **Validation:** Run `EngineDebugView`. Generate a 4-week plan. Check that Weeks 1-4 exist, contain the same exercises, but have changing sets/reps.

- [ ] **Task 3.4: Update `EngineDebugView` for Relational Visualization**
  - **Action:** Refactor the `debugLog` output or add a new UI component to display the generated plan as a grid/table. Group by Week -> Day -> Session. Show columns for Exercise, Sets, Reps, Load, and RPE to allow visual verification of progression patterns (e.g., rep drops, load increases).
  - **Validation:** Visual inspection: Can I clearly see the "Wave" pattern in the table? Are all weeks present? Are there any duplicate days or missing slots?
