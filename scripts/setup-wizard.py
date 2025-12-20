#!/usr/bin/env python3
# scripts/setup-wizard.py

import os
import sys
from pathlib import Path

ROOT = Path(os.environ.get("REPO_ROOT", Path.cwd())).resolve()
if not (ROOT / "flake.nix").exists():
    sys.exit("Run the wizard from the root of your nix-config repo.")

SCRIPTS_DIR = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

from helper import wizard_main

if __name__ == "__main__":
    wizard_main(ROOT)
