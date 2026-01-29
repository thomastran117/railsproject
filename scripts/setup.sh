#!/usr/bin/env bash

set -e

CYAN="\033[36m"
GREEN="\033[32m"
RESET="\033[0m"

echo -e "${CYAN}=== Setup starting ===${RESET}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

FRONTEND="$ROOT/frontend"
BACKEND="$ROOT/backend"

require_cmd() {
  local cmd="$1"
  local msg="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$msg" >&2
    exit 1
  fi
}

install_node_deps() {
  local name="$1"
  local path="$2"

  if [[ -f "$path/package.json" ]]; then
    echo -e "${CYAN}Installing $name dependencies (npm)...${RESET}"
    pushd "$path" > /dev/null
    npm install
    popd > /dev/null
  fi
}

install_rails_deps() {
  local path="$1"

  if [[ -f "$path/Gemfile" ]]; then
    echo -e "${CYAN}Installing backend dependencies (Bundler)...${RESET}"

    require_cmd ruby "Ruby is not installed or not on PATH."
    require_cmd bundle "Bundler is not installed. Try: gem install bundler"

    echo -e "${GREEN}Ruby: $(ruby -v)${RESET}"
    echo -e "${GREEN}Bundler: $(bundle -v)${RESET}"

    pushd "$path" > /dev/null
    bundle install

    if [[ -x "bin/rails" ]]; then
      echo -e "${CYAN}Preparing database (bin/rails db:prepare)...${RESET}"
      bin/rails db:prepare
    fi

    popd > /dev/null
  fi
}

require_cmd node "Node.js is not installed or not on PATH."
require_cmd npm  "npm is not installed or not on PATH."
echo -e "${GREEN}Node: $(node -v)  npm: $(npm -v)${RESET}"

install_node_deps "frontend" "$FRONTEND"
install_rails_deps "$BACKEND"

echo -e "${GREEN}=== Setup complete ===${RESET}"
