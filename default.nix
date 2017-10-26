{ nixpkgs ? <nixpkgs> }:
let
  callPackage = (import nixpkgs {}).callPackage;
in
{
  jupyter-notebooks = callPackage (
    { stdenv, python3, glibcLocales }:
    stdenv.mkDerivation rec {
      name = "nixpkgs-stats";
      src = ./.;

      buildInputs = [ glibcLocales ] ++
        (with python3.pkgs; [ jupyter pandas plotly cufflinks ]);

      buildPhase = ''
        mkdir tmp
        export HOME=$(basename tmp)
        export LC_ALL=en_US.utf8
        jupyter-nbconvert --ExecutePreprocessor.timeout=-1 --to notebook \
          --execute *.ipynb
        jupyter-nbconvert --to slides \
          --reveal-prefix https://cdn.jsdelivr.net/npm/reveal.js@3.5.0 \
          *.nbconvert.ipynb
        jupyter-nbconvert *.nbconvert.ipynb
      '';

      installPhase = ''
        mkdir -p $out/nix-support
        for stats in *.html; do
          install -vD $stats -t $out/share
          echo "doc none $out/share/$stats" \
            >> $out/nix-support/hydra-build-products
        done
        install -vD ${python3.pkgs.plotly}/${python3.sitePackages}/plotly/package_data/plotly.min.js \
          $out/share/plotly.js
      '';

      shellHook = ''
        cp ${python3.pkgs.plotly}/${python3.sitePackages}/plotly/package_data/plotly.min.js \
          plotly.js
        jupyter-notebook --browser=chromium --NotebookApp.iopub_data_rate_limit=1.0e10
      '';
    }
  ) {};
}
