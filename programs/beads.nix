{ config, pkgs, ... }:

let
  sources = import ../nix/sources.nix;
  pkgsGo = import sources.nixpkgs-go { inherit (pkgs.stdenv.hostPlatform) system; };

  beads = (pkgs.buildGoModule.override {
    go = pkgsGo.go_latest; # Use newer nixpkgs pin for Go >= 1.25.8
  }) rec {
    pname = "beads";
    version = "0.61.0";

    src = pkgs.fetchFromGitHub {
      owner = "steveyegge";
      repo = "beads";
      rev = "v${version}";
      sha256 = "sha256-3V0FrqJ/ajDlMyquAZo1jUmYXF4TneBoh3VTsjvwyq0=";
    };

    vendorHash = "sha256-wcFAvGoDR9IYckWRMqPqCgPSUKmoYYyYg0dfNGDI6Go=";

    subPackages = [ "cmd/bd" ];

    doCheck = false;  # Tests require dolt DB and git and have env-specific assumptions

    meta = with pkgs.lib; {
      description = "Beads - lightweight GitHub memory / task tool";
      homepage = "https://github.com/steveyegge/beads";
      license = licenses.mit; # check repo to confirm
      platforms = platforms.all;
    };
  };

  dolt = (pkgs.buildGoModule.override {
    go = pkgsGo.go_latest; # Use newer nixpkgs pin for Go >= 1.25.8
  }) rec {
    pname = "dolt";
    version = "1.59.10";

    src = pkgs.fetchFromGitHub {
      owner = "dolthub";
      repo = "dolt";
      rev = "v${version}";
      hash = "sha256-DfocUOHpPdNeMcL7kVm7ggm2cVgWp/ifvCFyFosxhcs=";
    };

    modRoot = "./go";
    subPackages = [ "cmd/dolt" ];
    vendorHash = "sha256-yZ+q4KNfIiR2gpk10dpZOMiEN3V/Lk/pzhgaqp7lKag=";
    proxyVendor = true;
    doCheck = false;

    meta = with pkgs.lib; {
      description = "Relational database with version control and CLI a-la Git";
      homepage = "https://github.com/dolthub/dolt";
      license = licenses.asl20;
    };
  };
in
{
  home.packages = [
    beads
    dolt
  ];
}
