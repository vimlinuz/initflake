{
  description = "A Nix-flake-based solana development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      nixpkgs,
      naersk,
      rust-overlay,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];

      pkgs = import nixpkgs {
        inherit system overlays;
      };

      naerskLib = pkgs.callPackage naersk { };

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

          pkgs.rust-bin.stable.latest.default # Stable rust, default profile. If not sure, always choose this.
          # rust-bin.beta.latest.default   # Wanna test beta compiler.
          # rust-bin.stable.latest.minimal # I don't need anything other than rustc, cargo, rust-std. Bye rustfmt, clippy, etc.
          # rust-bin.beta.latest.minimal
          # GUI dialog tool for build notifications
          pkgs.zenity

          pkgs.pnpm
          pkgs.yarn
          pkgs.prettier
        ];

        env.RUSTFLAGS = "-C link-arg=-Wl,-rpath,${nixpkgs.lib.makeLibraryPath runTimeDeps}";

        shellHook = ''
          # if they are manually installed need to set the path
          export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
          export PATH="$HOME/.cargo/bin:$PATH"
        '';
      };
      formatter = pkgs.rustfmt;
    };
}
