# dotfiles

## Setup

#### Install [nix](https://nixos.org/)

```
sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
```

#### Run [home-manager](https://github.com/nix-community/home-manager)

```
nix-shell --run "home-manager switch"
```

#### Update

```
nix flake update nixpkgs-edge
```

coc-snippets for vim
- Ensure pip `sudo -H python -m ensurepip`
- Update python's neovim `python -m pip install --user --upgrade pynvim`

#### Set default shell
```
sudo bash -c "echo $(which zsh) >> /etc/shells"
chsh -s $(which zsh) $(whoami)
```

coc-snippets for vim
- Ensure pip `sudo -H python -m ensurepip`
- Update python's neovim `python -m pip install --user --upgrade pynvim`

#### Maintenance

```
# Garbage collect unused packages, -d delete past generations also
nix-collect-garbage -d
nix --extra-experimental-features nix-command store gc
# Deduplicate identical store paths
nix --extra-experimental-features nix-command store optimise

docker system prune -a --volumes
```
