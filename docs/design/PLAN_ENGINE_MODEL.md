# Workout Engine Model

This document defines the mathematical model, architectural strategy, and implementation specification for the automated workout generation system. It synthesizes principles from `PLANNING_FINAL.md` and `SPLIT.md` into a computational framework.

## I. Mathematical Problem Description

The goal is to define a function $F$ that maps a User Profile ($U$) and an Exercise Library ($E$) to a valid Periodized Training Plan ($P$), subject to a set of Constraints ($C$).

### 1. The Variables

**Input Vector ($U$):**
$$U = \{ Age, Goal, Availability, Fatigue, Performance \$$
*   $Age \in \{ \text{Novice, Intermediate, Advanced} \}$
*   $Goal \in \{ \text{Strength, Hypertrophy} \}$
*   $Availability \in \{ 2, 3, 4, 5, 6 \}$ (Days/Week)

**Search Space ($E$):**
A finite set of Exercises, where each exercise $e \in E$ has properties:
$$e = \{ \text{Name, Type (Compound/Isolation), Pattern (Push/Pull/Legs), Muscle, FatigueCost} \$$

**Output Matrix ($P$):**
A time-series schedule of $W$ weeks.
$$P = [W_1, W_2, \dots, W_n]$$
Where each Week $W$ is a set of Daily Sessions $D$:
$$D = [ (e_1, sets, reps, load), (e_2, \dots), \dots ]$$

### 2. The Constraints ($C$)

The system must satisfy two types of constraints:

**Type A: Hard Constraints (Binary Pass/Fail)**
*   **Frequency:** Every muscle group must be targeted $\ge 2$ times per week.
*   **Hierarchy:** Compound exercises must precede Isolation exercises within a session.
*   **Feasibility:** $Count(Sessions) \equiv U_{Availability}$

**Type B: Soft Constraints (Optimization Ranges)**
These are targets, not limits. Deviation is allowed but must be reported.
*   **Volume:** $TotalSets_{Muscle} \approx Target(U_{Age})$
    *   *Novice:* 10–12 sets/week
    *   *Intermediate:* 13–15 sets/week
    *   *Advanced:* 16–20 sets/week
*   **Specificty:**
    *   *Strength:* $>50\%$ volume on Competition Lifts.
    *   *Hypertrophy:* Balance Compound/Isolation ratios.

---

## II. Proposed Solution: The "Funnel" Architecture

To avoid NP-Complete complexity (Combinatorial Explosion), we utilize a **Hierarchical Constraint Satisfaction System** with a "Funnel" design. This reduces the problem from an exponential search $O(2^n)$ to a linear lookup and sort process $O(n)$.

### Stage 1: Hard Pruning (Predicate Pushdown)
**Logic:** Eliminate invalid configurations immediately based on $U$.
*   *Action:* Select exactly **ONE** Strategy (Periodization Model) and **ONE** Split Template.
*   *Result:* A strict configuration object (e.g., "Intermediate Wave Loading + 4-Day Upper/Lower").

### Stage 2: Skeleton Generation (Templating)
**Logic:** Pre-allocate empty "Slots" based on the Split Template to satisfy Hierarchical and Frequency constraints automatically.
*   *Action:* Generate an empty plan where Day 1 is defined not as "Empty" but as `[Slot(Compound, Push), Slot(Compound, Pull), Slot(Isolation, Tricep)...]`.
*   *Result:* Constraints like "Compounds First" are structurally enforced before exercise selection begins.

### Stage 3: Greedy Filling (Selection)
**Logic:** Fill the pre-defined slots from the library $E$ using a Greedy Algorithm.
*   *Heuristic:* Sort candidates by "Fit" (e.g., Primary Muscle Match > Compound Status).
*   *Action:* `Select * from E where type=Slot.Type and pattern=Slot.Pattern LIMIT 1`.

### Stage 4: Soft Fitting & Reporting (Validation)
**Logic:** Calculate the "Distance" between the generated plan and the Soft Constraints.
*   *Action:* Sum volumes per muscle. Compare against `Target(U_{Age})`.
*   *Result:* A `Plan` object accompanied by a `ConstraintReport` (e.g., "Chest Volume: -2 sets under target"). This empowers the user to make final micro-adjustments.

---

## III. Implementation Specification (End-to-End Pseudo-Code)

This pseudo-code follows the **Strategy + Pipeline** pattern.

### 1. Data Structures

```python
from dataclasses import dataclass
from typing import List, Dict, Optional, Literal

# --- Domain Models ---

@dataclass
class UserProfile:
    training_age: Literal['Novice', 'Intermediate', 'Advanced']
    goal: Literal['Strength', 'Hypertrophy']
    days_available: int # 2-6
    current_fatigue_score: int = 0 # For Reactive Deload logic

@dataclass
class Exercise:
    id: str
    name: str
    type: Literal['Compound', 'Isolation']
    pattern: str # e.g., 'Vertical Push', 'Squat Pattern'
    primary_muscle: str
    secondary_muscles: List[str]

@dataclass
class StrategyConfig:
    # Loaded from Config (PLANNING_FINAL.md logic)
    progression_model: str # 'Linear', 'Wave', 'Block'
    vol_min: int
    vol_max: int
    rep_range_compound: tuple
    rep_range_isolation: tuple
    cycle_duration_weeks: int

@dataclass
class DailySlot:
    # A placeholder in the Skeleton
    required_type: Literal['Compound', 'Isolation']
    required_pattern: Optional[str] = None
    target_muscle: Optional[str] = None
    default_sets: int = 3

@dataclass
class ScheduledExercise:
    exercise: Exercise
    sets: int
    reps: str
    load_instruction: str # e.g. "RPE 7" or "70%"

@dataclass
class GenerationResult:
    week_plan: Dict[str, List[ScheduledExercise]]
    periodization_plan: List[str] # Descriptions of future weeks
    constraint_report: Dict[str, str] # e.g. {"Chest": "Optimal", "Back": "Under -2"}

```

### 2. The Engine Logic

```python
class WorkoutEngine:
    def __init__(self, exercise_lib: List[Exercise], config_loader):
        self.library = exercise_lib
        self.config = config_loader

    def generate_plan(self, user: UserProfile) -> GenerationResult:
        """
        The Main Funnel Pipeline
        """
        
        # --- STAGE 1: HARD PRUNING ---
        # Select Strategy based on Age (e.g., Intermediate -> Wave Loading)
        strategy = self._get_strategy(user.training_age)
        
        # Select Split Template based on Days + Goal (e.g., 4 Day + Hyp -> Upper/Lower)
        split_template = self._get_split_template(user.days_available, user.goal)
        
        if not split_template:
            raise ValueError("No valid split found for this frequency/goal combination.")

        # --- STAGE 2: SKELETON GENERATION ---
        # The template already provides the "Slots" (buckets)
        # e.g., split_template['Day1'] = [Slot(Compound, Chest), Slot(Isolation, Tricep)...]
        
        week_plan_base = {}
        
        # --- STAGE 3: GREEDY FILLING ---
        for day_name, slots in split_template.items():
            daily_session = []
            
            for slot in slots:
                selected_exercise = self._find_best_match(slot, exclude=[e.exercise.id for e in daily_session])
                
                if selected_exercise:
                    # Apply Base Reps/Load from Strategy
                    reps = strategy.rep_range_compound if slot.required_type == 'Compound' else strategy.rep_range_isolation
                    
                    scheduled = ScheduledExercise(
                        exercise=selected_exercise,
                        sets=slot.default_sets,
                        reps=f"{reps[0]}-{reps[1]}",
                        load_instruction="RPE 7 (Base Week)"
                    )
                    daily_session.append(scheduled)
            
            week_plan_base[day_name] = daily_session

        # --- STAGE 4: SOFT FITTING & PROJECTION ---
        report = self._validate_constraints(week_plan_base, strategy)
        future_weeks = self._project_periodization(strategy)

        return GenerationResult(
            week_plan=week_plan_base,
            periodization_plan=future_weeks,
            constraint_report=report
        )

    # --- Helper Methods ---

    def _get_strategy(self, age: str) -> StrategyConfig:
        # Logic from PLANNING_FINAL.md Section I
        # Returns config object with vol_min, vol_max, etc.
        pass

    def _find_best_match(self, slot: DailySlot, exclude: List[str]) -> Optional[Exercise]:
        # The "Greedy" Selector
        candidates = [
            ex for ex in self.library 
            if ex.type == slot.required_type 
            and ex.id not in exclude
        ]
        
        # Pattern Match (Predicate Pushdown)
        if slot.required_pattern:
            candidates = [c for c in candidates if c.pattern == slot.required_pattern]
            
        # Muscle Match
        if slot.target_muscle:
            candidates = [c for c in candidates if c.primary_muscle == slot.target_muscle]
            
        if not candidates:
            return None
            
        # Sort by "Best Fit" (Simple heuristic: First match in DB, or randomize)
        return candidates[0] 

    def _validate_constraints(self, plan, strategy) -> Dict[str, str]:
        # Calculate Volume per muscle
        volume_map = {} # { 'Chest': 10, 'Back': 12 }
        
        for day in plan.values():
            for item in day:
                # Direct Volume
                m = item.exercise.primary_muscle
                volume_map[m] = volume_map.get(m, 0) + item.sets
                
                # Overlap Rule (from PLANNING_FINAL.md)
                # e.g., Squat adds 1.0 to Quads, but maybe 0.5 to Glutes?
                # This can be expanded.

        # Generate Report
        report = {}
        for muscle, vol in volume_map.items():
            if vol < strategy.vol_min:
                report[muscle] = f"LOW ({vol} < {strategy.vol_min})"
            elif vol > strategy.vol_max:
                report[muscle] = f"HIGH ({vol} > {strategy.vol_max})"
            else:
                report[muscle] = "OPTIMAL"
        
        return report

    def _project_periodization(self, strategy) -> List[str]:
        # Logic from PLANNING_FINAL.md Section I.2 & I.3
        if strategy.progression_model == 'Wave':
            return [
                "Week 1: Base Volume (12 Reps)",
                "Week 2: Load Focus (10 Reps, +2.5% Load)",
                "Week 3: Intensity Peak (8 Reps, +5% Load)",
                "Week 4: Reactive Deload (50% Volume)"
            ]
        elif strategy.progression_model == 'Linear':
            return ["Week 2+: Linear Single Progression (+5lbs per session)"]
        
        return []
```