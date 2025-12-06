
# Problem Generalization: Constraint-Based Multi-Week Gym Plan Generation  
(*Strategy-Dependent Multi-Week Periodization – Option C*)

This document formalizes your training-plan generation problem as a **multi-week constraint-optimization model** and maps your **actual rules** (training age, goal, split, periodization) into that framework.

It extends the previous version by:

- Explicitly modeling **periodization across multiple weeks** as decision variables.
- Allowing **different mesocycle lengths per strategy** (Option C).
- Providing a **concrete mapping** from your rules to the generalized model.

---

## 1. High-Level Problem Statement

We want an engine that generates a **complete training program** over multiple weeks (a mesocycle), given:

- User profile:
  - `training_age ∈ {Novice, Intermediate, Advanced}`
  - `goal ∈ {Strength, Hypertrophy}`
  - `days_per_week ∈ {2..6}`
- An exercise library with:
  - Pattern (Squat / Hinge / H. Push / V. Pull / etc.)
  - Type (Compound / Isolation)
  - Muscle groups (primary, secondary)
  - Fatigue characteristics

The engine must decide, for each **week**, **day**, and **slot**:

- Which exercise to assign
- How many sets & reps
- At what intensity (RPE, %1RM, or load zone)
- For advanced lifters: which **block phase** each week belongs to

while:

- Satisfying all **hard constraints** (validity & safety)
- Optimizing **soft constraints** (quality & goal alignment)

This is a **multi-week CSP/COP**: Constraint Satisfaction + Optimization.

---

## 2. Time and Structure: Weeks, Days, Slots

We introduce explicit time and structure dimensions.

### 2.1 Weeks

Let:

- `W(training_age)` = mesocycle length determined by strategy:

  - **Novice** (Linear): `W = 4` weeks  
  - **Intermediate** (Wave): `W = 3 or 4` weeks (e.g., 3-week wave + 1 optional deload)  
  - **Advanced** (Block): `W ∈ {4..8}`, e.g.:
    - Accumulation (2–3 weeks)
    - Intensification (2–3 weeks)
    - Realization / Peaking / Deload (1–2 weeks)

We model this as:

```text
Weeks: w ∈ {1, …, W}
where W is derived from strategy(training_age).
```

### 2.2 Days and Slots

- `Days: d ∈ {1, …, D}` where `D = days_per_week` (determined by user).
- `Slots: s ∈ {1, …, S_d}`: ordered slots within each day (e.g. 1..4–6), determined by your split template and design.

Each `(w, d, s)` is a **training opportunity** that can hold zero or one exercise.

---

## 3. Decision Variables

For each week `w`, day `d`, and slot `s`:

### 3.1 Exercise Assignment

```text
X[w, d, s] ∈ ExerciseLibrary ∪ {EMPTY}
```

### 3.2 Sets / Reps / Intensity

```text
Sets[w, d, s]      ∈ {0..8}             # sets for that exercise in that week/day/slot
Reps[w, d, s]      ∈ ℕ (bounded ranges) # integer reps
Intensity[w, d, s] ∈ IntensityZones     # e.g., {Easy, Moderate, Hard, VeryHard} or %1RM bands
```

For some models, `Sets` and/or `Reps` may be partly derived from strategy and treated as constrained, not fully free.

### 3.3 Block Phase (Advanced Only)

For advanced lifters with block periodization:

```text
Phase[w] ∈ {Accumulation, Intensification, Realization, Deload}
```

Subject to strategy-specific patterns, e.g.:

- Phase[1..2] = Accumulation
- Phase[3..4] = Intensification
- Phase[5]    = Realization or Deload

---

## 4. Parameters from Strategy and Split

### 4.1 Strategy (Per Training Age)

For each `(training_age, goal)` we define a **StrategyConfig**:

- Mesocycle length `W`
- Weekly volume targets per muscle `target_low[m, w], target_high[m, w]`
- Per-phase constraints:
  - Rep ranges for compound vs isolation
  - Intensity bands
  - Expected fatigue budgets

Examples:

- **Novice / Linear**:
  - W = 4
  - Weeks 1–4: progressive load, stable rep ranges (e.g., 5–8 reps for compounds).
- **Intermediate / Wave**:
  - W = 3 or 4
  - Week 1: 10–12 reps; Week 2: 8–10 reps; Week 3: 6–8 reps; Week 4: deload / reduced volume.
- **Advanced / Block**:
  - W = 6–8
  - Accumulation: higher volume, moderate intensity (reps 8–15)
  - Intensification: moderate volume, high intensity (reps 4–8)
  - Realization: lower volume, very high intensity (reps 1–3), lower fatigue

### 4.2 Split Templates (Per Days/Week and Goal)

From your split rules (e.g. ULUL for 4 days Hypertrophy, S/B/D-based splits for Strength), we derive:

- Which **body regions / movement patterns** each day focuses on.
- Which **slot types** exist (e.g. Day 1 Slot 1 = “Squat Pattern, Compound”; Day 1 Slot 2 = “Hinge Pattern, Compound”; etc.).

