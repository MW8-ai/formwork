# Decision Log

| Date | Decision | Alternatives | Why |
|---|---|---|---|
| 2026-07-03 | azapi for Terraform base | azurerm ai_foundry (hub-based, legacy), AVM pattern module | Exact parity with Bicep on the new CognitiveServices-based Foundry; no provider lag. AVM documented as enterprise alternative. |
| 2026-07-03 | RAG built first, 3 scenarios stubbed | build all four | One proven vertical before generalizing (platform-thinking guard). |
| 2026-07-03 | disableLocalAuth=true everywhere | keys for demo convenience | Standing credentials are the top showcase-repo risk; Entra-only is the standard being showcased. |
