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
              pkgs.nodejs_25
              pkgs.ruby_3_4
            ];
            shellHook = ''
              [ -d "$HOME/.local/share/gem/ruby/3.4.0/bin" ] && PATH="$PATH:$HOME/.local/share/gem/ruby/3.4.0/bin"
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
