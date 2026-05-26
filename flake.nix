{
  description = "Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixgl,
    ...
  }:
    let
      allowUnfree = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
        "1password-cli"
        "claude-code"
        "github-copilot-cli"
      ];

      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowUnfree;
      };
    in
    {
      homeConfigurations = {
        "keiran@Keirans-MacBook-Pro.local" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = mkPkgs "aarch64-darwin";
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

        "keiran@machina" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          extraSpecialArgs = {
            inherit nixgl; # Pass nixgl to nixgl.nix
          };

          modules = [
            (
              {config, ...}: {
                xdg.enable = true;

                home.username = "keiran";
                home.homeDirectory = "/home/keiran";

                services.ollama = {
                  enable = true;
                  host = "127.0.0.1";
                };

                home.packages = with pkgs; [
                  ncdu
                ];

                programs = {
                  firefox = {
                    enable = true;
                    configPath = "${config.xdg.configHome}/mozilla/firefox";
                  };
                };
              }
            )
            ./home.nix
            ./programs/nixgl.nix
            ./programs/hyprlnd.nix
            ./programs/ghostty-wrapped.nix
          ];
        };

        "ava@machina" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          extraSpecialArgs = {
            inherit nixgl; # Pass nixgl to nixgl.nix
          };

          modules = [
            (
              {config, ...}: {
                xdg.enable = true;
                home.username = "ava";
                home.homeDirectory = "/home/ava";

                home.packages = with pkgs; [
                  rclone
                ];

                programs = {
                  firefox = {
                    enable = true;
                    configPath = "${config.xdg.configHome}/mozilla/firefox";
                  };
                };
              }
            )
            ./home.nix
            ./programs/nixgl.nix
            ./programs/hyprlnd.nix
            ./programs/ghostty-wrapped.nix
          ];
        };

        "holly@machina" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          extraSpecialArgs = {
            inherit nixgl; # Pass nixgl to nixgl.nix
          };

          modules = [
            (
              {config, ...}: {
                xdg.enable = true;
                home.username = "holly";
                home.homeDirectory = "/home/holly";

                programs = {
                  firefox = {
                    enable = true;
                    configPath = "${config.xdg.configHome}/mozilla/firefox";
                  };
                };
              }
            )
            ./home.nix
            ./programs/nixgl.nix
            ./programs/hyprlnd.nix
            ./programs/ghostty-wrapped.nix
          ];
        };
      };
    };
}
