#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: ./install.sh [--bin-dir DIR] [--agent ID]" >&2
}

bin_dir="${HOME}/.local/bin"
preferred_agent=""
while [ $# -gt 0 ]; do
  case "$1" in
    --bin-dir)
      shift
      bin_dir="${1:?missing value for --bin-dir}"
      ;;
    --agent)
      shift
      preferred_agent="${1:?missing value for --agent}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
  shift
done

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source="$root/ttyclaw"
target="$bin_dir/ttyclaw"

if [ ! -x "$source" ]; then
  echo "install.sh: executable not found: $source" >&2
  exit 1
fi

mkdir -p "$bin_dir"
if [ -e "$target" ] || [ -L "$target" ]; then
  if [ "$target" -ef "$source" ]; then
    echo "ttyclaw is already installed at $target"
  else
    echo "install.sh: refusing to replace existing $target" >&2
    exit 1
  fi
else
  ln -s "$source" "$target"
  echo "Installed ttyclaw at $target"
fi

if [ -t 0 ] && [ -z "$preferred_agent" ]; then
  read -r -p "Preferred OpenClaw agent (e.g. jarvis; leave blank for main): " preferred_agent || true
fi
if [ -n "$preferred_agent" ]; then
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ttyclaw"
  mkdir -p "$config_dir"
  printf '%s\n' "$preferred_agent" > "$config_dir/agent"
  echo "Preferred agent saved to $config_dir/agent"
fi

case ":${PATH}:" in
  *":${bin_dir}:"*) ;;
  *) echo "Add $bin_dir to PATH to run ttyclaw from any directory." ;;
esac
