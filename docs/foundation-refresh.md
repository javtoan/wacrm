# Phase 0 — Foundation Refresh

This phase establishes the stable base for the WACRM Platform fork before
product-specific modules are introduced. It preserves the upstream core and
keeps production promotion separate from validation.

## Target outcome

`Foundation v1.0` consists of:

- the current audited upstream baseline;
- the fork-specific clean-install migration fix;
- a reproducible staging database;
- a configured staging deployment;
- verified authentication and core user journeys;
- documented recovery points and promotion criteria.

## Guardrails

- `main` remains unchanged until every required gate below passes.
- `archive/pre-upstream-2026-09-28` and `pre-upstream-2026-09-28` preserve the
  previous fork state.
- Upstream-owned security, authentication, RLS, WhatsApp, AI, API and MCP core
  code is not customized without a documented reason.
- Product-specific work belongs in isolated modules and later phases.
- Production credentials and production databases are outside this phase.

## Workstream status

### 0.1 Repository baseline — complete

- [x] Identify the fork and upstream repositories.
- [x] Determine the common base and ahead/behind state.
- [x] Confirm the fork had no unpublished product commits.
- [x] Fast-forward the integration branch to upstream.
- [x] Preserve the previous state with a branch and annotated tag.
- [x] Publish the integration branch without modifying `main`.
- [x] Open draft PR #1 for review and promotion.

### 0.2 Code quality and dependency baseline — complete

- [x] Install from the lockfile.
- [x] Run the full unit/integration test suite.
- [x] Run TypeScript checks.
- [x] Run ESLint.
- [x] Build the production application with non-secret test variables.
- [x] Run the dependency vulnerability audit.
- [x] Confirm GitHub CI passes on the integration branch.

### 0.3 Supabase foundation — complete

- [x] Create the isolated `wacrm-staging` project.
- [x] Link the repository to the staging project.
- [x] Preview all database migrations before applying them.
- [x] Detect and repair the clean-install `uuid-ossp` schema issue.
- [x] Apply migrations `001` through `042` in order.
- [x] Confirm local and remote migration histories match.
- [x] Confirm a second dry run has no pending migrations.
- [x] Run `supabase/ci/verify-schema.sql` successfully.
- [x] Run the remote database linter.
- [x] Revoke every temporary and legacy access token used during setup.

### 0.4 Staging runtime configuration — validated with known incidents

- [x] Select the staging application host and canonical staging URL.
- [x] Configure `NEXT_PUBLIC_SUPABASE_URL`.
- [x] Configure the Supabase public/anon key.
- [x] Configure the server-only Supabase service-role key.
- [x] Generate and store a staging-only `ENCRYPTION_KEY`.
- [x] Configure `NEXT_PUBLIC_SITE_URL` and the Spanish locale.
- [x] Keep Meta/WhatsApp disabled until its own integration gate.
- [x] Document secret ownership and rotation procedures.

Validation was completed in staging without recording secret values here.
External Meta/WhatsApp delivery remains intentionally disabled and is not part
of Foundation acceptance.

### 0.5 Authentication baseline — validated with known incidents

- [x] Set the Supabase Auth Site URL to the canonical staging URL.
- [x] Allow the staging and localhost callback URL patterns.
- [x] Verify sign-up and email confirmation.
- [x] Verify sign-in and sign-out.
- [x] Verify forgotten-password and reset-password flows.
- [x] Verify session persistence and protected-route redirects.
- [x] Verify account creation and first-owner membership.

Authentication was validated on staging. Provider email limits and delivery
remain staging operational constraints rather than production guarantees.

### 0.6 Application smoke tests — validated with known incidents

- [x] Deploy the current PR head to staging.
- [x] Load the dashboard without runtime errors.
- [x] Create and update a contact.
- [x] Create a pipeline and move a deal between stages.
- [x] Create a deterministic flow without enabling external delivery.
- [x] Create an automation in a non-delivery test configuration.
- [x] Verify account isolation with two test accounts.
- [x] Verify owner/admin/agent/viewer access boundaries.
- [x] Check browser console and server logs for unexpected errors.

Smoke tests were completed with outbound integrations disabled. Known
non-blocking findings continue into Gate 0.7 and do not constitute a production
readiness decision.

### 0.7 Security and operational readiness — partial

- [ ] Review Supabase Security Advisor findings.
- [ ] Review Supabase Performance Advisor findings.
- [ ] Resolve or formally accept every high-severity finding.
- [ ] Confirm service-role secrets never reach client bundles or logs.
- [x] Establish staging backup/recovery expectations in
      `docs/runbooks/staging-backup-recovery.md`.
- [x] Document upstream sync and migration procedures.
- [x] Record the existing non-blocking SQL lint warning for
      `transfer_account_ownership`.

The `vector` extension warning is accepted temporarily for Foundation because
the RAG schema and queries depend on its present location. Moving it requires a
dedicated migration and regression test. Migrations 043, 044, and 045 address
function execution grants, public Storage listing, and function search paths.
Backup creation and isolated recovery remain **NOT TESTED**: the current
workstation has no Supabase CLI/PostgreSQL client, database credential, or
approved encrypted destination. Gate 0.7 must not pass until an encrypted dump
and isolated restore drill satisfy the runbook evidence checklist.

### 0.8 Foundation v1.0 promotion — approval required

- [ ] Review the final PR diff and green checks.
- [ ] Mark PR #1 ready for review.
- [ ] Merge PR #1 into `main` only with explicit approval.
- [ ] Tag the promoted commit as `foundation-v1.0`.
- [ ] Create the post-foundation development branch.
- [ ] Confirm the recovery branch and tag remain available.

## Current verified references

- Previous fork baseline: `137760e8f88fcd238551e3e51d51c315643fecf1`
- Audited upstream baseline: `45e80ad9e23b91f5c02ab9f935edbae67810e59d`
- Foundation fix commit: `c24f539`
- Integration branch: `codex/upstream-sync-2026-09-28`
- Draft pull request: <https://github.com/javtoan/wacrm/pull/1>
- Supabase staging project: `vfxegtsyurcrkketjkbn`

## Next executable gate

The next executable work is **Gate 0.7 backup/recovery evidence**. Install the
current Supabase CLI and PostgreSQL client, provide time-limited staging
database access and an approved encrypted destination, create the logical and
Storage backups, then restore only to an isolated target. Do not promote PR #1
until that drill passes and the remaining advisor findings are resolved or
formally accepted.
