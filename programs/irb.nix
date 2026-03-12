{ pkgs, ... }:

{
  home.file.".irbrc".text = ''
    IRB.conf[:USE_MULTILINE] = true
    IRB.conf[:USE_RELINE] = false
    IRB.conf[:USE_READLINE] = false

    if defined?(Reline::Face)
      black   = "##{ENV['BASE16_COLOR_00_HEX']}" || "#00ff00"   # fallback
      grey   = "##{ENV['BASE16_COLOR_01_HEX']}" || "#00ff00"   # fallback
      accent = "##{ENV['BASE16_COLOR_0E_HEX']}" || "#ff0000"  # blue-ish

      Reline::Face.config(:completion_dialog) do |conf|
        # Main unselected items in the menu
        conf.define :default, foreground: :white, background: black

        # Currently highlighted / selected item
        conf.define :enhanced, foreground: black, background: accent

        # Scrollbar on the right (if the list is long)
        conf.define :scrollbar,
                    foreground: grey,
                    background: :black

        # Optional: scrollbar thumb (the moving part)
        # conf.define :scrollbar_thumb, foreground: :cyan, background: :black
      end
    end
  '';
}
