# 🤝 Contributing to Ping Me

> This document is the **law of the land**. Every contributor (human or AI co-pilot) must follow these rules without exception.

---

## 🌿 Branch Naming Convention

**NEVER push directly to `main`.** `main` is sacred — it only receives merges via Pull Requests.

### Format

```
<scope>/<short-description>
```

### Allowed Scopes

| Scope | Use Case | Example |
| :--- | :--- | :--- |
| `backend/` | Backend features, services, routes, DB | `backend/auth-otp-flow` |
| `frontend/` | Flutter screens, widgets, state | `frontend/chat-list-ui` |
| `fix/` | Bug fixes on either side | `fix/websocket-reconnect` |
| `chore/` | Config, tooling, CI/CD, deps | `chore/update-turso-sdk` |
| `docs/` | Documentation updates | `docs/api-endpoints` |
| `feature/` | Cross-cutting full feature work | `feature/e2ee-signal-protocol` |
| `hotfix/` | Critical production patch | `hotfix/auth-token-expiry` |

### Rules

1. **All lowercase, hyphens only** — no underscores, no spaces, no CamelCase.
2. **Be descriptive but concise** — `backend/message-status-tracking` not `backend/stuff`.
3. **One feature per branch** — don't mix backend and frontend work in one branch.
4. **Prefix must match the area of change** — frontend-only changes on a `backend/` branch are NOT allowed.

---

## 🔄 Git Workflow

```
main ──────────────────────────────────── (protected)
  │
  └──► backend/feature-name   (your work)
            │
            └──► PR → review → merge into main
```

### Step-by-Step

```bash
# 1. Always branch off from latest main
git checkout main
git pull origin main

# 2. Create your branch
git checkout -b backend/your-feature-name

# 3. Work, commit often
git add .
git commit -m "feat: describe what you built"

# 4. Push your branch
git push origin backend/your-feature-name

# 5. Open a Pull Request on GitHub
# Never force push to main.
```

---

## 📝 Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <short summary>

[optional body]
```

| Type | When to Use |
| :--- | :--- |
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Maintenance / deps |
| `docs` | Documentation only |
| `refactor` | Code restructure, no behavior change |
| `test` | Adding or fixing tests |
| `perf` | Performance improvement |

**Examples:**
```
feat: add OTP verification route with 5-min expiry
fix: resolve WebSocket disconnection on idle timeout
chore: update Turso client to v0.3.1
```

---

## 🏗️ Project Architects

| Role | Handle | Zone |
| :--- | :--- | :--- |
| **👑 Lead Architect** | Paradox | Backend, Architecture, Systems Design, E2EE |
| **🤖 AI Co-Pilot** | Antigravity | Code scaffolding, infrastructure support |

---

## 🔒 Protected Branches

| Branch | Protection Rule |
| :--- | :--- |
| `main` | No direct push. PR required. |

---

*Ping Me — Built to compete. Built right.*
