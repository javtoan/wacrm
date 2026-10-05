-- ============================================================
-- SECURITY DEFINER EXECUTE privilege hardening
--
-- PostgreSQL grants EXECUTE on new functions to PUBLIC by default.
-- Several privileged functions therefore remained callable by roles
-- that were never intended to invoke them directly, even where an
-- earlier migration granted the intended role explicitly.
--
-- Reset every audited function to an explicit allow-list. Function
-- owners (postgres) retain their inherent privileges, and trigger
-- execution is not affected by revoking direct client invocation.
-- ============================================================

BEGIN;

-- Invitation discovery is intentionally available before sign-in.
REVOKE ALL ON FUNCTION public.peek_invitation(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.peek_invitation(text) FROM anon;
REVOKE ALL ON FUNCTION public.peek_invitation(text) FROM authenticated;
REVOKE ALL ON FUNCTION public.peek_invitation(text) FROM service_role;
GRANT EXECUTE ON FUNCTION public.peek_invitation(text) TO anon, authenticated;

-- Authenticated, self-authorizing RPCs. Each derives the caller from
-- auth.uid() and performs its own membership/role checks.
REVOKE ALL ON FUNCTION public.redeem_invitation(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.redeem_invitation(text) FROM anon;
REVOKE ALL ON FUNCTION public.redeem_invitation(text) FROM authenticated;
REVOKE ALL ON FUNCTION public.redeem_invitation(text) FROM service_role;
GRANT EXECUTE ON FUNCTION public.redeem_invitation(text) TO authenticated;

REVOKE ALL ON FUNCTION public.set_member_role(uuid, public.account_role_enum) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.set_member_role(uuid, public.account_role_enum) FROM anon;
REVOKE ALL ON FUNCTION public.set_member_role(uuid, public.account_role_enum) FROM authenticated;
REVOKE ALL ON FUNCTION public.set_member_role(uuid, public.account_role_enum) FROM service_role;
GRANT EXECUTE ON FUNCTION public.set_member_role(uuid, public.account_role_enum) TO authenticated;

REVOKE ALL ON FUNCTION public.remove_account_member(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.remove_account_member(uuid) FROM anon;
REVOKE ALL ON FUNCTION public.remove_account_member(uuid) FROM authenticated;
REVOKE ALL ON FUNCTION public.remove_account_member(uuid) FROM service_role;
GRANT EXECUTE ON FUNCTION public.remove_account_member(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.transfer_account_ownership(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.transfer_account_ownership(uuid) FROM anon;
REVOKE ALL ON FUNCTION public.transfer_account_ownership(uuid) FROM authenticated;
REVOKE ALL ON FUNCTION public.transfer_account_ownership(uuid) FROM service_role;
GRANT EXECUTE ON FUNCTION public.transfer_account_ownership(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.is_account_member(uuid, public.account_role_enum) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_account_member(uuid, public.account_role_enum) FROM anon;
REVOKE ALL ON FUNCTION public.is_account_member(uuid, public.account_role_enum) FROM authenticated;
REVOKE ALL ON FUNCTION public.is_account_member(uuid, public.account_role_enum) FROM service_role;
GRANT EXECUTE ON FUNCTION public.is_account_member(uuid, public.account_role_enum) TO authenticated, service_role;

REVOKE ALL ON FUNCTION public.touch_presence(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.touch_presence(text) FROM anon;
REVOKE ALL ON FUNCTION public.touch_presence(text) FROM authenticated;
REVOKE ALL ON FUNCTION public.touch_presence(text) FROM service_role;
GRANT EXECUTE ON FUNCTION public.touch_presence(text) TO authenticated;

-- Backend RPCs. These are called through a service-role Supabase
-- client and must not be exposed to browser roles.
REVOKE ALL ON FUNCTION public.claim_ai_reply_slot(uuid, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.claim_ai_reply_slot(uuid, integer) FROM anon;
REVOKE ALL ON FUNCTION public.claim_ai_reply_slot(uuid, integer) FROM authenticated;
REVOKE ALL ON FUNCTION public.claim_ai_reply_slot(uuid, integer) FROM service_role;
GRANT EXECUTE ON FUNCTION public.claim_ai_reply_slot(uuid, integer) TO service_role;

REVOKE ALL ON FUNCTION public.record_webhook_failure(uuid, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.record_webhook_failure(uuid, integer) FROM anon;
REVOKE ALL ON FUNCTION public.record_webhook_failure(uuid, integer) FROM authenticated;
REVOKE ALL ON FUNCTION public.record_webhook_failure(uuid, integer) FROM service_role;
GRANT EXECUTE ON FUNCTION public.record_webhook_failure(uuid, integer) TO service_role;

-- Operational repair RPC. Keep it available to trusted backend jobs,
-- but not to end-user roles.
REVOKE ALL ON FUNCTION public.recompute_broadcast_counts(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.recompute_broadcast_counts(uuid) FROM anon;
REVOKE ALL ON FUNCTION public.recompute_broadcast_counts(uuid) FROM authenticated;
REVOKE ALL ON FUNCTION public.recompute_broadcast_counts(uuid) FROM service_role;
GRANT EXECUTE ON FUNCTION public.recompute_broadcast_counts(uuid) TO service_role;

-- Internal broadcast helper and trigger entry points. Their postgres
-- owner retains execution; existing triggers continue to call them.
REVOKE ALL ON FUNCTION public._bcast_bump(uuid, text, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public._bcast_bump(uuid, text, integer) FROM anon;
REVOKE ALL ON FUNCTION public._bcast_bump(uuid, text, integer) FROM authenticated;
REVOKE ALL ON FUNCTION public._bcast_bump(uuid, text, integer) FROM service_role;

REVOKE ALL ON FUNCTION public.broadcast_recipient_aggregate_trigger() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.broadcast_recipient_aggregate_trigger() FROM anon;
REVOKE ALL ON FUNCTION public.broadcast_recipient_aggregate_trigger() FROM authenticated;
REVOKE ALL ON FUNCTION public.broadcast_recipient_aggregate_trigger() FROM service_role;

REVOKE ALL ON FUNCTION public.notify_conversation_assigned() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.notify_conversation_assigned() FROM anon;
REVOKE ALL ON FUNCTION public.notify_conversation_assigned() FROM authenticated;
REVOKE ALL ON FUNCTION public.notify_conversation_assigned() FROM service_role;

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM anon;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM authenticated;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM service_role;

-- One-shot data-repair functions remain owner-only. They are retained
-- for controlled maintenance but cannot be invoked through the API.
REVOKE ALL ON FUNCTION public.merge_duplicate_contacts() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.merge_duplicate_contacts() FROM anon;
REVOKE ALL ON FUNCTION public.merge_duplicate_contacts() FROM authenticated;
REVOKE ALL ON FUNCTION public.merge_duplicate_contacts() FROM service_role;

REVOKE ALL ON FUNCTION public.merge_duplicate_conversations() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.merge_duplicate_conversations() FROM anon;
REVOKE ALL ON FUNCTION public.merge_duplicate_conversations() FROM authenticated;
REVOKE ALL ON FUNCTION public.merge_duplicate_conversations() FROM service_role;

COMMIT;
