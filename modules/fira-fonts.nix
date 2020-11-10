{ config, lib, pkgs, ... }:

let
  cfg = config.fira-fonts;
in
with lib;
{
  options = {
    fira-fonts = {
      enable = mkEnableOption "Fira fonts";
    };
  };

  config = mkIf cfg.enable (
    if builtins.currentSystem == "x86_64-darwin" then {
      home.file."Library/Fonts/fira-code" = {
        source = pkgs.fira-code;
        recursive = true;
      };
    } else {
      home.file.".fonts/fira-code" = {
        source = pkgs.fira-code;
      };
    }
  );
}
