"""Drop-in Plumbline gates for IaC repos: copy into plumbline/gates/ and add
`from plumbline.gates import iac_gates  # noqa: F401` next to the builtin
import in cli.py. Then add 'iac_scan' to your profile or add_gates.

This is the Formwork -> Plumbline link: same referee, new sport.
"""

from __future__ import annotations

import json
from pathlib import Path

from plumbline.config import Config
from plumbline.gates.base import Finding, GateResult, Status, register, run_tool, skip, tool_available


@register("iac_scan")
def iac_scan(root: Path, cfg: Config) -> GateResult:
    """checkov over Terraform dirs (Bicep is scanned in CI post-compile as ARM)."""
    tf_dirs = {p.parent for p in root.rglob("*.tf")}
    if not tf_dirs:
        return GateResult("iac_scan", Status.PASS, detail="no Terraform files")
    if not tool_available("checkov"):
        return skip("iac_scan", "checkov", "pip install checkov")
    findings: list[Finding] = []
    for d in sorted(tf_dirs):
        proc = run_tool(["checkov", "-d", str(d), "--framework", "terraform",
                         "-o", "json", "--quiet"], root)
        try:
            data = json.loads(proc.stdout or "{}")
            blocks = data if isinstance(data, list) else [data]
            for block in blocks:
                for item in (block.get("results", {}) or {}).get("failed_checks", []):
                    findings.append(Finding(
                        f"{item.get('check_id')}: {item.get('check_name')}",
                        f"{item.get('file_path')}:{item.get('file_line_range', ['?'])[0]}",
                        "high" if str(item.get("severity", "")).upper() in ("HIGH", "CRITICAL")
                        else "medium"))
        except json.JSONDecodeError:
            findings.append(Finding("checkov output unparsed", str(d), "low"))
    high = any(f.severity == "high" for f in findings)
    status = Status.FAIL if high else (Status.WARN if findings else Status.PASS)
    return GateResult("iac_scan", status, findings)
