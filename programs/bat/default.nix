{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "my-base16";
    };
    themes = {
      my-base16 = {
        src = ./themes/my-base16.tmTheme;
        file = "my-base16.tmTheme";
      };
    };
  };
}
