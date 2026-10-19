{
  description = "UFDA suite: pinned component sources and development commands";

  inputs = {
    ixyk.url = "github:heartpunk/ixyk/b6779bb0ed4354c820fb831be1f4402170a0e5d1";
    wruh.url = "github:heartpunk/wruh/16d77877512d97fad0622a7a6ac401cf8b2dd538";
    ayxg.url = "github:heartpunk/ayxg/5106df06d92620da810c325b8779ce97a14f7f0e";
    utem.url = "git+ssh://git@github.com/heartpunk/utem.git?rev=88efa92e1fe4c0553f8eba43dec198b19ebdeb31";
    tmvm.url = "git+ssh://git@github.com/heartpunk/tmvm.git?rev=7b2935541d5537c09db7354daee6f98ff74a265e";
  };

  outputs = inputs:
    let
      pins = {
        ixyk = "b6779bb0ed4354c820fb831be1f4402170a0e5d1";
        wruh = "16d77877512d97fad0622a7a6ac401cf8b2dd538";
        ayxg = "5106df06d92620da810c325b8779ce97a14f7f0e";
        utem = "88efa92e1fe4c0553f8eba43dec198b19ebdeb31";
        tmvm = "7b2935541d5537c09db7354daee6f98ff74a265e";
      };
      sources = builtins.mapAttrs (_: source: toString source) {
        inherit (inputs) ixyk wruh ayxg utem tmvm;
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
            # The extraction CLI now lives in IXYK, not the WRUH proof package.
            (mkCli { name = "extract_model"; component = "ixyk";
              mode = "bazel-binary"; target = "//extractor:extract_model";
              binaryPath = "bazel-bin/extractor/extract_model"; })
            (mkCli { name = "reapi_smoke"; component = "ixyk";
              mode = "python-clean"; target = "tools/reapi_smoke.py";
              nixShim = nixNoWriteLock; })
            (mkCli { name = "bazelw"; component = "wruh";
              mode = "bazel"; target = "scripts/bazelw"; })
            (mkCli { name = "tinymemory-bounded-oracle"; component = "tmvm";
              mode = "lake"; target = "tinymemory-bounded-oracle"; })
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
