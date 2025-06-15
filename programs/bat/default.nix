{ pkgs, ... }:

{
  home = {
    file.".config/bat/syntaxes/GitOneline.sublime-syntax".text = builtins.readFile ./syntaxes/GitOneline.sublime-syntax;
    file.".config/bat/themes/my-base16.tmTheme".text = builtins.readFile ./themes/my-base16.tmTheme;
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "my-base16";
    };
  };
}
