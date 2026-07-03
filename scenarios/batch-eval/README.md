# Scenario: batch-eval (stub)

Deliberately not built yet. The base is proven with the RAG scenario first;
this becomes a parameter file plus a small overlay on the same hardened base
(infra/bicep/main.bicep) — it inherits Entra-only auth, diagnostics, and
managed-identity RBAC automatically and cannot opt out.

Planned overlay resources: see docs/ROADMAP.md.
