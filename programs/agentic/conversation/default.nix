{ pkgs, ... }:

# `conversation`: a session where speech is the whole reply. Keiran dictates with VoiceInk on Right
# Option and hears the agent through piper-server (programs/piper); the agent speaks for itself with
# `piper_say`. See conversation.py for how the pieces fit, and ../skills/speaking for how it talks.

let
  # Karabiner's shell has neither aerospace (self-installed to ~/.local/bin) nor the nix profile on PATH
  userPath = ''export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"'';

  speaking = ../skills/speaking;

  # The agent runs without skills, so the speaking skill travels inside its instructions: the skill
  # body with its frontmatter stripped, then the wording rules it points at.
  speakingBody = pkgs.runCommand "speaking.md" { } ''
    sed '1{/^---$/!q;};1,/^---$/d' ${speaking}/SKILL.md > $out
  '';

  instructions = pkgs.concatText "conversation-instructions.md" [
    ./instructions.md
    speakingBody
    "${speaking}/references/spoken-english.md"
  ];

  conversation = pkgs.writeShellApplication {
    name = "conversation";
    runtimeInputs = [ pkgs.uv ];
    text = ''
      ${userPath}
      exec uv run --no-project --python ${pkgs.python312}/bin/python3 \
        --with "prompt_toolkit==3.0.52" \
        python ${./conversation.py} \
          --instructions ${instructions} \
          --piper-url http://127.0.0.1:5100 \
          "$@"
    '';
  };

  # Karabiner runs this as Right Option goes down, before VoiceInk starts recording. Without a
  # conversation running it does nothing, so push-to-talk behaves as it always has.
  conversation-listen = pkgs.writeShellApplication {
    name = "conversation-listen";
    text = ''
      ${userPath}
      state="$HOME/.local/state/conversation"

      pid="$(cat "$state/pid" 2>/dev/null)" || exit 0
      kill -0 "$pid" 2>/dev/null || exit 0

      conversation_window="$(cat "$state/window")"
      focused_window="$(aerospace list-windows --focused --format '%{window-id}')"

      if [[ "$focused_window" != "$conversation_window" ]]; then
        echo "$focused_window" > "$state/return-to"
        aerospace focus --window-id "$conversation_window"
      fi

      kill -USR1 "$pid"
    '';
  };
in
{
  home.packages = [ conversation conversation-listen ];
}
