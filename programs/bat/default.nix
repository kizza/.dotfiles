{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "my-base16";
    };
    themes = {
      my-base16 = builtins.readFile ./themes/my-base16.tmTheme;
    };
  };
}
