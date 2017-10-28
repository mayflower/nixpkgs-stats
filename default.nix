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
        (with python3.pkgs; [ jupyter pandas plotly cufflinks nbmerge ]);

      buildPhase = ''
        mkdir tmp
        export HOME=$(basename tmp)
        export LC_ALL=en_US.utf8
        nbmerge commits.ipynb issues.ipynb pull-requests.ipynb -o stats.ipynb
        jupyter-nbconvert --ExecutePreprocessor.timeout=-1 --to notebook \
          --execute stats.ipynb --inplace
        jupyter-nbconvert --to slides \
          --reveal-prefix https://cdn.jsdelivr.net/npm/reveal.js@3.5.0 \
          stats.ipynb
        jupyter-nbconvert stats.ipynb
      '';

      installPhase = ''
        mkdir -p $out/nix-support
        for stats in *.html; do
          install -vD $stats -t $out/share
          echo "doc $(basename $stats .html | tr . -) $out/share/$stats" \
            >> $out/nix-support/hydra-build-products
        done
        install -vD ${python3.pkgs.plotly}/${python3.sitePackages}/plotly/package_data/plotly.min.js \
          $out/share/plotly.js
        install -vD custom.css $out/share/custom.css
      '';

      shellHook = ''
        cp ${python3.pkgs.plotly}/${python3.sitePackages}/plotly/package_data/plotly.min.js \
          plotly.js
        jupyter-notebook --browser=chromium --NotebookApp.iopub_data_rate_limit=1.0e10
      '';
    }
  ) {};
}
