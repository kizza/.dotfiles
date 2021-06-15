{ pkgs, ... }:

{
  home = {
    file.".gitconfig".text = ''
      ${builtins.readFile ./config}
      ${builtins.readFile ./alias}
      ${builtins.readFile ./colours}
    '';
    file.".gitignore".text = builtins.readFile ./ignore;
  };
}
