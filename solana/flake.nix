{
  description = "A Nix-flake-based solana development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
      rust-overlay,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];

      pkgs = import nixpkgs {
        inherit system overlays;
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      naerskLib = pkgs.callPackage naersk { };

      rust-toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      runTimeDeps = [
        pkgs.libxkbcommon

        # GPU backend
        pkgs.vulkan-loader
        pkgs.libGL

        # Window system
        pkgs.wayland
        pkgs.libx11
        pkgs.libxcursor
        pkgs.libxi
        pkgs.zenity
      ];
    in
    {
      packages.${system}.default = naerskLib.buildPackage {
        src = ./.;
        buildInputs = [ pkgs.openssl ] ++ runTimeDeps;
        nativeBuildInputs = [ pkgs.pkg-config ];
      };

      devShells.${system}.default = pkgs.mkShell {

        packages = [
          pkgs.openssl

          pkgs.cargo-watch
          # GUI dialog tool for build notifications
          pkgs.zenity

          # rust-toolchain
          pkgs.rust-bin.stable.latest.default # Stable rust, default profile. If not sure, always choose this.
          # rust-bin.beta.latest.default   # Wanna test beta compiler.
          # rust-bin.stable.latest.minimal # I don't need anything other than rustc, cargo, rust-std. Bye rustfmt, clippy, etc.
          # rust-bin.beta.latest.minimal

          pkgs.pnpm
          pkgs.yarn
          pkgs.prettier
          pkgs.nodejs
        ];

        env.RUSTFLAGS = "-C link-arg=-Wl,-rpath,${nixpkgs.lib.makeLibraryPath runTimeDeps}";

        shellHook = ''
          # if they are manually installed need to set the path
          export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
          export PATH="$HOME/.cargo/bin:$PATH"
        '';
      };
      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;
      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;
    };
}
