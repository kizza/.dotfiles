let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  home-manager = import sources.home-manager { inherit pkgs; };
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    niv
    home-manager.home-manager
  ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${sources.nixpkgs}"
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  '';
  # bat cache --build
  # export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
}
