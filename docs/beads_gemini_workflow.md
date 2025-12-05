# Gemini CLI + Beads Workflow Guide
Comprehensive guide for installing, configuring, and operating **Beads** with **Gemini CLI**, including edge cases and best practices.

---

## 1. Overview

Beads is a lightweight, local, agent‑friendly issue tracker designed to give LLM agents a **structured task graph**, replacing ad‑hoc TODO lists and fragile `plan.md` workflows.

In this workflow:

- **Beads** = the canonical project memory  
- **Gemini CLI** = the agent working against that memory  
- **You** = human supervisor, validator, and executor of Beads commands

After setup, Beads becomes mostly transparent while Gemini CLI manages issues on your behalf.

---

## 2. Installation

### 2.1 Install Beads (`bd`) on macOS

**Option A — Homebrew (recommended):**
```bash
brew tap steveyegge/beads
brew install bd
```

**Option B — Install script:**
```bash
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

### 2.2 Verify installation
```bash
bd --version
bd doctor
```

A successful `bd doctor` means your environment is ready.

---

## 3. Initializing Beads in a Project

Inside your project folder:

```bash
cd /path/to/project
bd init
```

This creates:

```
.beads/
  issues.jsonl      # Canonical issue database (committed)
  beads.db          # Local SQLite cache (ignored)
  config.yaml
  metadata.json
  README.md
```

After this, Beads is active for the repository.

---

## 4. Understanding How Beads Works

### 4.1 Issue Model

Each issue contains:

- **id** (e.g., `bd-a3f19c`)
- **title**
- **body**
- **priority** (0–4)
- **type** (`task`, `bug`, etc.)
- **status** (`open`, `in_progress`, `blocked`, `closed`)
- **dependencies**:
  - `blocks`
  - `blocked-by`
  - `parent / children`
  - `related`
  - `discovered-from`

### 4.2 Storage Model

- **SQLite (`beads.db`)**: fast local cache  
- **JSONL (`issues.jsonl`)**: single canonical source of truth  
- `bd sync` ensures both remain consistent.

### 4.3 Why Beads is Better Than Plan Files

- Machine-readable  
- Agent-safe  
- Non-hallucinated  
- Persistent  
- Session-independent  
- Designed for multi-agent workflows  

Markdown files may still exist for human planning, but **Beads drives the execution**.

---

## 5. Daily Usage Workflow (Minimal)

1. Create or review issues:
   ```bash
   bd create "Setup app routing" -t task -p 2
   bd ready --json
   ```

2. Start Gemini CLI inside the repo:
   ```bash
   gemini
   ```

3. Provide the core instruction (or use wrapper script):
   ```
   Use Beads (bd) as the issue tracker.
   Run `bd ready --json`, choose an issue, and focus only on that.
   Update issues via Beads commands.
   ```

4. Gemini proposes:
   - implementation steps  
   - `bd update` commands  
   - `bd close` commands  

5. You execute the shell commands it outputs.

6. Sync if needed:
   ```bash
   bd sync
   ```

---

## 6. Recommended `AGENTS.md` (Persistent Instructions)

Place this in your repo:

```markdown
# Agent Instructions (Beads Workflow)

1. Use Beads ("bd") as the canonical issue tracker.
2. Before starting work, run:
   `bd ready --json`
3. Select one issue ID and state your intention to work on it.
4. When discovering new tasks, propose:
   `bd create "<title>" -t task -p <priority>`
5. Update progress with:
   `bd update <id> --status in_progress`
6. Close issues with:
   `bd close <id>`
7. Never rely solely on free-form TODOs; Beads must reflect all work.
8. At end of session, summarize what was done and any new issues needed.
```

This prevents instruction loss when chats compress.

---

## 7. Wrapper Script (`gem-beads`)

Create `/usr/local/bin/gem-beads`:

```bash
#!/usr/bin/env bash
set -e
cd "${1:-.}"

READY=$(bd ready --json 2>/dev/null || echo "[]")

gemini -p "
You are an AI agent working in a Beads-enabled project.

- Use 'bd ready --json' to find tasks.
- Select a single issue and focus on it.
- Propose 'bd update' and 'bd close' commands as needed.
- All discovered work must become Beads issues.

Current ready issues:
${READY}
"
```

Make executable:

```bash
chmod +x /usr/local/bin/gem-beads
```

Use:

```bash
gem-beads .
```

---

## 8. Using Markdown Plans Without Conflicts

You can still ask Gemini CLI to generate `plan.md` for human consumption.

**Rules for no conflict:**

- Beads = canonical task source  
- Markdown = human narrative summary  
- Every actionable item must correspond to a Beads issue ID  
- Gemini should *never* use the Markdown as the task list

---

## 9. Edge Cases and How to Handle Them

### 9.1 Chat Compression / Lost First Prompt  
Problem: Gemini CLI forgets earlier instruction.  
Solution:
- Put instructions in `AGENTS.md`
- Use wrapper (`gem-beads`) so each session restarts correctly
- Gemini can reload instructions by reading the file

### 9.2 Manual Edits to Markdown Without Updating Beads  
Problem: plan.md diverges from reality.  
Solution:
- Convert all actionable items into Beads issues
- Treat Markdown as a read-only view of the plan

### 9.3 Gemini Suggests Invalid or Conflicting Beads Commands  
Solution:
- You are the authority; only execute commands you approve  
- If needed:  
  ```bash
  bd show <id>
  bd dep tree <id>
  ```

### 9.4 Agent Hallucinating Tasks Not in Beads  
Solution:
- Ask it to convert every hallucinated TODO into an explicit `bd create` command

### 9.5 Working on Multiple Issues at Once  
Solution:
- Beads enforces single-task focus per agent session  
- If needed, create sub-issues or dependencies correctly

### 9.6 Deleting or Renaming Issues  
Use:
```bash
bd update <id> --title "New title"
bd delete <id>
```
Beads auto-maintains graph integrity.

---

## 10. Best Practices

- **Always start with `bd ready --json`**
- **Never keep hidden task lists outside Beads**
- **Keep `AGENTS.md` short and strict**
- **Use wrapper script for consistency**
- **Gemini should always reference issue IDs**
- **Close issues cleanly and sync**

---

## 11. Quick Reference

### Basic Commands

```bash
bd list
bd ready --json
bd create "<title>" -t task -p 2
bd update <id> --status in_progress
bd close <id>
bd show <id> --json
bd dep tree <id>
bd sync
```

---

## 12. Summary

This workflow gives you:

- Structured, reliable task execution  
- Sessions that survive chat resets  
- Clear human-visible plans without conflicting sources of truth  
- A lightweight project memory system tailor-made for LLM agents  

Beads + Gemini CLI together build a high-discipline development loop with minimal friction and maximum consistency.

---

End of document.
