{
  description = "A Nix-flake-based Go development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    inputs:
    let
      goVersion = 23;

      supportedSystems = [ "x86_64-linux" ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: {
        go = final."go_1_${toString goVersion}";
      };

      devShells = forEachSupportedSystem (
        { pkgs }: {
          default = pkgs.mkShell {
            packages = [
              # go (version is specified by overlay)
              pkgs.go

              # goimports, godoc, etc.
              pkgs.gotools

              # https://github.com/golangci/golangci-lint
              pkgs.golangci-lint
            ];
          };
        }
      );
    };
}
