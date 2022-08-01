{ pkgs, ... }:

{
  actionmenu = pkgs.vimUtils.buildVimPlugin {
    name = "actionmenu";
    src = pkgs.fetchFromGitHub {
      owner = "kizza";
      repo = "actionmenu.nvim";
      rev = "7a75af97d686bd241879afebb5aa21ee5634e397";
      sha256 = "1c4fkzwa4bbv5iszndzylsh1wj7mkqnfa32s1hq96a20wfmc2mrh";
    };
  };

  replace-with-register = pkgs.vimUtils.buildVimPlugin {
    name = "ReplaceWithRegister";
    src = pkgs.fetchFromGitHub {
      owner = "vim-scripts";
      repo = "ReplaceWithRegister";
      rev = "832efc23111d19591d495dc72286de2fb0b09345";
      sha256 = "0mb0sx85j1k59b1zz95r4vkq4kxlb4krhncq70mq7fxrs5bnhq8g";
    };
  };

  vim-buftabline = pkgs.vimUtils.buildVimPlugin {
    name = "vim-buftabline";
    src = pkgs.fetchFromGitHub {
      owner = "ap";
      repo = "vim-buftabline";
      rev = "635150f43fb430876d15dbae1a7b6363cadfea35";
      sha256 = "1md3w0z3pcn2nfdp9kcj3n0bdm3kjx5f95101m1f61jy4aq8qfsd";
    };
  };
}
