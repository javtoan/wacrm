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

### 0.4 Staging runtime configuration — pending

- [ ] Select the staging application host and canonical staging URL.
- [ ] Configure `NEXT_PUBLIC_SUPABASE_URL`.
- [ ] Configure the Supabase public/anon key.
- [ ] Configure the server-only Supabase service-role key.
- [ ] Generate and store a staging-only `ENCRYPTION_KEY`.
- [ ] Configure `NEXT_PUBLIC_SITE_URL` and the Spanish locale.
- [ ] Keep Meta/WhatsApp disabled until its own integration gate.
- [ ] Document secret ownership and rotation procedures.

### 0.5 Authentication baseline — pending

- [ ] Set the Supabase Auth Site URL to the canonical staging URL.
- [ ] Allow the staging and localhost callback URL patterns.
- [ ] Verify sign-up and email confirmation.
- [ ] Verify sign-in and sign-out.
- [ ] Verify forgotten-password and reset-password flows.
- [ ] Verify session persistence and protected-route redirects.
- [ ] Verify account creation and first-owner membership.

### 0.6 Application smoke tests — pending

- [ ] Deploy the current PR head to staging.
- [ ] Load the dashboard without runtime errors.
- [ ] Create and update a contact.
- [ ] Create a pipeline and move a deal between stages.
- [ ] Create a deterministic flow without enabling external delivery.
- [ ] Create an automation in a non-delivery test configuration.
- [ ] Verify account isolation with two test accounts.
- [ ] Verify owner/admin/agent/viewer access boundaries.
- [ ] Check browser console and server logs for unexpected errors.

### 0.7 Security and operational readiness — pending

- [ ] Review Supabase Security Advisor findings.
- [ ] Review Supabase Performance Advisor findings.
- [ ] Resolve or formally accept every high-severity finding.
- [ ] Confirm service-role secrets never reach client bundles or logs.
- [ ] Establish staging backup/recovery expectations.
- [ ] Document upstream sync and migration procedures.
- [ ] Record the existing non-blocking SQL lint warning for
  `transfer_account_ownership`.

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

The next gate is **0.4 Staging runtime configuration**. It requires choosing a
staging application host and canonical URL before Supabase Auth redirects and
end-to-end authentication can be configured safely.
