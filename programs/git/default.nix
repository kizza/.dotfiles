{ pkgs, ... }:

{
  home = {
    file.".gitconfig".text = ''
      ${builtins.readFile ./base}
      ${builtins.readFile ./alias}
      ${builtins.readFile ./colours}
    '';
    file.".gitignore".text = builtins.readFile ./ignore;
  };
}
