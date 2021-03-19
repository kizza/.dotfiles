{ pkgs, ... }:

{
  home = {
    file = {
      ".config/diff-so-fancy" = {
        source = pkgs.fetchFromGitHub {
          owner = "so-fancy";
          repo = "diff-so-fancy";
          rev = "93f360bd0c7f86d423bc2ade391bcde6109c95ae";
          sha256 = "0q2mcg26kz632sglxz8x8z6ib4wy1hvw898pix978m0dw28gpygz";
        };
      };
    };
  };
}
