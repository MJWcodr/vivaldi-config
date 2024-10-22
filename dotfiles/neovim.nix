{ pkgs, ... }:

{
  home.packages = with pkgs; [
			neovim
			neovim-qt
			typos-lsp
			typstfmt
			tinymist
			nodePackages_latest.lua-fmt
			gcc
	];

  # Manage Neovim
  xdg.configFile.nvim = {
    source = ./neovim;
    recursive = true;
  };
}
