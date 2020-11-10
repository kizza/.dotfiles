{ pkgs, ... }:

{
  home = {
    file = {
      ".config/diff-so-fancy" = {
        source = pkgs.fetchFromGitHub {
          owner = "so-fancy";
          repo = "diff-so-fancy";
          rev = "19e55f6562e78c290ef7e47059e8dc73b26461c5";
          sha256 = "09rm9gq7yvwgaxvaa62smnrg3db3ikabvq6pp50k1q79x10bcw02";
        };
      };
    };
  };
}
