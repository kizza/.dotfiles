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
        decorations = "transparent";
        startup_mode = "Maximized";
        padding = {
          x = 2;
          y = 18;
        };
        dynamic_padding = true;
      };

      # Custom keybindings (iTerm2 inspired)
      key_bindings = [
        { key= "K";           mods= "Command";          chars= "\\x02\\x6b"; }
        { key= "T";           mods= "Command";          chars= "\\x02\\x63"; }
        { key= "W";           mods= "Command";          chars= "\\x02\\x78"; }
        { key= "D";           mods= "Command";          chars= "\\x02\\x25"; }
        { key= "D";           mods= "Command|Shift";    chars= "\\x02\\x22"; }
        { key= "LBracket";    mods= "Command|Shift";    chars= "\\x02\\x70"; }
        { key= "RBracket";    mods= "Command|Shift";    chars= "\\x02\\x6e"; }

        # Pass <C-S-f> to neovim (this is mapped to <leader>fu
        { key= "F";           mods= "Control|Shift";    chars= ",fu"; }
        { key= "F";           mods= "Command|Shift";    chars= ",pp"; }
      ];

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
