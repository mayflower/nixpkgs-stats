let
  callPackage = (import <nixpkgs> {}).callPackage;
in
callPackage (
{ python3 }:
python3.pkgs.buildPythonApplication rec {
  name = "nixpkgs-stats";
  src = ./.;

  propagatedBuildInputs = with python3.pkgs; [
    jupyter pandas plotly cufflinks
  ];

  shellHook = ''
    jupyter-notebook --browser=chromium --NotebookApp.iopub_data_rate_limit=1.0e10
  '';
}
) {}
