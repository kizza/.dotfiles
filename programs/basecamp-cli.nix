{ pkgs, ... }:

let
  version = "0.7.2";

  platform =
    if pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64 then "darwin_arm64"
    else if pkgs.stdenv.hostPlatform.isDarwin then "darwin_amd64"
    else if pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAarch64 then "linux_arm64"
    else "linux_amd64";

  basecamp-cli = pkgs.stdenv.mkDerivation {
    pname = "basecamp-cli";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/basecamp/basecamp-cli/releases/download/v${version}/basecamp_${version}_${platform}.tar.gz";
      hash = "sha256-9OL+wk1iAKTwMnhkH+3R6WCKWWZ5RtbB/xpZ3oa9sYI=";
    };

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/bin
      install -m755 basecamp $out/bin/basecamp
    '';
  };
in
{
  home.packages = [
    basecamp-cli
  ];
}
