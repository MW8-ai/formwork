# Hardening Ladder

Rung 1 — Personal showcase (default): public endpoint, Entra-only auth,
full diagnostics, identity-only RBAC, no keys.

Rung 2 — Work / shared sub: publicNetworkEnabled=false, private endpoints for
Foundry + Search + Storage, VNet integration, Azure Policy for allowed regions
and mandatory tags.

Rung 3 — GCC / regulated: rung 2 plus customer-managed keys, network-restricted
agent patterns, NIST 800-53 mapping via the cloud-architect review skill, and
Content Safety Prompt Shields enforced on every model deployment.

Each rung is additive; nothing at a lower rung is ever loosened to climb.
