#!/usr/bin/env python3
"""Idempotently append an [[mcp_servers]] block to a Vibe config.toml.

Reads the target with tomllib, skips if a server of the same name exists,
otherwise appends the block. Append is safe because an [[mcp_servers]]
header always starts a fresh table. Standard library only.
"""
import sys
import tomllib
from pathlib import Path


def server_exists(config_text: str, name: str) -> bool:
    data = tomllib.loads(config_text)
    return any(s.get("name") == name for s in data.get("mcp_servers", []))


def add_server(config_path: Path, name: str, block: str) -> bool:
    """Append `block` unless a server named `name` already exists.

    Returns True if appended, False if it already existed.
    """
    config_path = Path(config_path)
    config_path.parent.mkdir(parents=True, exist_ok=True)
    existing = config_path.read_text() if config_path.exists() else ""
    if existing and server_exists(existing, name):
        return False
    prefix = existing if not existing or existing.endswith("\n") else existing + "\n"
    config_path.write_text(prefix + "\n" + block.strip() + "\n")
    return True


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: add_mcp_server.py <config_path> <name> <block_file>", file=sys.stderr)
        return 2
    cfg, name, block_file = sys.argv[1], sys.argv[2], sys.argv[3]
    added = add_server(Path(cfg), name, Path(block_file).read_text())
    print(f"{'added' if added else 'exists'}: {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
