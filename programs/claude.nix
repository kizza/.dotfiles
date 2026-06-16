{ pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-agent-acp
  ];

  programs.claude-code = {
    enable = true;
    skills = ./agentic/skills;
  };
}
