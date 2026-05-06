{
  description = "Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixgl = {
    #   url = "github:nix-community/nixGL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
    # nixgl,
  }:
    {
      homeConfigurations = {
        "keiran@Keirans-MacBook-Pro.local" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            {
              home.username = "keiran";
              home.homeDirectory = "/Users/keiran";
              home.packages = with pkgs; [
                awscli2
                bun
                btop
                # cmake
                colima
                coreutils
                # ffmpeg
                gh
                gh-dash
                # ghostty
                overmind
                ruby_3_4
                rustc
                solargraph
                television
                # yt-dlp
              ];
            }
            ./home.nix
            ./programs/aerospace.nix
            ./programs/agent-safehouse.nix
            # ./programs/beads.nix
            ./programs/jankyborders.nix
            ./programs/sketchybar
            # ./programs/java.nix
            ./programs/irb.nix
            ./programs/gh.nix
            ./programs/ghostty.nix
            ./programs/karabiner
            # ./programs/macvim
            ./programs/opencode.nix
          ];
        };

        "keiran@debby" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            {
              home.username = "keiran";
              home.homeDirectory = "/home/keiran";
              home.packages = with pkgs; [
                cloudflared
              ];
            }
            ./home.nix
          ];
        };
      };
    };
}
