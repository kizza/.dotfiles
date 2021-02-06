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
./update
```

#### Set default shell
```
sudo bash -c "echo $(which zsh) >> /etc/shells"
chsh -s $(which zsh) $(whoami)
```

coc-snippets for vim
- Ensure pip `sudo -H python -m ensurepip`
- Update python's neovim `python -m pip install --user --upgrade pynvim`
