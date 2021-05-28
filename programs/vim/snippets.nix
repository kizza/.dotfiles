{ ... }:

{
  home = {
    file = {
      ".vim/snippets/eruby.snippets".text = builtins.readFile ./snippets/eruby.snippets;
      ".vim/snippets/ruby.snippets".text = builtins.readFile ./snippets/ruby.snippets;
      ".vim/snippets/javascript.snippets".text = builtins.readFile ./snippets/javascript.snippets;
    };
  };
}
