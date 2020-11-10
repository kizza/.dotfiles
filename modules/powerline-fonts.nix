{ config, lib, pkgs, ... }:

let
  cfg = config.powerline-fonts;
in
with lib;
{
  options = {
    powerline-fonts = {
      enable = mkEnableOption "Powerline fonts";
    };
  };

  config = mkIf cfg.enable (
    if builtins.currentSystem == "x86_64-darwin" then {
      home.file."Library/Fonts/powerline-fonts" = {
        source = pkgs.powerline-fonts;
        recursive = true;
      };
    } else {
      home.file.".fonts/powerline-fonts" = {
        source = pkgs.powerline-fonts;
      };
    }
  );
}
