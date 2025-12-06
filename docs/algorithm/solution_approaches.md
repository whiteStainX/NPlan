
# Established Algorithms for Constraint-Based Gym Plan Generation

This document outlines algorithmic approaches suitable for solving your generalized gym-plan generation problem.  
Each approach is mapped to your specific constraints and data structure.

---

# 1. CSP / Backtracking (Recursive Search With Pruning)

A classical **Constraint Satisfaction Problem (CSP)** solver:

### How it works
- Recursively assign exercises to slots.
- At each step:
  - Prune choices that violate **hard constraints**.
  - Use forward-checking to eliminate impossible future states.
- When a full valid plan is generated, evaluate **soft constraints** for scoring.

### Why it fits your problem
Your split template already defines:
- A small number of slots
- Strong structural restrictions (patterns, types)

This drastically reduces the branching factor.

### Strengths
- Very easy to integrate with your current code.
- Perfectly handles hard constraints.
- Produces optimal or near-optimal solutions with heuristics:
  - Most constrained slot first
  - Best-first domain ordering
  - Early pruning if minimum weekly volume targets become impossible

### Weaknesses
- Worst-case exponential (though your domain is small)
- No built-in automatic tuning of soft constraints unless combined with heuristics

---

# 2. ILP / MILP (Integer Linear Programming)

A rigorous mathematical optimization approach.

### Variables
Binary variables:

```
x[i,j] = 1 if exercise i is assigned to slot j else 0
```

### Hard constraints become linear equations
- Slot capacity:  
  `Σ_i x[i,j] ≤ 1`
- Slot domain restrictions: remove illegal exercises
- Weekly muscle volume:  
  `weekly_sets[m] = Σ_i Σ_j sets[j] * contributes(i,m) * x[i,j]`

### Soft constraints become objective penalty terms

Example objective:

```
minimize Σ penalty_volume[m] + penalty_balance + penalty_goal_specific
```

### Strengths
- Cleanest separation of model vs. solver.
- Guarantees optimality (for small problems like yours).
- Easy to add new constraints, simply by writing new linear terms.

### Weaknesses
- Requires a solver (CBC, Gurobi, OR-Tools)
- Hard constraints must be expressible in linear form

This is the most “industry-standard” approach for scheduling/timetabling tasks.

---

# 3. CP-SAT (OR-Tools Constraint Programming Solver)

Modern constraint programming with SAT-based optimization.

### Why it fits
Your problem is structured exactly like a timetabling system:
- Slots × exercises
- Hard logical constraints
- Soft penalties

CP-SAT supports:
- Linear constraints
- Boolean logic
- Multi-objective optimization
- Very fast search through conflict-driven clause learning

### Advantages
- Much more expressive than ILP for discrete logic
- Often faster than classical ILP
- Automatically prunes huge swaths of search space

### Weaknesses
- Requires understanding OR-Tools modeling patterns

---

# 4. Local Search / Metaheuristics (Hill Climbing, Simulated Annealing, Genetic Algorithms)

Uses your **current greedy solution as a starting point**.

### Steps
1. Generate initial plan (your existing greedy engine).
2. Define neighborhood operations:
   - Swap exercises between slots
   - Replace exercise in a slot with another
   - Adjust sets
3. Score each plan using soft constraints.
4. Explore the search space:
   - Hill climbing → always improve
   - Simulated annealing → sometimes accept worse moves
   - Genetic algorithms → evolve multiple plans

### Why it fits your current pipeline
- You don’t need to rewrite your model.
- Very effective when soft constraints dominate.
- Flexible and easy to tune.

### Weaknesses
- No guarantee of optimal solution
- Sensitive to hyperparameters

---

# 5. Hybrid Approaches

You can mix algorithms:

### 5.1 CSP + Local Search
- Use CSP/backtracking to find a valid plan.
- Then apply local search to improve soft constraints.

### 5.2 ILP for Volume + CSP for Assignment
- First determine ideal weekly volume distribution with ILP.
- Then CSP chooses exercises matching that plan.

### 5.3 Template-Based Reduction + ILP
Your split templates drastically reduce the search space, making ILP extremely fast.

---

# 6. Recommended Path for Your System

Based on your current engine and goals:

### **Phase 1 — Convert your constraints to modular HardConstraint & SoftConstraint objects**
This detaches your logic from the algorithm.

### **Phase 2 — Implement CSP/backtracking**
Easy transition from your current greedy algorithm.

### **Phase 3 — (Optional) Add local search**
To fine-tune soft constraints.

### **Phase 4 — (Optional) Port to ILP or CP-SAT**
For maximal generality and long-term scalability.

---

# 7. Summary Table

| Approach | Strength | Weakness | Fit to Your Case |
|---------|----------|----------|------------------|
| CSP/backtracking | Strong hard constraint satisfaction | Potentially expensive search | Excellent starting point |
| ILP | Clean, optimal, scalable | Needs solver | Best long-term general solution |
| CP-SAT | Extremely fast & expressive | Some learning curve | Best all-around |
| Local search | Easy integration | Not guaranteed optimal | Great for polishing plans |

---

# Final Recommendation

Start with **CSP + SoftConstraints**, because it:
- Reuses your existing architecture
- Makes constraints first-class and testable
- Provides immediate quality improvements

Later, evolve to **CP-SAT** for a production-grade, fully optimal solution.

