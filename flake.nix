{
  description = "UFDA suite: pinned component sources and development commands";

  inputs = {
    ixyk.url = "github:heartpunk/ixyk/66729541a3fe3fb3a3d0979510fa3f0fbc59873a";
    wruh.url = "github:heartpunk/wruh/e9931eaf74199fb7c66d2b1609a7e8aa502ed659";
    ayxg.url = "github:heartpunk/ayxg/ab2bee80d559b864ca512058b75db75e2052d357";
    utem.url = "github:heartpunk/utem/6060b0c8a68e7be5ac2126cfc58e3cfac5e41197";
  };

  outputs = inputs:
    let
      pins = {
        ixyk = "66729541a3fe3fb3a3d0979510fa3f0fbc59873a";
        wruh = "e9931eaf74199fb7c66d2b1609a7e8aa502ed659";
        ayxg = "ab2bee80d559b864ca512058b75db75e2052d357";
        utem = "6060b0c8a68e7be5ac2126cfc58e3cfac5e41197";
      };
      sources = builtins.mapAttrs (_: source: toString source) {
        inherit (inputs) ixyk wruh ayxg utem;
      };
      systems = [ "aarch64-darwin" "x86_64-linux" ];
      mkShell = system:
        let
          pkgs = import inputs.ixyk.inputs.nixpkgs { inherit system; };
          lib = pkgs.lib;
          # Each wrapper enters the component's own development shell.
          runner = pkgs.writeShellScriptBin "ufda-component-cli" ''
            exec ${pkgs.bash}/bin/bash ${./scripts/component-cli} "$@"
          '';
          nixNoWriteLock = pkgs.writeShellScriptBin "nix" ''
            if [ "''${1:-}" = run ]; then
              shift
              exec ${pkgs.nix}/bin/nix run --no-write-lock-file "$@"
            fi
            exec ${pkgs.nix}/bin/nix "$@"
          '';
          mkCli = { name, component, mode, target, binaryPath ? "", nixShim ? null }:
            let
              nixShimArg = if nixShim == null then "" else
                "--nix-shim ${lib.escapeShellArg "${nixShim}/bin"}";
            in pkgs.writeShellScriptBin name ''
              exec ${runner}/bin/ufda-component-cli \
                ${lib.escapeShellArg component} \
                ${lib.escapeShellArg pins.${component}} \
                ${lib.escapeShellArg (toString inputs.${component})} \
                ${lib.escapeShellArg pins.${component}} \
                ${lib.escapeShellArg mode} \
                ${lib.escapeShellArg target} \
                ${lib.escapeShellArg binaryPath} \
                ${lib.escapeShellArg "${pkgs.bash}/bin/bash"} \
                ${nixShimArg} \
                -- "$@"
            '';
          componentClis = [
            (mkCli { name = "ixyk-dev-check"; component = "ixyk";
              mode = "component-command"; target = "ixyk-dev-check"; })
            (mkCli { name = "ixyk-golden-check"; component = "ixyk";
              mode = "lake"; target = "ixyk-golden-check"; })
            (mkCli { name = "ixyk-differential-eval"; component = "ixyk";
              mode = "lake"; target = "ixyk-differential-eval"; })
            (mkCli { name = "fuzz_model"; component = "ixyk";
              mode = "bazel-binary"; target = "//extractor:fuzz_model";
              binaryPath = "bazel-bin/extractor/fuzz_model"; })
            (mkCli { name = "extract_model"; component = "ixyk";
              mode = "bazel-binary"; target = "//extractor:extract_model";
              binaryPath = "bazel-bin/extractor/extract_model"; })
            (mkCli { name = "reapi_smoke"; component = "ixyk";
              mode = "python-clean"; target = "tools/reapi_smoke.py";
              nixShim = nixNoWriteLock; })
            (mkCli { name = "wruh-extract"; component = "wruh";
              mode = "wruh-python"; target = "extractor.extract_cli"; })
            (mkCli { name = "wruh-compose"; component = "wruh";
              mode = "wruh-python"; target = "extractor.compose_cli"; })
            (mkCli { name = "bazelw"; component = "wruh";
              mode = "bazel"; target = "scripts/bazelw"; })
          ];
        in pkgs.mkShell {
          packages = [ pkgs.bash pkgs.nix pkgs.git ] ++ componentClis;
        };
    in {
      lib = { inherit sources pins; };
      devShells = inputs.ixyk.inputs.nixpkgs.lib.genAttrs systems (system:
        builtins.mapAttrs (name: _: inputs.${name}.devShells.${system}.default) pins
        // { default = mkShell system; });
    };
}
