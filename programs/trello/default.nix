{ pkgs, ... }:

let
  trello = pkgs.writeShellApplication {
    name = "trello";
    runtimeInputs = [ pkgs.curl pkgs.jq pkgs.gnugrep ];
    text = builtins.readFile ./trello.sh;
  };
in
{
  home.packages = [ trello ];
}
