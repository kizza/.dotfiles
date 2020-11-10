{ ... }:

{
  home = {
    file = {
      ".vim/syntax/dark.vim".text = builtins.readFile ./syntax/dark.vim;
      ".vim/syntax/gitcommit.vim".text = builtins.readFile ./syntax/gitcommit.vim;
      ".vim/syntax/light.vim".text = builtins.readFile ./syntax/light.vim;
      ".vim/syntax/nerdtree.vim".text = builtins.readFile ./syntax/nerdtree.vim;
      ".vim/syntax/typescript.vim".text = builtins.readFile ./syntax/typescript.vim;
    };
  };
}
