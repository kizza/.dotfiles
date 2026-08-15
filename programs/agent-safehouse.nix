{ config, pkgs, ... }:

let
  agent-safehouse = pkgs.stdenv.mkDerivation rec {
    pname = "agent-safehouse";
    version = "0.5.2";

    src = pkgs.fetchFromGitHub {
      owner = "eugene1g";
      repo = "agent-safehouse";
      rev = "v${version}";
      sha256 = "sha256-/ZsVyy65nDl6sSlsZ51vlSS6dYdZawerCJ00Hz1ZDPY=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp dist/safehouse.sh $out/bin/safehouse
      chmod +x $out/bin/safehouse
    '';

    meta = with pkgs.lib; {
      description = "Sandbox runner for AI agents using macOS sandbox-exec";
      homepage = "https://github.com/eugene1g/agent-safehouse";
      license = licenses.mit;
      platforms = platforms.darwin;
    };
  };
in
{
  home = {
    packages = [agent-safehouse];

    file.".config/agent-safehouse/local-overrides.sb".text = ''
      ;; Support nix home manager
      (allow file-read-metadata
        (home-subpath "/.nix-profile/bin")
      )

      (allow file-read*
        (subpath "/nix/var/nix/profiles")
      )
      (allow file-read-metadata
        (subpath "/nix/var/nix/profiles")
      )
      (allow process-exec
        (subpath "/nix/var/nix/profiles")
      )

      (allow file-read*
        (subpath "/nix/store")
      )
      (allow process-exec
        (subpath "/nix/store")
      )
    '';
  };
}
