{ pkgs, ... }:

{
  # programs.ripgrep = {
  #   enable = true;
  # };

  home = {
    packages = with pkgs; [
      ripgrep
    ];
  };

  home = {
    file.".config/ripgrep/config".text = builtins.readFile ./config.sh;
  };
}


