#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# shellcheck source=scripts/lib.sh
source scripts/lib.sh
load_env
require_command git

PROJECT_NAME="${PROJECT_NAME:-agroclimR_app}"
GITHUB_USERNAME="${GITHUB_USERNAME:-GITHUB_USERNAME}"

if [[ ! -d .git ]]; then
  git init
fi

git branch -M main

git add README.md LICENSE .gitignore .env.example bin docker scripts tests examples docs inst

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  git commit -m "chore: initialize agroclimR_app structure"
else
  if ! git diff --cached --quiet; then
    git commit -m "chore: update agroclimR_app scaffold"
  fi
fi

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if ! git remote get-url origin >/dev/null 2>&1; then
    gh repo create "${GITHUB_USERNAME}/${PROJECT_NAME}" --private --source=. --remote=origin --push
  else
    git push -u origin main
  fi
else
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}.git"
    echo "Added placeholder remote: https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}.git"
  fi
  echo "Run after creating/authenticating the repo:"
  echo "  git push -u origin main"
fi

