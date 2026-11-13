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
  ]
  # chromium is linux-only
  ++ pkgs.lib.optional pkgs.stdenv.isLinux (
    pkgs.writeShellScriptBin "lighthouse" ''
      unset LD_LIBRARY_PATH # host libs (e.g. alsa-lib) can be newer than the pinned glibc
      tmp=$(mktemp -d)
      ${pkgs.zola}/bin/zola build --base-url http://localhost:1314 --output-dir "$tmp/public" >/dev/null
      ${pkgs.darkhttpd}/bin/darkhttpd "$tmp/public" --addr 127.0.0.1 --port 1314 >/dev/null &
      trap "kill $!; rm -rf $tmp" EXIT
      until ${pkgs.curl}/bin/curl -s localhost:1314 >/dev/null; do sleep 0.5; done
      lh() { CHROME_PATH=${pkgs.chromium}/bin/chromium ${pkgs.nodejs}/bin/npx -y lighthouse@13.5.0 "http://localhost:1314/''${PAGE:-}" --chrome-flags="--headless=new --no-sandbox" --output=json "$@"; }
      lh --output-path="$tmp/mobile.json" "$@"
      lh --output-path="$tmp/desktop.json" --preset=desktop "$@"
      ${pkgs.jq}/bin/jq -n --slurpfile m "$tmp/mobile.json" --slurpfile d "$tmp/desktop.json" '{mobile: $m[0], desktop: $d[0]}' > lighthouse.json
    ''
  );
}
