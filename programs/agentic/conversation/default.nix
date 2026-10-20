{ pkgs, ... }:

# `conversation`: a session where speech is the whole reply. Keiran types, and hears the agent through
# piper-server (programs/piper); the agent speaks for itself with `piper_say`. See conversation.py for
# how the pieces fit, and ../skills/speaking for how it talks.

let
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
      exec uv run --no-project --python ${pkgs.python312}/bin/python3 \
        --with "prompt_toolkit==3.0.52" \
        python ${./conversation.py} \
          --instructions ${instructions} \
          --piper-url http://127.0.0.1:5100 \
          "$@"
    '';
  };
in
{
  home.packages = [ conversation ];
}
