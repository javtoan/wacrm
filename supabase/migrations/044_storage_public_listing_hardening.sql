-- ============================================================
-- 044_storage_public_listing_hardening.sql
--
-- Public buckets serve object URLs without requiring broad SELECT
-- policies on storage.objects. Remove public listing access while
-- preserving the existing public buckets and write policies.
--
-- Idempotent -- safe to re-run.
-- ============================================================

DROP POLICY IF EXISTS "Avatars are publicly readable"
ON storage.objects;

DROP POLICY IF EXISTS "Flow media is publicly readable"
ON storage.objects;

DROP POLICY IF EXISTS "Chat media is publicly readable"
ON storage.objects;
