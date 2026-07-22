project_root := justfile_directory()
set dotenv-load

[private]
default:
    @just --list --unsorted

[parallel]
format: format-flake format-node format-just

[unix]
format-flake:
    nix fmt '{{ project_root }}/flake.nix'

[windows]
format-flake:
    @cmd /c "echo Formatting flakes is only possible from a Nix environment"

format-node:
    npm run format

format-just:
    just --fmt --unstable

sync:
    npm ci

dev:
    npm run dev

[unix]
clean:
    rm -rf dist

[windows]
clean:
    cmd /c "if exist dist rmdir /s /q dist"

build:
    npm run build
