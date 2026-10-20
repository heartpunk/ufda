{
  description = "UFDA suite: pinned component sources and development commands";

  inputs = {
    ixyk.url = "github:heartpunk/ixyk/34c62756f501ed14c47b0d7e09cbcefa2f01e268";
    wruh.url = "github:heartpunk/wruh/62e2f61210a08b742099c8b10fb1284194d7d97c";
    ayxg.url = "github:heartpunk/ayxg/1bb41f03c920acb94ddf2e8813494c4f903a109e";
    utem.url = "github:heartpunk/utem/43d6015fd58c8ade9ad9a1d831dbb96b337e4efa";
  };

  outputs = inputs:
    let
      pins = {
        ixyk = "34c62756f501ed14c47b0d7e09cbcefa2f01e268";
        wruh = "62e2f61210a08b742099c8b10fb1284194d7d97c";
        ayxg = "1bb41f03c920acb94ddf2e8813494c4f903a109e";
        utem = "43d6015fd58c8ade9ad9a1d831dbb96b337e4efa";
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
