# User Experience 2.0: The NPlan Flow

## 1. Onboarding (The First Launch)
**Goal:** Create the `User` profile and potentially the first Plan.

1.  **Profile Setup:**
    *   Input: Name.
    *   Selectors: Training Age (Novice/Int/Adv), Goal (Strength/Hypertrophy).
    *   Preferences: First Day of Week (Sun/Mon), Unit (kg/lbs).
2.  **Plan Decision:**
    *   Prompt: "Create a training plan now?"
    *   *No:* Go to Dashboard (Empty state). Show prominent "Create Plan" button.
    *   *Yes:* Proceed to Plan Generation.

## 2. Plan Generation & Editing (Strategy)
**Goal:** Define the Plan.

1.  **Configuration:**
    *   Input relevant configuration to allow system to generate the plan
2.  **Generation:**
    *   System generates a proposed schedule using `PlanGeneratorService`.
3.  **Review & Refine (The Editor):**
    *   **Level 1 (Week View):** See days (e.g., Mon: Squat, Wed: Bench). Reorder days.
    *   **Level 2 (Session View):** Tap a day to see exercises. Add/Remove/Reorder/Swap exercises in the *Template*.
4.  **Save:** Commits `PlanTemplate` to SwiftData.

## 3. Dashboard (The Hub)
**Goal:** Daily execution and status.

1.  **Primary Action:** Big "Start Workout" button if a session is scheduled/projected for today.
2.  **Status:**
    *   Weekly Adherence (Ring or Bar).
    *   Current Week View: [Mon: Done] [Wed: Missed] [Fri: Planned].
3.  **Aggregates:** Total Volume, recent PRs.

## 4. Workout Execution (Tactics)
**Goal:** Log the work. Handle reality.

1.  **Load:** `ProgramCalendarService` projects the session (Template + History + Overrides).
2.  **Adjust (Pre-Workout or In-Workout):**
    *   **Swap:** "Equipment busy" -> Swap exercise. (Creates `SessionOverride`).
    *   **Volume:** Add/Remove sets.
3.  **Log:**
    *   Input: Weight, Reps, RPE per set.
    *   **Timer:** Auto-starts on set completion. Must handle backgrounding (calculate elapsed time on resume).
4.  **Finish:**
    *   Saves `WorkoutLog`.
    *   Updates Adherence.

## 5. Program Calendar (The Map)
**Goal:** Visualize the journey.

1.  **Visuals:** Clean grid. Color-coded dots/shapes for "Completed", "Planned", "Missed". Minimal text.
2.  **Interaction:**
    *   Tap a past date: View Log (Read-only/Edit Details).
    *   Tap a future date: View Projection. Option to "Edit" (Creates Override).

## 6. Settings & Management
**Goal:** Control the machine.

1.  **Profile:** Edit Name, Age, Goal, Units. Allow users to edit and save
2.  **Plan Rules:**
    *   View "Factory Default" engines.
    *   Create/Clone "Custom" engines (Json config editing).
3.  **Data Management:**
    *   Granular Deletion: "Delete all logs", "Delete current plan", "Factory Reset".
