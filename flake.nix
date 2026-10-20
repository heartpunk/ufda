{
  description = "UFDA suite: pinned component sources and development commands";

  inputs = {
    ixyk.url = "github:heartpunk/ixyk/8db2a865adc76ec0e07b2421b14db3318581f58e";
    wruh.url = "github:heartpunk/wruh/03abf8bde75094d82aabd4789f18643656368d72";
    ayxg.url = "github:heartpunk/ayxg/c7bd6ecc08a570c5b4a67643dcd33fc6c461bfec";
    utem.url = "github:heartpunk/utem/127f8e0b15329482b1bc5314eda30160887d20af";
  };

  outputs = inputs:
    let
      pins = {
        ixyk = "8db2a865adc76ec0e07b2421b14db3318581f58e";
        wruh = "03abf8bde75094d82aabd4789f18643656368d72";
        ayxg = "c7bd6ecc08a570c5b4a67643dcd33fc6c461bfec";
        utem = "127f8e0b15329482b1bc5314eda30160887d20af";
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
