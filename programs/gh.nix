{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
    extensions = with pkgs; [ github-copilot-cli ];
  };
}
