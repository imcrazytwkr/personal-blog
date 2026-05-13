{
  description = "Middleman development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: genAttrs supportedSystems (system: f system);
    in
    {
      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixfmt
      );
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.libffi
              pkgs.nodejs_24
              pkgs.ruby_3_4
            ];
            shellHook = ''
              # @SEE: https://github.com/NixOS/nixpkgs/issues/225012
              GEM_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/gem/ruby/${builtins.baseNameOf pkgs.ruby_3_4}"
              export GEM_HOME

              GEM_PATH="$\{GEM_PATH:+:}$GEM_HOME"
              export GEM_PATH

              [ -d "$GEM_PATH/bin" ] && PATH="$PATH:$GEM_PATH/bin"
              export PATH

              [ -s "$HOME/.aliases" ] && source "$HOME/.aliases"

              PS1='\u@middleman-dev:\w/ > '
              export PS1
            '';
          };
        }
      );
    };
}
