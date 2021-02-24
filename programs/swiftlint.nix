{ pkgs, ... }:

let
  swiftlint = pkgs.callPackage (import ../packages/swiftlint) {};
in
{
  home.packages = with pkgs; [
    swiftlint
    swiftformat
  ];
}
