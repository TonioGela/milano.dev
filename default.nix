let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  wrangler = pkgs.writeText "wrangler.jsonc" (
    builtins.toJSON {
      name = "milano-dev";
      compatibility_date = "2026-09-25";
      assets = {
        directory = "./public";
        not_found_handling = "404-page";
      };
      routes = [
        {
          pattern = "milano.dev";
          custom_domain = true;
        }
      ];
    }
  );

  headers = pkgs.writeText "_headers" ''
    /*
      Content-Security-Policy: default-src 'self'; script-src 'self' 'inline-speculation-rules'; object-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'self'
      X-Content-Type-Options: nosniff
      Referrer-Policy: strict-origin-when-cross-origin
      X-Frame-Options: SAMEORIGIN
      Permissions-Policy: accelerometer=(), camera=(), geolocation=(), gyroscope=(), microphone=(), payment=(), usb=()
  '';
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "milano.dev";
  version = "2.0.1";
  src = pkgs.lib.fileset.toSource {
    root = ./.;
    fileset = pkgs.lib.fileset.unions [
      ./config.toml
      ./content
      ./data
      ./sass
      ./static
      ./templates
    ];
  };

  nativeBuildInputs = [ pkgs.zola ];

  buildPhase = ''
    runHook preBuild
    zola build --output-dir public
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r public $out/public
    cp ${headers} $out/public/_headers
    cp ${wrangler} $out/wrangler.jsonc
    runHook postInstall
  '';
}
