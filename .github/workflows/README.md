### GitHub Actions Debug Workflows

This repo includes two manually-triggered debugging workflows to help validate branch logic and inspect runtime environments:

---

#### `.github/workflows/branch-logic-debug.yml`
**Purpose:** Confirms how GitHub Actions interprets branch names for conditional logic.

**Includes:**
- Raw `GITHUB_REF` output
- Parsed branch name
- Matching checks for:
  - `feature`
  - `feature/*`
  - `fix/*`
  - `hotfix/*`
  - `docs/*`

**How to run:**
1. Go to the **Actions** tab.
2. Select **Branch Matching Debugger**.
3. Click **“Run workflow”** and choose a branch.

---

#### `.github/workflows/env-context-dump.yml`
**Purpose:** Dumps full GitHub Actions environment and event context for deeper CI/CD troubleshooting.

**Includes:**
- All environment variables (`env`)
- GitHub’s internal `github` context object (as JSON)
- The triggering event payload (saved to `debug/event.json`)

**How to run:**
1. Go to the **Actions** tab.
2. Select **GitHub Actions Context Dump**.
3. Click **“Run workflow”** and pick any branch.
