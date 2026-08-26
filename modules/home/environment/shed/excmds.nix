{ ... }:
{
  programs.shed = {
    functions = {
      ask = ''
        local line
        local prompt="$*"

        if ! [ -t 0 ]; then
          line="$(thru)"
        fi

        if [ -z "$line" ]; then
          claude -p "This prompt is being given by a user who is asking you to complete a shell command. Your response should be given in the form of a single POSIX-compatible shell command, unformatted (no markdown, just raw text) and nothing else. This response will replace the user's current line, so it should be something that can be executed right away. Suggest a shell command based on the user's request: $1"
        else
          claude -p "This prompt is being given by a user who is asking you to complete a shell command. Your response should be given in the form of a single POSIX-compatible shell command, unformatted (no markdown, just raw text) and nothing else. This response will replace the user's current line, so it should be something that can be executed right away. The user has an incomplete command in the buffer, your response should complete the following command: \`$line\` Suggest a shell command based on the user's request: $1"
        fi
      '';
    };
    exCommands = {
      ask = "%!ask";
      subsh = "normal!ggO(<ESC>Go)<ESC>v%=";
      brace = "normal!ggO{<ESC>Go}<ESC>v%=";
    };
  };
}
