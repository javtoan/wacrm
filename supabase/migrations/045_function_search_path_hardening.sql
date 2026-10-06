-- Fix the search path for functions flagged by Supabase Security Advisor.
-- ALTER FUNCTION preserves each function's body and other attributes.

ALTER FUNCTION public.update_ai_knowledge_documents_updated_at()
  SET search_path = public;

ALTER FUNCTION public.update_updated_at_column()
  SET search_path = public;

ALTER FUNCTION public._bcast_cols_for_status(text)
  SET search_path = public;

ALTER FUNCTION public.update_ai_configs_updated_at()
  SET search_path = public;
