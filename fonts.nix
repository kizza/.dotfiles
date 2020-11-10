{ pkgs, ... }:

{
  imports = [
    modules/fira-fonts.nix
    modules/nerd-fonts.nix
    modules/powerline-fonts.nix
  ];

  fira-fonts.enable = true;
  nerd-fonts.enable = true;
  powerline-fonts.enable = true;
}
