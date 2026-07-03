# Instructions for Claude Code in this repo

1. Before declaring any task complete, run `plumbline check` and resolve every
   FAIL finding. The machine-readable report is at `.plumbline/report.json`.
2. Any change to a `.bicep` file must compile: `az bicep build --file <f> --stdout`.
3. Any change under `infra/terraform` must pass `terraform fmt -check` and
   `terraform validate`.
4. Never weaken security defaults in `infra/bicep/main.bicep` or the Terraform
   mirror (disableLocalAuth, diagnostics, publicNetworkAccess handling) without
   an entry in docs/DECISIONS.md explaining why.
5. New scenarios are overlays on the base module. Do not duplicate base
   resources inside a scenario.