These define structural **slot constraints** and greatly reduce the solution space.

---

## 5. Hard Constraints (Multi-Week)

Hard constraints must always hold; any violation makes a plan invalid.

We group them into:

1. **Structural constraints**
2. **Muscle frequency & coverage**
3. **Periodization logic (inter-week progression)**
4. **Fatigue & safety constraints**

### 5.1 Structural Slot Feasibility

For any `(w, d, s)`:

- Exercise must match slot:
  - `type (Compound/Isolation)`
  - `pattern (Squat, Hinge, etc.)`
  - Upper vs Lower focus per split day

Formally:

```text
If SlotSpec[d, s] requires pattern P and type T,
then X[w, d, s] must have exercise.pattern = P and exercise.type = T
(or be EMPTY if allowed).
```

### 5.2 Muscle Frequency per Week

For each muscle `m` and week `w`, ensure a **weekly minimum frequency**:

```text
freq[m, w] ≥ 2   # e.g. chest trained at least twice per week
```

where `freq[m, w]` is derived from which days/slots train muscle m.

### 5.3 Inter-Week Progression Constraints

Multi-week periodization rules:

#### 5.3.1 Novice (Linear Progression)

- **Load/Intensity must non-decrease** over time during the mesocycle:

```text
Intensity[w+1, d, s] ≥ Intensity[w, d, s]   # or monotonic trend for key lifts
```

- Rep ranges generally stable:

```text
Reps[w, d, s] ∈ [R_min, R_max] for all w
```

#### 5.3.2 Intermediate (Wave Periodization)

- Rep scheme must follow approximate wave pattern, especially for main compounds:

Example for compounds:

```text
Week 1: Reps ∈ [10..12]
Week 2: Reps ∈ [8..10]
Week 3: Reps ∈ [6..8]
Week 4: Optional deload with reduced Sets and/or Intensity
```

Hard constraint variant (strict):

```text
If w = 1 then Reps[w,d,s] ∈ [10..12] for compounds
If w = 2 then Reps[w,d,s] ∈ [8..10]
If w = 3 then Reps[w,d,s] ∈ [6..8]
If w = 4 then Sets[w,d,s] ≤ 0.6 * Sets[w-1,d,s]
```

#### 5.3.3 Advanced (Block Periodization)

- Each week must be assigned a **phase**:

```text
Phase[w] ∈ {Accumulation, Intensification, Realization, Deload}
```

- Phase sequence constrained; e.g.:

```text
Phase[1..2] must be Accumulation
Phase[3..4] must be Intensification
Phase[5]    must be Realization or Deload
Phase[w+1] cannot be "earlier" than Phase[w] in progression order.
```

- Each phase imposes hard bounds:

```text
If Phase[w] = Accumulation:
    Reps[w,d,s] in [8..15]   for compounds
    Volume (Sets) relatively high

If Phase[w] = Intensification:
    Reps[w,d,s] in [4..8]
    Intensity high, volume moderate

If Phase[w] = Realization:
    Reps[w,d,s] in [1..3]
    Intensity very high, volume low
```

### 5.4 Fatigue & Safety Across Weeks

We define:

```text
Fatigue[w, d, s] = f(exercise, Sets[w,d,s], Intensity[w,d,s])
WeeklyFatigue[w] = Σ_d Σ_s Fatigue[w, d, s]
```

Hard constraints:

- Weekly fatigue below strategy-dependent budget:

```text
WeeklyFatigue[w] ≤ FatigueBudget[w]
```

- Cross-day conflicts:

```text
If X[w, d, s] is Heavy Deadlift and Intensity[w, d, s] in HEAVY_ZONE:
    Then no Heavy Squat with HEAVY_ZONE allowed on day d+1 (or first day next week).
```

---

## 6. Soft Constraints (Multi-Week Objective)

Soft constraints guide **quality** of the mesocycle; they become terms in the objective function.

### 6.1 Volume Targets per Muscle per Week

For each muscle `m` and week `w`:

```text
WeeklySets[m, w] = Σ_d Σ_s (Sets[w,d,s] * contributes(X[w,d,s], m))
```

Strategy defines:

```text
target_low[m, w], target_high[m, w]
```

Penalty if outside range:

```text
volume_penalty[m, w] =
    max(0, target_low[m,w] - WeeklySets[m,w])
  + max(0, WeeklySets[m,w] - target_high[m,w])
```

### 6.2 Smooth Volume Progression Across Weeks

We prefer gradual changes in volume:

```text
progression_penalty[m, w] = penalty if
    WeeklySets[m, w+1] is far from WeeklySets[m, w] * allowed_factor
```

e.g., not more than ±20% change.

### 6.3 Rep/Intensity Curve Matching

For Intermediate & Advanced strategies:

- We define a **target rep/intensity curve** for each lift or pattern.
- Penalty for deviation:

