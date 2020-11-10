{ pkgs, ... }:

{
  home = {
    file = {
      ".config/base16-shell" = {
        source = pkgs.fetchFromGitHub {
          owner = "chriskempson";
          repo = "base16-shell";
          rev = "ce8e1e540367ea83cc3e01eec7b2a11783b3f9e1";
          sha256 = "1yj36k64zz65lxh28bb5rb5skwlinixxz6qwkwaf845ajvm45j1q";
        };
      };
    };
  };
}
