# Staging backup and recovery runbook

## Status and scope

This runbook covers the Supabase Free project `wacrm-staging`
(`vfxegtsyurcrkketjkbn`). It defines a reproducible logical backup and an
isolated restore drill. It does not authorize restoring over staging.

As of 2026-10-07, the procedure is **documented but not recovery-tested**.
The available workstation has Docker, but no Supabase CLI, `pg_dump`, `psql`,
database credential, or approved encrypted backup destination. No real dump
was created and recovery must not be marked PASS until the evidence in this
runbook has been produced.

## Recovery objectives (proposed, not verified)

- **RPO:** at most 24 hours of database changes.
- **RTO:** restore database service in an isolated project within 4 hours of
  declaring recovery, plus time to copy Storage objects.
- Run a logical backup daily and before every migration or risky data repair.
- Retain 7 daily and 4 weekly encrypted backup sets. Review retention if
  staging begins to contain regulated or production-derived data.
- Perform an isolated restore drill monthly and before Foundation promotion.

These are operating targets, not measured guarantees. The first successful
timed restore drill establishes the initial measured RPO/RTO.

## What is and is not protected

The logical backup is three SQL files: roles, schema, and data. The data dump
includes database rows in managed schemas, including `auth.users`; treat every
file as sensitive personal data. The schema dump preserves database objects,
functions, triggers, grants, and RLS policies subject to Supabase CLI filtering.
Custom login-role passwords are not recoverable and must be reset separately.

`storage.buckets` and `storage.objects` contain Storage metadata. The actual
object bytes live outside PostgreSQL and are **not** in a database dump. Export
object bytes separately with an authenticated, checksum-producing Storage copy
process, and preserve each object's bucket and path. A database-only restore
can therefore reference missing files.

The backup also does not contain Dashboard configuration, Auth provider/SMTP
secrets, API keys, project secrets, Edge Function secrets, custom domains,
redirect allow-lists, external provider state, or the application's deployment
environment. Maintain those in the approved secrets manager and configuration
inventory; never place their values in this repository or backup logs.

## Preconditions

1. An operator has time-limited access to the staging database password and
   stores it only in the process environment or an approved password manager.
2. Current Supabase CLI and Docker are installed. Discover syntax with
   `supabase db dump --help`; do not assume flags from an older release.
3. An encrypted destination outside the repository exists. Use an encrypted
   volume or client-side encryption backed by an approved key manager.
4. Create a new empty Supabase project (or disposable compatible local stack)
   as the restore target. Record its project ref without recording credentials.
5. Confirm the source is `vfxegtsyurcrkketjkbn` and the destination is not that
   project before any restore command.

Use the Session pooler connection string by default. Put the complete source
and target connection strings in `SOURCE_DB_URL` and `RESTORE_DB_URL` for the
current shell without echoing them. Clear both variables when finished. Avoid
putting credentials directly on a command line, in shell history, or in CI
logs.

## Create a logical backup

Run from an encrypted directory outside the checkout. Use a timestamped folder
owned by the operator; the examples below assume the current directory is that
folder.

```sh
supabase db dump --db-url "$SOURCE_DB_URL" -f roles.sql --role-only
supabase db dump --db-url "$SOURCE_DB_URL" -f schema.sql
supabase db dump --db-url "$SOURCE_DB_URL" -f data.sql --use-copy --data-only \
  -x "storage.buckets_vectors" -x "storage.vector_indexes"
supabase db dump --db-url "$SOURCE_DB_URL" -f history_schema.sql \
  --schema supabase_migrations
supabase db dump --db-url "$SOURCE_DB_URL" -f history_data.sql --use-copy \
  --data-only --schema supabase_migrations
```

Do not redirect verbose output into the backup directory unless it has been
reviewed for connection strings and personal data. Do not use a public Git
repository, unencrypted artifact, or ordinary shared drive as backup storage.

## Validate and seal the backup

1. Confirm every command exited successfully and all five files are non-empty.
2. Inspect only structure, never row contents: verify `schema.sql` contains
   table definitions and RLS/policy statements; verify `data.sql` contains COPY
   statements; verify migration history files reference `schema_migrations`.
3. Generate SHA-256 hashes for all files. Store the hash manifest beside the
   encrypted archive and record timestamp, source project ref, CLI version,
   operator, and exit statuses without credentials or row data.
4. Encrypt the complete set before it leaves the workstation. Verify the
   encrypted archive can be decrypted and that its hashes still match.
