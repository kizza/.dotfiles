{ pkgs, ... }:

{

  home.file.".gitignore".text = builtins.readFile ./programs/git/gitignore;
  home.file.".gitconfig".text = builtins.readFile ./programs/git/gitconfig;

  # programs.git = {
  #   enable = true;
  #   userName = "Keiran O'Leary";
  #   userEmail = "hello@keiranoleary.com";
  #   aliases = {
  #     # ad = "add";
  #     amend = "commit --amend --no-edit";
  #     br = "branch";
  #     ch = "checkout";
  #     # cm = "commit";
  #     # d = "diff";
  #     discard = "checkout --";
  #     fixup = "commit --fixup";
  #     pl = "pull --rebase";
  #     pu = "push";
  #     # s = "status";
  #     since-master = "diff --name-only origin/master";
  #     # unstage = "reset HEAD";
  #     wipe = "reset --hard HEAD";
  #   };
  #   ignores = [ ".DS_Store" "*.swp" ];
  # };
}
