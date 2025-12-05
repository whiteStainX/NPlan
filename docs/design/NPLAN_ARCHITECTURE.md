# NPlan Architecture

## 1. Architectural Style
**Service-Oriented Clean Architecture** with **SwiftData** as the reactive core. Decoupled and modular design. IoC (Inversion of Control) ensures the decoupled nature and makes sure all components can be easily modified for quick testing.

*   **UI Layer (MVVM):** Declarative SwiftUI views driven by ViewModels. ViewModels observe SwiftData queries.
*   **Service Layer (Stateless Logic):** "Engines" that accept Data inputs and return Computed outputs (Projections).
*   **Data Layer (SwiftData):** The single source of truth.

## 2. The Engine (The Very Core of the Project)
This is the defining characteristic of the plan generation engine. It utilizes a **Hierarchical Constraint Satisfaction System** with a **"Funnel" Architecture** to solve the complex problem of generating a valid, periodized workout plan without combinatorial explosion.

### The Funnel Stages
1.  **Stage 1: Hard Pruning (Strategy Selection)**
    *   **Input:** User Profile (Training Age, Goal, Frequency).
    *   **Logic:** Determines the **Periodization Strategy** (e.g., Linear vs. Wave vs. Block) and the **Split Template** (e.g., Upper/Lower vs. Push/Pull/Legs) based on strict lookup tables defined in `PLAN_GENERATION_RULES.md` and `SPLIT_GUIDELINES.md`.
    *   **Output:** A strict configuration object (e.g., "Intermediate Wave Loading + 4-Day Upper/Lower").

2.  **Stage 2: Skeleton Generation (Templating)**
    *   **Logic:** Pre-allocates empty "Slots" for the selected split. Structural constraints (like "Compounds before Isolations") are enforced here by the template structure itself.
    *   **Output:** An empty plan with typed slots (e.g., `[Slot(Type: Compound, Pattern: Push), Slot(Type: Isolation, Muscle: Triceps)]`).

3.  **Stage 3: Greedy Filling (Exercise Selection)**
    *   **Logic:** Iterates through the slots and selects the "Best Fit" exercise from the `ExerciseLibrary` database.
    *   **Heuristic:** Prioritizes primary muscle match and user equipment availability (if applicable), utilizing a greedy selection algorithm.

4.  **Stage 4: Soft Fitting & Reporting (Validation)**
    *   **Logic:** Calculates the "Distance" between the generated plan and the Soft Constraints (Volume Targets, Specificity).
    *   **Output:** A `ConstraintReport` (e.g., "Chest Volume: Optimal", "Back Volume: -2 sets under target") allowing the user to make informed manual adjustments.

## 3. Component Responsibilities

### A. Core Services (The "Engines")
These stateless services reside in `Domain/Engines` or `Domain/Services`.

*   **`PlanGenerationService` (The Facade):**
    *   Orchestrates the "Funnel" process.
    *   Coordinates `StrategySelector`, `TemplateBuilder`, and `ExerciseSelector`.
    *   **Input:** `UserProfile`, `ExerciseLibrary`.
    *   **Output:** `Plan` (Draft), `ConstraintReport`.

*   **`ProgressionEngine` (The Time-Series Logic):**
    *   Calculates future workouts based on the current `Plan` and the selected `Strategy`.
    *   Handles the logic for **Linear Progression**, **Wave Loading**, and **Block Periodization**.
    *   Determines loads (Weight/RPE) for future sessions.
    *   **Responsibility:** "Given Week 1 is complete, what does Week 2 look like?"

*   **`ValidationService` (The Auditor):**
    *   Analyzes a given `Plan` against the rules defined in `PLAN_ENGINE_MODEL.md`.
    *   Calculates weekly volume per muscle group.
    *   Checks frequency compliance (e.g., "Is Chest hit 2x/week?").

*   **`ExecutionService` (The Session Manager):**
    *   Manages the active workout session.
    *   Handles RPE logging, Timer logic, and immediate "In-Workout" adjustments (Swap, Skip).

### B. Data Stores (SwiftData)
*   `ModelContainer` is injected at the root.
*   Services generally read via `FetchDescriptor`.
*   UI reads via `@Query`.
*   **Key Models:**
    *   `UserProfile`: Stores Training Age, Goal, Constraints.
    *   `Plan`: The active macro-cycle.
    *   `WorkoutSession`: A single planned or completed workout.
    *   `Exercise`: The static library of movements.

### C. App State
*   **Minimalism:** `AppState` should NOT hold the entire data model in memory.
*   **Responsibility:** Handles Session state (Navigation, Active Workout tracking) and System state (First run, Migration status).

## 4. Directory Structure
```
NPlan/
├── App/
│   ├── Core/               # DI, AppState, System Config
│   ├── Data/
│   │   ├── Models/         # SwiftData @Model classes (UserProfile, Plan, WorkoutSession)
│   │   ├── Seeds/          # Default Exercises/Templates JSON
│   ├── Domain/             # Pure Logic & Structs
│   │   ├── Engines/        # PlanGenerationService, ProgressionEngine, ValidationService
│   │   ├── Services/       # AnalyticsService, ExecutionService
│   ├── UI/                 # Feature Modules
│   │   ├── Onboarding/
│   │   ├── Dashboard/      # Calendar, Adherence
│   │   ├── Workout/        # Active Session View
│   │   ├── Settings/
```
