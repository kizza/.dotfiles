{ config, lib, pkgs, ... }:

let
  cfg = config.nerd-fonts;
in
with lib;
{
  options = {
    nerd-fonts = {
      enable = mkEnableOption "Nerd fonts";
    };
  };

  # Available fonts at...
  # https://github.com/NixOS/nixpkgs/blob/6ba3207643fd27ffa25a172911e3d6825814d155/pkgs/data/fonts/nerdfonts/shas.nix

  config = mkIf cfg.enable (
    if builtins.currentSystem == "x86_64-darwin" then {
      home.file."Library/Fonts/nerd-fonts" = {
        source = pkgs.nerdfonts.override {
          fonts = [ "FiraCode" "SourceCodePro" ];
        };
        recursive = true;
      };
    } else {
      home.file.".fonts/nerd-fonts" = {
        source = pkgs.nerdfonts.override {
          fonts = [ "FiraCode" "SourceCodePro" ];
        };
      };
    }
  );
}
