{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
}:
pkgs.mkShell {
  packages = [
    pkgs.npins
    pkgs.zola
    (pkgs.writeShellScriptBin "events" ''
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
