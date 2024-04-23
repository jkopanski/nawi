{
  description = "Nats widgets";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, utils, haskellNix, nixgl }:
    let
      supportedSystems = [ "x86_64-linux" ];
    in
    utils.lib.eachSystem supportedSystems (system:
      let
        overlays = [
          nixgl.overlay
          haskellNix.overlay
          (final: prev: {
            nawi =
              final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc94";
                shell = {
                  tools = {
                    cabal = { };
                    cabal-hoogle = { };
                    fourmolu = { };
                    ghcid = { };
                    hlint = { };
                    haskell-language-server = { };
                  };
                  buildInputs =
                    # let
                    #   dev = final.writeShellScriptBin "dev" ''
                    #     ghcid \
                    #       --command="cabal repl exe:nawi" \
                    #       --run \
                    #       --setup ":set args [\"--config\", \"./config.dhall\", \"--dev\"]" \
                    #       --restart config.dhall \
                    #       --restart nawi.cabal \
                    #       --restart cabal.project
                    #   '';
                    # in
                    with pkgs; [
                      pkgs.nixgl.auto.nixGLDefault
                      # pkgs.nixgl.nixGLMesa
                      # pkgs.nixgl.nixVulkanMesa

                      jq
                      nixpkgs-fmt
                      wrapGAppsHook4
                   ];
                };
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.nawi.flake { };
      in
      flake // {
        packages.default = flake.packages."nawi:exe:nawi";
        formatter = pkgs.nixpkgs-fmt;
        legacyPackages = pkgs;
      });

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
      "https://famisoft.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "famisoft.cachix.org-1:sfEpFUBZqHUB7Ip4aALC20v3lGb5bnHvu5uR0QnDFmA="
    ];
    allow-import-from-derivation = "true";
  };
}
