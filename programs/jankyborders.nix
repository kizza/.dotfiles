{ pkgs, ... }:

{
  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 8.0;
      hidpi = "off";
      # active_color = "0xffD699B6"; # Magenta
      active_color = "0xff7FBBB3"; # Blue
      inactive_color = "0x00eeeeee";
    };
  };
}
