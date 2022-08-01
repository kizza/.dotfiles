{ ... }:

{
  home = {
    file.".config/nvim/coc-settings.json".text = builtins.readFile ./coc-settings.json;
    file.".vim/coc-settings.json".text = builtins.readFile ./coc-settings.json;

    file.".vim/plugs.vim".text = builtins.readFile ./coc.vim;
  };
}
