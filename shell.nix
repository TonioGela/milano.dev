let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  cities = [
    "Milano"
    "Milan"
    "Sesto San Giovanni"
  ];
in
pkgs.mkShell {
  packages = [
    pkgs.npins
    pkgs.zola
    (pkgs.writeShellScriptBin "events" ''
      export INPUT_CITIES="''${INPUT_CITIES:-${pkgs.lib.concatStringsSep "," cities}}"
      exec ${pkgs.nodejs}/bin/node ${sources.events-parsing}/index.js
    '')
    (pkgs.writeShellScriptBin "build" ''
      events && exec zola build "$@"
    '')
    (pkgs.writeShellScriptBin "serve" ''
      events && exec zola serve --port "''${1:-8080}"
    '')
  ];
}
