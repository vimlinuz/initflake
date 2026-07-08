{
  description = "A Nix-flake-based C/C++ development environment";
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
          # clang-tools should come before the clang I read it some where
          # the clang does not matters because you will ditch it for the gcc or g++ I know
          pkgs.clang-tools
          pkgs.libcxx
          pkgs.clang
          pkgs.clang-tools
          pkgs.gcc
          pkgs.cmake
          # pkgs.ninja
          # pkgs.gnumake
          pkgs.gdb
          # pkgs.valgrind
          pkgs.bear
          pkgs.glibc.dev
        ];
        nativeBuildInputs = [ pkgs.pkg-config ];
        env = {
          CC = "gcc";
          CXX = "g++";
        };
        shellHook = ''
          export CC=clang
          export CXX=clang++
          export C_INCLUDE_PATH=${pkgs.glibc.dev}/include
          export CPLUS_INCLUDE_PATH=${pkgs.glibc.dev}/include
        '';
      };
    };
}
