# scripts/helper.py
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, Tuple, Optional


# -------------------------
# Platform helpers
# -------------------------

def is_linux() -> bool:
    return sys.platform.startswith("linux")


def is_darwin() -> bool:
    return sys.platform == "darwin"


def run(cmd: list[str]) -> str:
    return subprocess.check_output(cmd, text=True).strip()


# -------------------------
# Minimal TUI helpers
# -------------------------

def ask(q: str, default: Optional[str] = None) -> str:
    d = "" if default is None else default
    ans = input(f"{q} [{d}]: ").strip()
    return ans or d


def ask_yn(q: str, default: str = "y") -> bool:
    a = input(f"{q} (y/n) [{default}]: ").lower().strip()
    return (a or default).startswith("y")


def menu_select(prompt: str, choices: list[str], default: Optional[str] = None) -> str:
    if not choices:
        raise ValueError("choices list is empty")
    if default is None:
        default = choices[0]
    if default not in choices:
        raise ValueError("default must be one of the choices")

    print(prompt)
    for i, item in enumerate(choices, 1):
        mark = " <- default" if item == default else ""
        print(f"  [{i}] {item}{mark}")

    while True:
        ans = input(f"Choice (1-{len(choices)}) [{choices.index(default)+1}]: ").strip()
        if ans == "":
            return default
        if ans.isdigit():
            n = int(ans)
            if 1 <= n <= len(choices):
                return choices[n - 1]
        elif ans in choices:
            return ans
        print("Invalid selection.")


# -------------------------
# Defaults
# -------------------------

DEFAULT_TZ = "America/Chicago"
DEFAULT_LOCALE = "en_US.UTF-8"


def default_tz() -> str:
    return DEFAULT_TZ


def default_locale() -> str:
    return DEFAULT_LOCALE


# -------------------------
# GPU detection (Linux only)
# -------------------------

def detect_gpu() -> Optional[str]:
    """
    Return 'nvidia', 'amd', or 'intel' based on primary GPU in lspci.
    """
    if not is_linux():
        return None

    try:
        out = run(["lspci", "-nn"])
    except Exception:
        return None

    gpu_lines = [
        line for line in out.splitlines()
        if re.search(r"\b(VGA compatible controller|3D controller)\b", line)
    ]

    for line in gpu_lines:
        if "NVIDIA" in line:
            return "nvidia"
        if re.search(r"\b(AMD|ATI)\b", line):
            return "amd"
        if "Intel" in line:
            return "intel"

    return None


# -------------------------
# Scrape existing config (Linux-focused)
# -------------------------

def scrape_existing(path: Path) -> Tuple[Dict[str, object], str]:
    txt = path.read_text()
    out: Dict[str, object] = {}

    if m := re.search(r'system\.stateVersion\s*=\s*"([^"]+)"', txt):
        out["state_version"] = m.group(1)
    if m := re.search(r'time\.timeZone\s*=\s*"([^"]+)"', txt):
        out["timezone"] = m.group(1)
    if m := re.search(r'networking\.hostName\s*=\s*"([^"]+)"', txt):
        out["hostname"] = m.group(1)
    if m := re.search(r'i18n\.defaultLocale\s*=\s*"([^"]+)"', txt):
        out["locale"] = m.group(1)
    if m := re.search(r'i18n\.extraLocaleSettings\s*=\s*\{([^}]+)\}', txt, re.S):
        out["extra_locale"] = _parse_extra_locale(m.group(1))

    return out, txt


def _parse_extra_locale(block: str) -> Dict[str, str]:
    return {k: v for k, v in re.findall(r'([A-Z_]+)\s*=\s*"([^"]+)"', block)}


def build_extra_locale(extra: Optional[dict[str, str]]) -> str:
    if not extra:
        return ""
    body = "\n".join(f'    {k} = "{v}";' for k, v in extra.items())
    return (
        "  i18n.extraLocaleSettings = {\n"
        f"{body}\n"
        "  };\n"
    )


# -------------------------
# Ensure users/<user>.nix exists
# -------------------------

def ensure_user_file(root: Path, user: str, template_name: str = "generic-user.nix") -> None:
    users_dir = root / "users"
    users_dir.mkdir(exist_ok=True)

    target = users_dir / f"{user}.nix"
    template = users_dir / template_name

    if target.exists():
        return

    if not template.exists():
        raise SystemExit(f"template {template} not found")

    txt = template.read_text().replace("__USERNAME__", user)
    target.write_text(txt)


# -------------------------
# Host nix generation
# -------------------------

def _nix_bool(b: bool) -> str:
    return "true" if b else "false"


