{
  description = "meme dma";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
  let
    inherit (nixpkgs.lib) substring;
    inherit (flake-utils.lib) eachDefaultSystem;

    version' = "0.1.0";
    localVersion = "${substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101")}.${self.shortRev or "dirty"}";
  in
  {
    overlays = rec {
      memedma = (final: prev: (with prev; {
        memedma = (stdenv.mkDerivation {
          name = "memedma";
          version = "${version'}+${localVersion}";
          src = ./.;

          nativeBuildInputs = [
            zig
          ];
          buildInputs = [
          ];
          propagatedBuildInputs = [
          ];

          installPhase = ''
            zig build -Drelease-safe -Dcpu=baseline --prefix $out install
          '';

          meta.mainProgram = "memedma";
        });
      }));
      default = memedma;
    };
  } // (eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          devshell.overlay
          self.overlays.default
        ];
      };
    in
    {
      devShells.default = pkgs.devshell.mkShell {
        imports = [ "${pkgs.devshell.extraModulesDir}/language/c.nix" ];

        language.c = with pkgs; rec {
          compiler = gcc;
          libraries = [
            gcc.cc.lib
          ];
          includes = libraries;
        };

        packages = with pkgs; [
          zig
        ];

        # env = [
        #   {
        #     name = "LDFLAGS";
        #     eval = "-L\${DEVSHELL_DIR}/lib";
        #   }
        # ];
      };

      packages = rec {
        inherit (pkgs) memedma;
        default = memedma;
      };
    }));
}
