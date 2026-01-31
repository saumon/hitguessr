<!--
Sync Impact Report
- Version: N/A → 1.0.0
- Modified principles: N/A (new constitution)
- Added sections: Core Principles, Quality & Performance Standards, Development Workflow & Reviews, Governance
- Removed sections: None
- Templates requiring updates: ✅ .specify/templates/plan-template.md; ✅ .specify/templates/spec-template.md; ✅ .specify/templates/tasks-template.md
- Follow-up TODOs: None
-->

# HitGuessr Constitution

## Core Principles

### I. Code Quality & Maintainability

All code changes MUST prioritize readability, single responsibility, and clear
boundaries. Public APIs MUST be documented, naming MUST be descriptive, and
dead or duplicated code MUST be removed. Rationale: high-quality code reduces
defects and lowers long-term change cost.

### II. Testing Standards (NON-NEGOTIABLE)

Every new or changed behavior MUST include tests that prove the intended
outcome and prevent regressions. Unit tests are required for pure logic; use
integration or UI tests for cross-module workflows. Tests MUST be reliable,
deterministic, and fast enough to run in CI. Rationale: verified behavior is
the only acceptable definition of done.

### III. UX Consistency & Accessibility

User-facing changes MUST follow established interaction patterns, visual
language, and copy guidelines. Accessibility requirements (keyboard, contrast,
and readable feedback) MUST be met for all primary flows. Rationale: consistent
experiences build trust and reduce user error.

### IV. Performance Budgets

Performance-impacting changes MUST declare targets and measure results against
budgeted metrics (e.g., p95 latency, frame rate, bundle size). Regressions are
not allowed without explicit approval and mitigation. Rationale: performance is
a product feature, not an optimization phase.

### V. Quality Gates & Review Discipline

All changes MUST pass linting, formatting, and automated tests before review.
Every change MUST be reviewed for correctness, UX consistency, and performance
impact when applicable. Rationale: gates prevent quality drift and ensure shared
ownership.

## Quality & Performance Standards

- Each spec MUST include explicit performance and UX consistency criteria.
- Linting and formatting tools MUST be enforced in CI.
- Dependency additions MUST include a justification and maintenance risk note.
- Any UI change MUST include a visual or interaction review step.
- Performance budgets MUST be tracked in plan/spec artifacts and verified in CI when feasible.

## Development Workflow & Reviews

- Work MUST be traced to a spec with acceptance scenarios and success metrics.
- Reviews MUST confirm test coverage for changed behavior and any UX impacts.
- Performance-sensitive changes MUST include before/after measurements or a documented rationale for why measurement is not applicable.
- Refactors MUST include parity checks to confirm behavior is unchanged.

## Governance

This constitution supersedes local or ad hoc practices. Amendments require a
documented proposal, explicit version bump (semantic versioning), and review by
project maintainers. All reviews MUST include a constitution compliance check.

**Version**: 1.0.0 | **Ratified**: 2026-01-31 | **Last Amended**: 2026-01-31
