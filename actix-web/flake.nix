{
  description = "A nix flake for a Rust project using Actix-web framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      naerskLib = pkgs.callPackage naersk { };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
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

          pkgs.openssl

          pkgs.yarn
          pkgs.nodejs
          pkgs.pnpm
          pkgs.typescript
          pkgs.eslint
          pkgs.prettier
          pkgs.typescript-language-server
        ];

        nativeBuildInputs = [ pkgs.pkg-config ];

        # env.RUST_SRC_PATH =
        #   "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      };
      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;
      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;
    };
}
