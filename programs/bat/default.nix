{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "my-base16";
    };
  };

  home = {
    file.".config/bat/themes/my-base16.tmTheme".text = builtins.readFile ./my-base16.tmTheme;
  };
}
