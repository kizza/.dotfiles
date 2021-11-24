{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };

  home = {
    file.".config/bat/themes/my-base16.tmTheme".text = builtins.readFile ./my-base16.tmTheme;
  };
}
