{
  description = "Synthetic_Data_Generation - project-local Python env (uv-managed), isolated from global home.nix/configuration.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.python312
            pkgs.uv
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            export UV_PYTHON="${pkgs.python312}/bin/python3"

            if [ ! -d .venv ]; then
              echo "No .venv found - running uv sync to create it..."
              uv sync
            fi

            echo "Synthetic_Data_Generation dev shell ready (uv-managed, project-local)."
            echo "Python: $(python3 --version 2>/dev/null || echo 'not on PATH until venv is activated')"
            echo "Activate: source .venv/bin/activate"
          '';
        };
      });
}
