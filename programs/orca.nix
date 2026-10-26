{ pkgs, ... }:

let
  version = "1.4.241";

  # stablyai/orca isn't in nixpkgs (nixpkgs' `orca` is the GNOME screen reader), so this wraps the signed
  # release build. Home Manager links it into `~/Applications/Home Manager Apps`; bump `version` and `hash`
  # to upgrade, as the app's own updater can't write to the store.
  orca = pkgs.stdenv.mkDerivation {
    pname = "orca-ide";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/stablyai/orca/releases/download/v${version}/Orca-${version}-arm64-mac.zip";
      hash = "sha256-7diwnNBRC+1Y2JORpi4qQzt7LkxyBnjIynpjy0yAjVY=";
    };

    nativeBuildInputs = [ pkgs.unzip ];
    sourceRoot = ".";

    # Stripping or patching would break the bundle's code signature.
    dontFixup = true;

    installPhase = ''
      mkdir -p $out/Applications
      cp -R Orca.app $out/Applications/
    '';

    meta.platforms = [ "aarch64-darwin" ];
  };
in
{
  home.packages = [
    orca
  ];
}
