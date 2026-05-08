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
    nixgl.packages.${pkgs.system}.nixGLIntel
  ];
}
