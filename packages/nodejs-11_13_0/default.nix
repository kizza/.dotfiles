{ stdenv }:
stdenv.mkDerivation rec {
  name = "nodejs-11_13_0";
  version = "11.13.0";
  src = builtins.fetchTarball {
    url = if builtins.currentSystem == "x86_64-darwin"
      then "https://nodejs.org/dist/v11.13.0/node-v${version}-darwin-x64.tar.gz"
      else "https://nodejs.org/dist/v11.13.0/node-v${version}-linux-x64.tar.gz";
  };
  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
  '';
}
