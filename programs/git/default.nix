{ pkgs, ... }:

{
  home = {
    file.".gitconfig".text = ''
      ${builtins.readFile ./config}
      ${builtins.readFile ./alias}
      ${builtins.readFile ./colours}
      ${builtins.readFile ./delta.gitconfig}
    '';
    file.".gitignore".text = builtins.readFile ./ignore;
  };
}
