{ pkgs, ... }:

with import <nixpkgs> {};

let
  git-secrets = stdenv.mkDerivation rec {
    pname = "git-secrets";
    version = "1.3.0";

    # buildInputs = with pkgs; [
    #   git-secrets
    # ];
    # dontUnpack = true;

    src = pkgs.fetchFromGitHub {
      owner = "awslabs";
      name = pname;
      repo = pname;
      rev = version;
      sha256 = "10lnxg0q855zi3d6804ivlrn6dc817kilzdh05mmz8a0ccvm2qc7";
    };

    installPhase = ''
      make install
    '';

    # Copy everything to $out
    fixupPhase = ''
      echo "Fixup"
      git secrets --register-aws
    '';

    meta = with lib; {
      description = "Install base16-shell but with my custom themes";
    };
  };
in
{
  home = {
    packages = [
      git-secrets
    ];
  };
}

