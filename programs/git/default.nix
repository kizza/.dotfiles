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

    # Applies to every repo via core.hooksPath in ./config — no per-repo
    # `git secrets --install` step to forget, unlike the old init.templateDir setup.
    file.".config/git/hooks/pre-commit" = {
      source = ./hooks/pre-commit;
      executable = true;
    };
  };
}
