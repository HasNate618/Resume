{
  description = "Dev environment for building and editing the LaTeX resume";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            texlive.combined.scheme-full
            zathura
          ];

          shellHook = ''
            echo "Resume dev shell ready. Run: latexmk -pdf -interaction=nonstopmode Resume.tex"
          '';
        };
      });
}
