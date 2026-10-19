{ config, pkgs, ... }:

# A Piper server that keeps the voice loaded and plays what it's sent, so `piper_say` returns at once
# and the first word lands ~0.2s later — instead of ~1s loading the model and starting ffplay per
# line. It speaks one utterance at a time, so agents queue rather than talk over each other.
#
# nixpkgs' piper-tts is Linux-only, so uv pulls the pinned packages from PyPI into its cache on first
# start; nix still supplies the python and uv themselves.

let
  port = 5100; # 5000 is macOS' AirPlay Receiver; bin/piper_say defaults to this too
  voicesDirectory = "${config.home.homeDirectory}/.config/piper/voices";
  logFile = "${config.home.homeDirectory}/Library/Logs/piper-server.log";

  piper-server = pkgs.writeShellApplication {
    name = "piper-server";
    runtimeInputs = [ pkgs.uv ];
    text = ''
      exec uv run --no-project --python ${pkgs.python312}/bin/python3 \
        --with "piper-tts==1.4.2" --with "sounddevice==0.5.6" \
        python ${./server.py} \
          --port ${toString port} \
          --voices-directory "${voicesDirectory}" \
          --default-voice alba-medium
    '';
  };
in
{
  home.packages = [ piper-server ];

  launchd.agents.piper-server = {
    enable = true;
    config = {
      ProgramArguments = [ "${piper-server}/bin/piper-server" ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30; # A missing voice would otherwise restart it every 10s
      ProcessType = "Interactive"; # Latency matters more than battery here
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };
}
