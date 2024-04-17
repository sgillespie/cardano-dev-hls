{
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    iohkNix.url = "github:input-output-hk/iohk-nix";
    chap = {
      url = "github:intersectmbo/cardano-haskell-packages?ref=repo";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, iohkNix, ... }@attrs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = builtins.attrValues (iohkNix.overlays) ++ [
          haskellNix.overlay

          (final: prev: {
            cabalProject =
              final.haskell-nix.cabalProject' {
                src = ./.;
                compiler-nix-name = "ghc96";

                inputMap = { "https://chap.intersectmbo.org/" = attrs.chap; };

                # This is used by `nix develop .` to open a shell for use with
                # `cabal`, `hlint` and `haskell-language-server`
                shell.tools = {
                  cabal = {};
                  fourmolu = {};
                  hlint = {};
                  haskell-language-server = {};
                };

                # Non-Haskell shell tools go here
                shell.buildInputs = with pkgs; [
                  nixpkgs-fmt
                ];
              };
          })
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };

        flake = pkgs.cabalProject.flake { };

      in
        flake);
}
