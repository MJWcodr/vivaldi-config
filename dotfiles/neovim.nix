{ pkgs, ... }:

{
  home.packages = with pkgs; [
			neovim
			neovim-qt
			typos-lsp
			typstfmt
			tinymist
			nodePackages_latest.lua-fmt
			luajitPackages.lua-lsp
			gcc

			# Haskell
			haskellPackages.haskell-language-server
			haskellPackages.ghc
			haskellPackages.cabal-install
	];

  # Manage Neovim
  xdg.configFile.nvim = {
    source = ./neovim;
    recursive = true;
  };
}