def generate_host_default_nix(
    *,
    hostname: str,
    user: str,
    role: str,
    tz: str,
    loc: str,
    extra_locale: Optional[dict[str, str]],
    state_version: str,
    gpu: Optional[str],
) -> str:
    """
    Generate machines/<hostname>/default.nix.

    Important: we only emit `my.isLaptop` for Linux roles.
    """
    is_linux_role = role.startswith("linux-")
    is_laptop = (role == "linux-laptop")

    extra_block = build_extra_locale(extra_locale) if is_linux_role else ""
    locale_line = f'  i18n.defaultLocale = "{loc}";\n' if is_linux_role and loc else ""
    gpu_import = ""
    if is_linux_role and gpu:
        gpu_import = f"    nixos-hardware.nixosModules.common-gpu-{gpu}\n"

    # Linux hosts: import linux module + hardware-configuration.nix
    if is_linux_role:
        return f"""{{ config, lib, pkgs, modules, host, home-manager, nixos-hardware, ... }}:

{{
  imports = [
    modules.universal
    modules.linux
    ./hardware-configuration.nix
{gpu_import}    ../../users/{user}.nix
  ];

  networking.hostName = host;

  # Linux-only laptop flag (defined by modules/linux.nix)
  my.isLaptop = { _nix_bool(is_laptop) };

  time.timeZone = "{tz}";
{locale_line}{extra_block}
  system.stateVersion = "{state_version}";
}}
"""

    # Darwin hosts: do NOT emit my.isLaptop at all
    # (and do not import hardware-configuration.nix)
    # Keep it minimal; other darwin-specific modules can be imported by the machine file if you prefer.
    return f"""{{ config, pkgs, modules, host, home-manager, nix-homebrew, ... }}:

{{
  imports = [
    modules.universal
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
    ../../users/{user}.nix
  ];

  networking.hostName = host;

  time.timeZone = "{tz}";

  system.stateVersion = {state_version};
}}
"""


def write_hw_file(host_dir: Path) -> None:
    """
    For Linux, copy /etc/nixos/hardware-configuration.nix when available.
    For Darwin, write a valid empty module (not a comment-only file).
    """
    hw_path = host_dir / "hardware-configuration.nix"

    if is_linux():
        src_hw = Path("/etc/nixos/hardware-configuration.nix")
        if src_hw.exists():
            hw_path.write_text(src_hw.read_text())
            return
        hw_path.write_text("{ ... }: { }\n")
        return

    # darwin: valid stub (in case something imports it accidentally)
    hw_path.write_text("{ ... }: { }\n")


# -------------------------
# Main wizard flow
# -------------------------

def wizard_main(root: Path) -> None:
    role_default = "mac-laptop" if is_darwin() else "linux-desktop"

    existing: Dict[str, object] = {}
    cfg_path = Path("/etc/nixos/configuration.nix")

    if is_linux() and cfg_path.exists() and ask_yn("Found /etc/nixos/configuration.nix -> import settings?", "y"):
        existing, _ = scrape_existing(cfg_path)
    elif ask_yn("No config found. Supply a path?", "n"):
        p = Path(ask("Path to configuration.nix", "")).expanduser()
        if p.exists():
            existing, _ = scrape_existing(p)

    state_version = str(existing.get("state_version") or "5")

    hostname = ask("Hostname", str(existing.get("hostname") or "my-machine"))
    user = ask("Primary user", "bedhedd")

    gpu = detect_gpu()
    role = menu_select(
        prompt="Select role:",
        choices=["linux-desktop", "linux-laptop", "mac-laptop", "headless"],
        default=role_default,
    )

    tz = ask("Timezone", str(existing.get("timezone") or default_tz()))

    # Locale prompts only matter for Linux hosts (darwin has no i18n.* option)
    loc = default_locale()
    extra_locale = None
    if role.startswith("linux-"):
        loc = ask("Locale", str(existing.get("locale") or default_locale()))
        if "extra_locale" in existing and ask_yn("Copy extraLocaleSettings?", "y"):
            extra_locale = existing.get("extra_locale")  # type: ignore[assignment]

    # Create host folder
    host_dir = root / "machines" / hostname
    host_dir.mkdir(parents=True, exist_ok=True)

    # Write machines/<hostname>/default.nix
    rendered = generate_host_default_nix(
        hostname=hostname,
        user=user,
        role=role,
        tz=tz,
        loc=loc,
        extra_locale=extra_locale,
        state_version=state_version,
        gpu=gpu,
    )
    (host_dir / "default.nix").write_text(rendered)

    # Hardware config stub/copy
    write_hw_file(host_dir)

    ensure_user_file(root, user)

    rebuild = "darwin-rebuild" if is_darwin() else "sudo nixos-rebuild"
    print(f"Created machines/{hostname}")
    print(f"Next: {rebuild} switch --flake .#{hostname}")
