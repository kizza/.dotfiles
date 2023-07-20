{ pkgs, ... }:

{
  home = {
    file = {
      ".gvimrc".text = builtins.readFile ./.gvimrc;
    };
  };
}
