{
  description = "A Nix-flake-based Bash development environment for bash";
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
          pkgs.bash
          pkgs.shellcheck
          pkgs.shfmt
          pkgs.bash-language-server
          pkgs.bats
          pkgs.jq
        ];
        shellHook = ''
          # Bash development environment ready
        '';
      };
    };
}
