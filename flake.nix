{
  description = "Middleman development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.libffi
            pkgs.nodejs_24
            pkgs.ruby_3_4
          ];
          shellHook = ''
            # @SEE: https://github.com/NixOS/nixpkgs/issues/225012
            GEM_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/gem/ruby/${builtins.baseNameOf pkgs.ruby_3_4}"
            export GEM_HOME

            GEM_PATH="$GEM_HOME''${GEM_PATH:+:$GEM_PATH}"
            export GEM_PATH

            [ -d "$GEM_HOME/bin" ] && case ":$PATH:" in
            *:"$GEM_HOME/bin":*) ;;
            *)
              PATH="$PATH:$GEM_HOME/bin"
              export PATH
              ;;
            esac

            PS1='\u@middleman-dev:\w/ > '
            export PS1
          '';
        };
      });
    };
}
