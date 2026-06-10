{
  description = "A Nix-flake-based python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.python3
          pkgs.python3Packages.pip
          pkgs.python3Packages.virtualenv
          pkgs.python3Packages.setuptools
          pkgs.python3Packages.wheel

          # Development tools
          pkgs.python3Packages.black
          pkgs.python3Packages.flake8
          pkgs.python3Packages.mypy
          pkgs.python3Packages.pytest
          pkgs.python3Packages.isort

          # Language server
          pkgs.python3Packages.python-lsp-server

          # Common Python packages
          pkgs.python3Packages.requests
          pkgs.python3Packages.numpy
          pkgs.python3Packages.pandas
        ];

        shellHook = ''
          # Create virtual environment if it doesn't exist
          if [ ! -d ".venv" ]; then
            echo "Creating virtual environment..."
            python -m venv .venv
          fi

          # Activate virtual environment
          source .venv/bin/activate

          # Upgrade pip
          pip install --upgrade pip
        '';
      };
    };
}
