# Git Training & Demo  
*A Practical 30-Minute Mini-Book for dev teams*

---

# 📑 Table of Contents

1. [Introduction](#1-introduction)  
2. [The Git Mental Model](#2-the-git-mental-model)  
   - [2.1 The Four Areas of Git](#21-the-four-areas-of-git)  
   - [2.2 Working Directory](#22-working-directory)  
   - [2.3 Staging Area (Index)](#23-staging-area-index)  
   - [2.4 Local Repository](#24-local-repository)  
   - [2.5 Remote Repository](#25-remote-repository)  
3. [Training Playground — Real Bug](#3-git-workflow-for-a-bug)  
   - [3.1 The Intentional Bug](#31-the-intentional-bug)  
   - [3.2 Creating a Focused Bugfix Branch](#32-creating-a-focused-bugfix-branch-best-practice)  
4. [High-Value Git Techniques](#4-high-value-git-techniques)  
   - [4.1 Technique 1 — Partial Staging](#41-technique-1--partial-staging)  
   - [4.2 Technique 2 — Fixing Mistakes Without Fear](#42-technique-2--fixing-mistakes-without-fear)  
5. [Feature Branch → PR Workflow + Best Practices](#5-feature-branch--pr-workflow--best-practices)  
6. [Git Merge Strategies](#6-git-merge-strategies)  

---

# 1. Introduction

Git has quietly become the backbone of modern software development. Whether you build cloud APIs, enterprise-grade .NET systems, or distributed microservices, Git is the invisible engine powering your team’s collaboration. Yet despite its ubiquity, most developers interact with only a fraction of its real capability. We learn just enough to survive:

- clone the repository  
- pull the latest changes  
- write code  
- commit  
- push  
- …and hope for the best

This surface-level workflow works—until it doesn’t:

- A merge conflict appears hours before deployment.  
- A feature branch dissolves into a messy chain of “fix”, “fix2”, “final”, and “final-final”.  
- A pull request becomes impossible to review because it includes debug logs, temporary edits, and half-baked experiments.

These are not failures of Git—they are failures in **how we use Git**.

This mini-book is written for mid-level developers who already work in production environments, collaborate with teams, and use Git daily—but want to use it *properly*, not just *functionally*.  
The goal is to give you a concise, practical, battle-tested set of Git techniques that truly matter in modern enterprise delivery:

- cleaner, intentional commits  
- safer experimentation without fear of breaking things  
- confident recovery from mistakes  
- professional pull request hygiene  
- a branching workflow that scales gracefully  

All demonstrations in this guide use **GitHub + VSCode** on a MacBook, but the concepts map **1:1 to Azure DevOps + Visual Studio** on Windows.

> **Git is Git everywhere.**  
> UIs change, Git doesn’t.

---

# 2. The Git Mental Model

Before we dive into advanced workflows such as partial staging etc., we must pause to build a solid mental foundation.

Git feels complex until you understand its internal structure.  
Once you internalize the Git mental model, everything becomes intuitive.

---

## 2.1 The Four Areas of Git

Git is a **distributed snapshot system** made of four distinct areas:

```
                         ┌────────────────────────────┐
                         │      Remote Repository     │
                         │  (GitHub / Azure DevOps)   │
                         └──────────────┬─────────────┘
                                        ▲
                                        │  git push / git pull
                                        │
┌────────────────────────────┐          │
│      Local Repository      │ <────────┘
│   (Your machine’s commit   │
│        history)            │
└──────────────┬─────────────┘
               ▲
               │  git commit
               │
┌────────────────────────────┐
│       Staging Area         │
│   (“Index” — the changes   │
│    you choose to commit)   │
└──────────────┬─────────────┘
               ▲
               │  git add / git add -p
               │
┌────────────────────────────┐
│     Working Directory      │
│  (Real files you edit on   │
│       disk or in VSCode)   │
└────────────────────────────┘
```

---

## 2.2 Working Directory

Where your real files live.  
This is what you see in VSCode or Visual Studio.

---

## 2.3 Staging Area (Index)

A **selective approval zone** where you decide which changes go into the next commit.

Enables:

- staging only parts of a file  
- grouping meaningful changes  
- cleaner commit histories  
- noise-free PRs  

Skipping it with:

```bash
git add .
```

is like “deploy everything because I fixed one line.”

---

## 2.4 Local Repository

After committing, changes move here.

Benefits:

- full offline capability  
- ability to safely rewrite history  
- recover almost anything  
- powerful tools like rebase/reset/bisect  

---

## 2.5 Remote Repository

GitHub or Azure DevOps.

- `git push` sends your work  
- `git pull` fetches team changes  

---

Together:  
```shell
Working Dir → Staging → Local Repo → Remote Repo
```
Once you understand this pipeline, Git stops feeling magical and starts feeling predictable.

---

# 3. Git Workflow for a Bug

We use a small PowerShell game: **Guess the Number**, which contains a deliberate bug.

Demonstrates:

- partial staging  
- clean commits

---

## 3.1 The Intentional Bug

The game incorrectly consumes attempts on invalid or out-of-range input:

```powershell
if (-not [int]::TryParse($guessRaw, [ref]$guess)) {
    Write-Host "That doesn't look like a valid number. Try again."
    continue       # ❌ BUG: attempt consumed
}

if ($guess -lt 1 -or $guess -gt $MaxNumber) {
    Write-Host "Please enter a number between 1 and $MaxNumber."
    continue       # ❌ BUG: attempt consumed
}
```

This bug mirrors real-world issues in validation logic, retry loops, and user workflows.

---

## 3.2 Creating a Focused Bugfix Branch (Best Practice)

Never fix anything directly on `main`.

```bash
git switch -c bugfix/preserve-attempts-on-invalid-input
```

This keeps work isolated and PRs clean.

---

# 4. High-Value Git Techniques

Senior developers rely on a small set of high-impact Git techniques. We will discuss two of them here.

---

## 4.1 Technique 1 — Partial Staging  
### *“Commit only what matters. Leave the noise behind.”*

### Step 1: The Real Bugfix

#### Original Bug:

```powershell
continue        # ❌ still consumes an attempt
```

#### Correct Fix:

```powershell
$attempt--      # ✅ FIX
continue
```

This belongs in the **bugfix commit**.

---

### Step 2: Unrelated Cosmetic Change

```powershell
Write-Host "Thanks for playing!"
```

becomes:

```powershell
Write-Host "Thanks for playing Guess the Number!" # ENHANCEMENT
```

This belongs in a **separate enhancement commit**.

---

### Step 3: How to Use Partial Staging

#### Substep 3.1 — Stage only bugfix hunks

```bash
git add -p src/guess-the-number.ps1
```

Example hunk:

```
+    $attempt--
+    continue
```

Press:

```
y
```

Skip enhancement hunk:

```
n
```

---

#### Substep 3.2 — Commit the bugfix

```bash
git commit -m "Preserve attempts on failed validation"
```

---

#### Substep 3.3 — Stage the enhancement

```bash
git add -p src/guess-the-number.ps1
```

Press:

```
y
```

---

#### Substep 3.4 — Commit the enhancement

```bash
git commit -m "Improve end-of-game message"
```

Final history:

```
git log -2 --oneline

<hash2> Improve end-of-game message
<hash1> Preserve attempts on failed validation
```

---

#### Why Partial Staging Matters

- Cleaner commits  
- Clearer PRs  
- Accurate history  
- Less noise  
- Professional Git hygiene  

If you adopt only one advanced Git technique, make it this one.

---

## 4.2 Technique 2 — Fixing Mistakes Without Fear  
### *“If it was ever committed, you can recover it.”*

The biggest barrier to mastering Git is fear—fear of losing work, breaking the branch, or making an irreversible mistake.

Technique 2 eliminates that fear by showing how to undo commits, unstage mistakes, discard edits, and recover anything using Git’s time machine: `reflog`.

---

### Step 1: Undo Last Commit (But Keep All Changes)

Add below line to end of file src/guess-the-number.ps1:

Write-Host "Have a good time ahead!"

You commit too fast:

```
git add src/guess-the-number.ps1
git commit -m "Last message"
```

Undo the commit but keep changes staged:

```
git reset --soft HEAD~1
```

---

### Step 2: Unstage Wrong Changes

Undo staging:

```
git restore --staged src/guess-the-number.ps1
```

---

### Stage 3: Hard Reset (Destructive but Recoverable)

Then stage and commit intentionally:

```
git add src/guess-the-number.ps1
git commit -m "Last message"
```

Remove the commit completely:

```
git reset --hard HEAD~1
```

This deletes the commit *and* its changes from the working directory.

---

### Step 4: Reflog — Git’s Time Machine

View all HEAD movements:

```
git reflog
```

Example:

```
766dd43 HEAD@{0}: reset: moving to HEAD~1
ab0239d HEAD@{1}: commit: Last message
```

Restore the lost commit:

```
git reset --hard ab0239d
```

---

### Why This Technique Matters

| Command | Purpose |
|--------|----------|
| `git reset --soft HEAD~1` | Undo commit, keep changes |
| `git restore --staged` | Unstage safely |
| `git restore <file>` | Discard uncommitted edits |
| `git reset --hard` | Wipe working directory + commit |
| `git reflog` | Recover anything |

Once developers understand these tools, Git becomes safe, predictable, and empowering.

---

# 5. Feature Branch → PR Workflow + Best Practices  
### *“Your PR is as important as your code.”*

This covers:

- creating feature branches  
- clean commits  
- PR titles/descriptions   
- merge strategies  

We implement a simple feature: **adding a `-ShowHints` parameter** to the Guess‑the‑Number game.  
This example is intentionally small, safe, and perfect to demonstrate a good PR.

---

### Step 1: Create the Feature Branch

Start from `main`:

```
git switch main
git pull
git switch -c feature/show-hints
```

---

### Step 2: Implement the Feature

#### Substep 2.1: Add a new parameter:

```powershell
param(
    [int]$MaxNumber = 100,
    [int]$MaxAttempts = 7,
    [string]$ShowHints = "off"
)
```

#### Substep 2.2: Add logic after the banner:

```powershell
if ($ShowHints -eq "on") {
    if ($secret -gt 50) {
        Write-Host "[Hint] The number is greater than 50."
    }
    else {
        Write-Host "[Hint] The number is 50 or below."
    }
    Write-Host ""
}
```

### Step 3: Commit cleanly:

```
git add -p src/guess-the-number.ps1
git commit -m "feat: add -ShowHints parameter"
```

Push the branch:

```
git push -u origin feature/show-hints
```

---

### Step 4: Open a Pull Request (GitHub → main)

#### **PR Best Practice #1 — Don’t push junk commits**
History is clean due to:
- partial staging  
- single meaningful commit  

#### **PR Best Practice #2 — Good title convention**

Example:

```
[#1234] Add -ShowHints flag to Guess the Number
```

#### **PR Best Practice #3 — Strong PR Description**

Example PR body:

```
### What changed?
- Added -ShowHints parameter.
- Prints a “greater than 50” or “50 or below” hint before the game starts.

### Why?
- Makes the game friendlier for beginners.

### How to test?
pwsh src/guess-the-number.ps1 -ShowHints on
pwsh src/guess-the-number.ps1 -ShowHints off

### Potential risks?
- None; this only affects initial output.
```

#### **PR Best Practice #4 — Keep PRs small**
Diff shows only ~8–10 lines.  
Easy to review, minimal risk.



#### **PR Best Practice #5 — Merge strategies**

- **Squash and merge** → preferred for small feature PRs  
- **Merge commit** → preserves branch history  
- **Rebase and merge** → linear history  

---

### Step 5 Merge the PR

In GitHub:

- Review  
- Approve  
- Merge (prefer "Squash and merge" for this example)

Then update your local `main`:

```
git switch main
git pull
```

---

#### Why This Section Matters

This section teaches developers how to:

- Work safely in feature branches  
- Produce clean, readable commit history  
- Write high‑quality, reviewer‑friendly PRs  
- Avoid common PR mistakes (junk commits, large diffs, rebasing PR branches)  
- Collaborate professionally in enterprise Git workflows  

This is the workflow expected in all modern teams using GitHub or Azure DevOps.


---

# 6. Git Merge Strategies  
### *Merge Commit vs Rebase and Merge vs Squash and Merge*

## 🔵 6.1 Merge Commit  
### *Preserve the full branching story.*

### What it does
- Keeps **every commit** from the feature branch  
- Creates a **merge commit (`M`)**  
- Preserves **branch structure**  
- Produces a **non-linear** graph  

### History Visualization
```
A --- B --------- M
       \         /
        C --- D
```

### Benefits
- Full traceability  
- Shows the real development timeline  
- No commit rewriting  
- Ideal for collaborative or long-running branches  

### Best For
- Large features  
- Multi-developer branches  
- Enterprise/audited environments  

---

## 🟢 6.2 Rebase and Merge  
### *Linearize the story while keeping all commits.*

### What it does
- Replays branch commits onto main  
- Preserves commits but **rewrites** them  
- Produces a **clean, linear** history  
- No merge commit  

### History Visualization
```
A --- B --- C' --- D'
```

### Benefits
- Cleaner than merge commit  
- Preserves granular commits  
- Easier to debug via `git bisect`  

### Best For
- Medium-sized feature branches  
- Clean, structured commit histories  

---

## 🟣 6.3 Squash and Merge  
### *Flatten the entire branch into one clean commit.*

### What it does
- Collapses all branch commits into **one**  
- Adds that commit directly to main  
- Removes branch structure  
- Produces a **very clean linear** history  

### History Visualization
```
A --- B --- E
```

(E = combined diff of C + D)

### Benefits
- Extremely clean history  
- Perfect for small PRs  
- Easiest rollback (one commit)  
- Hides noisy or experimental commits  

### Best For
- Small PRs  
- Bugfixes  
- Cosmetic changes  
- Teaching Git hygiene  

---

### 🧠 Summary Table

| Strategy | Keeps All Commits? | History Style | Merge Commit? | Best For |
|----------|--------------------|----------------|---------------|----------|
| **Merge Commit** | ✔ Yes | Non-linear | ✔ Yes | Large/team branches |
| **Rebase + Merge** | ✔ Yes (rewritten) | Linear | ❌ No | Clean multi-step PRs |
| **Squash + Merge** | ❌ No (one commit) | Linear | ❌ No | Small PRs, fixes |

### 🎯 One‑Line Metaphors

- **Merge Commit** → “Record the story exactly as it happened.”  
- **Rebase and Merge** → “Rewrite the story so it looks cleaner.”  
- **Squash and Merge** → “Summarize the entire story into one chapter.”