```text
rep_curve_penalty = Σ (|Reps[w,d,s] - target_reps[w,d,s]| over all key slots)
intensity_curve_penalty = Σ (|Intensity[w,d,s] - target_intensity[w,d,s]|)
```

### 6.4 Session Fatigue Balance

- Penalize weeks where one or two days are extremely heavy and others trivial.
- Encourage even distribution of fatigue:

```text
session_balance_penalty[w] = variance(Σ_s Fatigue[w,d,s] over d)
```

### 6.5 Exercise Diversity and Specificity

- Hypertrophy: penalize overly repetitive exercise selection across weeks; reward variation in angles.
- Strength: penalize too few exposures to key comp lifts and too many isolations.

---

## 7. Objective Function (Multi-Week Score)

We combine all soft constraints into a single objective:

```text
Score(Plan) = - (
    w_vol    * Σ_m Σ_w volume_penalty[m, w]
  + w_prog   * Σ_m Σ_w progression_penalty[m, w]
  + w_curve  * (rep_curve_penalty + intensity_curve_penalty)
  + w_fat    * Σ_w session_balance_penalty[w]
  + w_spec   * goal_specificity_penalty
  + w_div    * diversity_penalty
)
```

**Goal:** maximize `Score(Plan)` subject to all hard constraints.

---

## 8. Concrete Mapping of Your Existing Rules to the Multi-Week Model

This section explicitly ties **your rules** to the abstract formalism.

### 8.1 Training Age → Strategy → W and Phases

- **Novice**:
  - `W = 4`, no phases.
  - Linear progression: week-to-week load increase; rep range stable.
  - Constraints: monotonic Intensity; rep range fixed; WeeklySets gradually trending.

- **Intermediate**:
  - `W = 3` or `4`:
    - 3 working weeks with wave rep pattern (12 → 10 → 8), plus optional 4th deload week.
  - Constraints:
    - Per-week rep bands for compounds as defined above.
    - Week 4: reduced volume (Sets scaled down).

- **Advanced**:
  - `W` chosen per strategy (e.g., 6 weeks):
    - Week 1–2: Accumulation
    - Week 3–4: Intensification
    - Week 5–6: Realization / Deload
  - Constraints:
    - `Phase[w]` must follow Accumulation → Intensification → Realization (→ Deload).
    - Each phase has phase-specific rep/volume/intensity requirements.

### 8.2 Split Guidelines → Day/Slot Structure

From your split guide:

- Example: 4-day Hypertrophy ULUL:
  - U1, L1, U2, L2 days.
- Example: 4-day Strength around S/B/D:
  - Days built around 2–3 bench exposures, 1–2 squat, 1–2 deadlift.

These become:

- `SlotSpec[d, s]`: pattern & type requirements.
- Structural hard constraints for X[w, d, s].

### 8.3 Muscle Frequency and Weekly Targets

From your rules:

- Each major muscle (chest, back, quads, hamstrings, shoulders) must be trained **≥ 2× per week**.
- Weekly set targets differ by training age and goal (e.g. Novice 10–12, Intermediate 13–15, Advanced 16–20+ per muscle).

Mapped as:

- Hard constraints on frequency.
- Soft constraints on weekly volume ranges.

### 8.4 Periodization Curves

Your rules:

- Novice: simple linear load increases, stable reps.
- Intermediate: clear 3-week wave rep pattern.
- Advanced: multi-phase structure with distinct volume/intensity blocks.

Mapped as:

- Hard constraints on allowed rep/intensity ranges per week.
- Soft penalties for deviation from ideal curves.

### 8.5 Fatigue and Heavy-Lift Conflicts

Your rules:

- Avoid consecutive days of very heavy lower-body compounds.
- Avoid heavy deadlift before heavy squat.

Mapped as:

- Hard local cross-day constraints on `Intensity[w,d,s]` and `X[w,d,s]`.
- Optional soft penalties on aggregate WeeklyFatigue.

---

## 9. Summary

Your multi-week gym-plan generator is now modeled as:

1. **Decision variables across Weeks × Days × Slots:**
   - Exercise assignment `X[w,d,s]`
   - Sets, Reps, Intensity
   - Phase[w] for advanced

2. **Hard constraints:**
   - Structural feasibility (split & slot types)
   - Weekly muscle frequency
   - Periodization logic (linear, wave, block)
   - Fatigue/safety limits and heavy-lift conflicts

3. **Soft constraints (objective):**
   - Weekly volume targets and progression smoothness
   - Matching rep/intensity curves
   - Session fatigue balance
   - Goal-specific emphasis and exercise diversity

4. **Strategy-dependent mesocycle length W (Option C):**
   - W is determined by training age & chosen strategy, not fixed globally.

This formulation is now ready to be implemented with:

- CSP/backtracking
- CP-SAT / OR-Tools
- ILP/MILP
- Local search / metaheuristics

or any hybrid thereof, without needing to change the conceptual model again.

