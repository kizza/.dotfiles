{ config, nixgl, pkgs, ... }:

{
  targets.genericLinux = {
    enable = true;
    nixGL = {
      packages = nixgl.packages;
      defaultWrapper = "mesa";
      installScripts = [ "mesa" ];
    };
  };

  home.packages = [
    nixgl.packages.${pkgs.stdenv.hostPlatform.system}.nixGLIntel
  ];
}
