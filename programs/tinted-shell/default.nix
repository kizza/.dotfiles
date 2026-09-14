{ pkgs, lib, ... }:

let
  tintedShell = pkgs.stdenv.mkDerivation rec {
    pname = "tinted-shell";
    version = "1.0.0";

    srcs = [
      (pkgs.fetchFromGitHub {
        owner = "tinted-theming";
        name = pname;
        repo = "tinted-shell";
        rev = "839f96d22a5b3a702444b2b19513b2e751ff748a";
        sha256 = "yRFoqWanATVuxtNpw+cgORWY5MALnt131/yeCPPEk0I=";
      })
      ./themes
    ];

    sourceRoot = pname;

    # Copy my themes into the /scripts directory
    buildPhase = ''
      cp -r ../themes/. ./scripts/
    '';

    # Copy everything to $out
    installPhase = ''
      cp -r . $out
    '';

    meta = with lib; {
      description = "Install tinted-shell but with my custom themes";
    };
  };
in
{
  home = {
    file = {
      # Use activation below, to change permissions on file
      # ".config/tinted-theming/tinted-shell".source = tintedShell;
    };

    activation = {
      copyTintedShell = lib.hm.dag.entryAfter ["writeBoundary"] ''
        DIR="$HOME/.config/tinted-theming/tinted-shell"
        rm -rf "$DIR"
        mkdir -p "$DIR"
        cp -r ${tintedShell}/. $DIR
        find "$DIR" -type d -exec chmod 755 {} \;
        find "$DIR" -type f -exec chmod 644 {} \;

        # Recreating the directory dangles the active theme symlink, which points inside it.
        # base16-studio owns that link, so have it lay the theme back down — otherwise the next
        # thing to read the theme without an interactive shell first (sketchybar at boot) gets nothing.
        if [ -x "$HOME/base16-studio/bin/relink" ]; then
          "$HOME/base16-studio/bin/relink" || true
        fi
      '';
    };
  };
}
