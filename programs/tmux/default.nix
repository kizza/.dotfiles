{ ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = builtins.readFile ./tmux.conf;
    newSession = true;
    plugins = [];
    terminal = "screen-256color";
  };
}
