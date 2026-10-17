# Node versions. fnm reads .nvmrc and .node-version on cd the way nvm did, but sets PATH once at
# startup instead of sourcing nvm (which cost 7.7s of an 8s shell start)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"
fi
