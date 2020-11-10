{ pkgs, ... }:

{
  home = {
    file = {
      ".config/karabiner/karabiner.json".text = builtins.readFile ./karabiner.json;
    };
  };
}
