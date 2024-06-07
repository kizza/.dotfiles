{ pkgs, ... }:

{
  # "Contents cannot be represented as a nix string"
  # home = {
  #   file = {
  #     "/Applications/Alacritty.app/Contents/Resources/alacritty.icns".source = builtins.readFile ./alacritty.icns;
  #   };
  # };

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "screen-256color";
      };

      shell = {
        program = "zsh";
      #   args = [ "attach" ];
      };

      window = {
        decorations = "Transparent";
        startup_mode = "Maximized";
        padding = {
          x = 2;
          y = 18;
        };
        dynamic_padding = true;
      };

      # Custom keybindings (iTerm2 inspired)
      keyboard = {
        bindings = [
          { key= "K"; mods= "Command";       chars= "\\u0002\\u006b"; } # Ctrl + b, k
          { key= "T"; mods= "Command";       chars= "\\u0002\\u0063"; } # Ctrl + b, c
          { key= "W"; mods= "Command";       chars= "\\u0002\\u0078"; } # Ctrl + b, x
          { key= "D"; mods= "Command";       chars= "\\u0002\\u0025"; } # Ctrl + b, %
          { key= "D"; mods= "Command|Shift"; chars= "\\u0002\\u0022"; } # Ctrl + b, "
          { key= "{"; mods= "Command|Shift"; chars= "\\u0002\\u0070"; } # Ctrl + b, p
          { key= "}"; mods= "Command|Shift"; chars= "\\u0002\\u006E"; } # Ctrl + b, n

          # Pass <C-S-f> to neovim (this is mapped to <leader>fu
          { key= "F"; mods= "Control|Shift"; chars= ",fu"; }
          { key= "F"; mods= "Command|Shift"; chars= ",pp"; }
        ];
      };

      font = {
        size = 18;
        normal = {
          family = "SauceCodePro Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "SauceCodePro Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "SauceCodePro Nerd Font Mono";
          style = "Italic";
        };
        offset = {
          x = 0;
          y = 8;
        };
        glyph_offset = {
          x = 0;
          y = 6;
        };
      };
    };
  };
}
