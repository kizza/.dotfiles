{ config, pkgs, edgePkgs, ... }:

# A single launchd agent that runs one command each morning. Home-manager owns the plist, so each
# generation replaces it rather than stacking another one up.

let
  runHour = 7;
  runMinute = 0;

  # The wake needs root, which home-manager hasn't got. So on a new machine, run wakeCommand below
  # by hand once — without it the job only fires if the mac is already awake at runHour. It sticks
  # (macOS keeps a single repeat slot, surviving reboots); `pmset -g sched` confirms, and the run
  # itself warns into the log if it ever goes missing.
  wakeTime = "06:58:00"; # A couple of minutes early, so the mac is up before launchd fires
  wakeDays = "MTWRFSU";
  wakeCommand = "sudo pmset repeat wakeorpoweron ${wakeDays} ${wakeTime}";

  location = "Melbourne, Australia";

  logFile = "${config.home.homeDirectory}/Library/Logs/morning-task.log";

  morning-task = pkgs.writeShellApplication {
    name = "morning-task";
    runtimeInputs = [ edgePkgs.claude-code pkgs.coreutils pkgs.gnugrep ];
    text = ''
      echo "=== $(date '+%Y-%m-%d %H:%M:%S %Z') ==="

      if ! /usr/bin/pmset -g sched | grep -q "repeating wakeorpoweron"; then
        echo "WARNING: no repeating wake — ${wakeCommand}"
      fi

      claude -p "What's the weather today in ${location}? Two sentences."

      echo
    '';
  };
in
{
  home.packages = [ morning-task ];

  launchd.agents.morning-task = {
    enable = true;
    config = {
      ProgramArguments = [ "${morning-task}/bin/morning-task" ];
      StartCalendarInterval = [{ Hour = runHour; Minute = runMinute; }];
      RunAtLoad = false;
      ProcessType = "Background";
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
      EnvironmentVariables.TERM = "dumb"; # launchd has no tty, and claude's deps ask tput for one
    };
  };
}