5. Copy Storage object bytes separately, record per-object checksums, and
   reconcile object count and total bytes with Storage metadata. Never log
   signed URLs or object content.
6. Apply the retention policy only after a newer backup and its integrity
   evidence exist.

File presence and hashes prove integrity in transit, not recoverability. Only a
successful isolated restore drill proves recovery.

## Restore drill (isolated target only)

Before continuing, independently compare the source and destination project
refs. Stop if either URL resolves to `vfxegtsyurcrkketjkbn` as the destination.
Never run `supabase db reset --linked` for this drill.

Enable required extensions and platform features on the empty target, then run:

```sh
psql --dbname "$RESTORE_DB_URL" --single-transaction \
  --variable ON_ERROR_STOP=1 --file roles.sql
psql --dbname "$RESTORE_DB_URL" --single-transaction \
  --variable ON_ERROR_STOP=1 --file schema.sql
psql --dbname "$RESTORE_DB_URL" --single-transaction \
  --variable ON_ERROR_STOP=1 \
  --command 'SET session_replication_role = replica' --file data.sql
psql --dbname "$RESTORE_DB_URL" --single-transaction \
  --variable ON_ERROR_STOP=1 --file history_schema.sql \
  --file history_data.sql
```

If a known Supabase-managed ownership or `cli_login_postgres` grant fails, stop
and compare the exact statement with current Supabase restore documentation.
Make the smallest reviewed copy of the dump for the isolated target; do not
silently discard errors or modify the source backup.

Restore Storage bytes after database restore, preserving bucket and path.
Reapply secrets and Dashboard/Auth configuration from the approved inventory,
rotate any restored custom-role password, and re-enable required Realtime
publications. Keep outbound WhatsApp/email/webhook delivery disabled throughout
the drill.

## Recovery validation and evidence

Recovery is PASS only when all of the following are recorded without personal
data or secrets:

- restore commands completed with `ON_ERROR_STOP` and no ignored errors;
- expected application tables and critical columns exist;
- row counts by table match the source snapshot (counts only);
- `auth.users` count matches and a disposable test user can authenticate;
- Storage metadata count matches and sampled object checksums match the
  separately restored bytes;
- RLS is enabled on every expected exposed table and expected policy names,
  commands, roles, `USING`, and `WITH CHECK` clauses match;
- anonymous, owner, admin, agent, and viewer access checks behave as expected;
- local migration files and restored `supabase_migrations.schema_migrations`
  history agree, including migrations 043, 044, and 045;
- `supabase/ci/verify-schema.sql` and the database advisors complete, with
  findings resolved or explicitly accepted;
- application smoke tests run against the isolated target with outbound
  integrations disabled;
- elapsed restore time and observed data age are recorded to measure RTO/RPO.

Destroy the isolated project after evidence review according to the staging
data-handling policy. Revoke temporary credentials and securely remove local
plaintext files after the encrypted copy and hashes are verified.

## Free plan risks and escalation

The Free plan does not provide downloadable platform backups or a committed
PITR recovery point. Manual logical exports can fail silently if the schedule,
credential, workstation, or encrypted destination is unavailable. A daily RPO
is therefore operational rather than guaranteed, and Storage bytes require a
separate process. Project pausing, quota limits, provider incidents, human error,
and an untested restore can extend the proposed RTO.

Upgrade to Pro and reassess automated daily backups/PITR before staging carries
business-critical or production-derived data, the 24-hour RPO is insufficient,
or manual evidence misses two scheduled runs. Even after upgrading, retain an
independent encrypted export and Storage-object strategy.

## Migration and upstream-sync procedure

1. Work only on `codex/upstream-sync-2026-09-28`; fetch both remotes and inspect
   ahead/behind state. Do not update `main` or promote PR #1 without approval.
2. Before merging upstream or applying migrations, create and validate a fresh
   encrypted backup set. Stop when that prerequisite cannot be met.
3. Review incoming migrations and application changes. Resolve conflicts in the
   integration branch and run the repository's lint, typecheck, tests, and build.
4. Use `supabase migration list` and a dry run to compare local and staging
   history. Apply migrations in order only after review and backup evidence.
5. Run `supabase/ci/verify-schema.sql`, Security Advisor, Performance Advisor,
   and targeted Auth/RLS/Storage checks. Record accepted findings.
6. Re-run application smoke tests. Commit and push only the integration branch;
   leave PR #1 in draft until every Foundation promotion gate is evidenced.

The first execution of this procedure is pending the CLI/database access and an
approved encrypted destination described above.
