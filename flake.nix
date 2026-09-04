{
  description = "Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-edge.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Keep hunk >= 0.18.0: its bun2nix dependency evaluates nixpkgs for every
    # system it declares, and only from 0.18.0 does that list (nix-systems/triplet)
    # drop x86_64-darwin — which nixpkgs 26.11 refuses to evaluate at all.
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-edge,
    home-manager,
    nixgl,
    hunk,
    herdr,
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

      mkEdgePkgs = system: import nixpkgs-edge {
        inherit system;
        config.allowUnfreePredicate = allowUnfree;
      };
    in
    {
      homeConfigurations = {
        "keiran@Keirans-MacBook-Pro.local" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = mkPkgs "aarch64-darwin";

          # Pass edge packages downward
          extraSpecialArgs = {
            edgePkgs = mkEdgePkgs "aarch64-darwin";
          };

          modules = [
            {
              imports = [
                hunk.homeManagerModules.default
              ];
              programs.hunk = {
                enable = true;
                # enableGitIntegration = true; # Optional: set hunk as default git pager
                # settings = {
                #   theme = "graphite";
                #   mode = "split";
                #   line_numbers = true;
                # };
              };
            }
            {
              programs.herdr = {
                enable = true;
                package = herdr.packages.aarch64-darwin.default;
                settings = {
                  ui.agent_panel_sort = "spaces";
                  theme = {
                    name = "terminal";
                    custom = {
                      accent = "#A3B8EF";
                      surface0 = "#201F1F";
                      surface1 = "#EFA6A2";
                      surface_dim = "#263044";
                      overlay0 = "#776A6A";
                      overlay1 = "#A3B8EF";
                      text = "#A3B8EF";
                      subtext0 = "#776A6A";
                    };
                  };
                  keys = {
                    prefix = "ctrl+b";

                    # Tab navigation (tmux: M-{ / M-})
                    # previous_tab = "alt+shift+bracketleft";
                    # next_tab = "alt+shift+bracketright";

                    # Navigate...
                    goto = "prefix+w"; # all windows
                    workspace_picker = "prefix+s"; # workspaces
                    # focus_agent = "prefix+a+1..9"; # agents
                    settings = "prefix+;"; # Settings

                    # New tab (tmux: prefix c)
                    new_tab = "prefix+c";

                    # Pane splits (tmux: prefix " and prefix %)
                    split_horizontal = "prefix+quote";
                    split_vertical = "prefix+percent";

                    # Pane navigation (tmux: C-h/j/k/l, no prefix)
                    focus_pane_left = "ctrl+h";
                    focus_pane_down = "ctrl+j";
                    focus_pane_up = "ctrl+k";
                    focus_pane_right = "ctrl+l";
                  };
                };
              };
            }
            {
              home.username = "keiran";
              home.homeDirectory = "/Users/keiran";
              home.packages = with pkgs; [
                (pkgs.writeShellScriptBin "python3" ''
                  /Library/Developer/CommandLineTools/usr/bin/python3 "$@" # Call built-in directly (python3 stubs to xcrun which nix provides and breaks)
                '')
                _1password-cli
                awscli2
                bun
                btop
                cargo
                # cmake
                colima
                coreutils
                ffmpeg
                gh
                gh-dash
                # ghostty
                nmap
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
            ./programs/basecamp-cli.nix
            ./programs/claude.nix
            # ./programs/agent-safehouse.nix
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

          # Pass edge packages downward
          extraSpecialArgs = {
            edgePkgs = mkEdgePkgs "x86_64-linux";
          };

          modules = [
            {
              home.username = "keiran";
              home.homeDirectory = "/home/keiran";
              home.packages = with pkgs; [
                cloudflared
              ];
            }
            ./home.nix
            ./programs/opencode.nix
          ];
        };

        "keiran@machina" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          # Pass edge packages downward
          extraSpecialArgs = {
            inherit nixgl; # Pass nixgl to nixgl.nix
            edgePkgs = mkEdgePkgs "x86_64-linux";
          };

          modules = [
            (
              {config, ...}: {
                xdg.enable = true;

                home.username = "keiran";
                home.homeDirectory = "/home/keiran";

                services.ollama = {
                  enable = true;
                  host = "172.17.0.1"; # docker host
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
            ./programs/opencode.nix
          ];
        };

        "ava@machina" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = mkPkgs "x86_64-linux";

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
          pkgs = mkPkgs "x86_64-linux";

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
