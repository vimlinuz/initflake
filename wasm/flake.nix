{
  description = "A nix flake for wasm projects in rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
  };

  outputs =
    { nixpkgs, naersk, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      naerskLib = pkgs.callPackage naersk { };
    in
    {
      packages.${system}.default = naerskLib.buildPackage {
        src = ./.;
        buildInputs = [ pkgs.openssl ];
        nativeBuildInputs = [ pkgs.pkg-config ];
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.rustc
          pkgs.cargo
          pkgs.rust-analyzer
          pkgs.clippy
          pkgs.cargo-watch
          pkgs.rustfmt

          pkgs.nodejs
          pkgs.pnpm
          pkgs.typescript
          pkgs.eslint
          pkgs.prettier
          pkgs.typescript-language-server

          pkgs.wasm-pack
          pkgs.rocmPackages.llvm.lld
        ];

        nativeBuildInputs = [ pkgs.pkg-config ];
      };
      formatter = [
        pkgs.rustfmt
        pkgs.prettier
      ];

    };
}
