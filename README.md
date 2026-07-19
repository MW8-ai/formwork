# Formwork

Template-of-templates for Azure AI Foundry. Cornerstone defines the standard,
Plumbline verifies it, **Formwork shapes the install**: every showcase pipeline
is poured into the same hardened mold.

## Architecture

```
infra/
  bicep/main.bicep        <- the base: Foundry account + project, Entra-only auth,
  terraform/              <- diagnostics to Log Analytics, managed identity. Terraform
                             mirror uses azapi against the identical ARM resources.
scenarios/
  rag/rag.bicep           <- COMPLETE: base + AI Search + grounding storage,
                             identity-only RBAC (no keys exist anywhere)
  agentic/                <- stub, by design
  batch-eval/             <- stub, by design
  ingest/                 <- stub, by design
```

Security lives in the base once. Scenarios are overlays and **cannot opt out**
of: `disableLocalAuth: true` (Entra ID only), audit + full diagnostic logging,
system-assigned managed identities, TLS 1.2+/no-public-blob storage, and
role-scoped RBAC using built-in role GUIDs.

The `publicNetworkEnabled` parameter defaults true for personal-sub showcases;
flip it false and add private endpoints for work/GCC deployment (see
docs/HARDENING.md ladder).

## Quickstart (personal sub)

```bash
az login
./scripts/deploy.sh rag mydemo eastus2
# ...demo it...
./scripts/destroy.sh mydemo        # Foundry S0 + Search basic bill while idle; tear down
```

## Governance

CI runs four jobs: `bicep build` compile check, `terraform validate`, `checkov`
(Terraform natively, Bicep post-compile as ARM), and the shared
[Plumbline](https://github.com/MW8-ai/plumbline) gate workflow. The
`plumbline-patch/iac_gates.py` file adds a checkov gate to Plumbline itself —
same referee across every repo, which is the whole point.

Agent-usable by design: Claude Code (via CLAUDE.md) and Codex (via AGENTS.md)
are instructed to run `plumbline check` and read `.plumbline/report.json`
before completing any task in this repo.

## Terraform notes

The base uses `azapi` against `Microsoft.CognitiveServices/accounts@2025-06-01`
for exact parity with the Bicep module and zero provider lag. For enterprise
landing-zone deployments, Microsoft's AVM pattern module
(`Azure/avm-ptn-aiml-ai-foundry/azurerm`) is the sanctioned alternative.

## License

MIT

<!-- cornerstone-method:start -->

---

## Part of the Cornerstone Method

**Know → Define → Assess → Shape → Verify → Visualize.** Formwork is the **Shape** verb — Bicep and Terraform templates for Azure AI Foundry, so every environment sets the same way twice.

Siblings: [CloudIntelMatrix](https://github.com/MW8-ai/CloudIntelMatrix) (Know — [live matrix](https://mw8-ai.github.io/CloudIntelMatrix/)) · [Architect's Cornerstone](https://github.com/MW8-ai/architects-cornerstone) (Define) · [Architecture Review Framework](https://github.com/MW8-ai/AI-Cloud-Architect-Framework) (Assess) · [Plumbline](https://github.com/MW8-ai/plumbline) (Verify) · [Architecture Anatomy](https://github.com/MW8-ai/architecture-anatomy) (Visualize — [live atlas](https://mw8-ai.github.io/architecture-anatomy/) · [exploded 3D](https://mw8-ai.github.io/architecture-anatomy/3d-prototype.html))

Method hub: [MW8-ai/cornerstone-method](https://github.com/MW8-ai/cornerstone-method)
<!-- cornerstone-method:end -->
