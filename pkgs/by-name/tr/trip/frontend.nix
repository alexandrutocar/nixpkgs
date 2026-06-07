{
  buildNpmPackage,
  npmDepsHash,
  version,
  pname,
  src,
}:
buildNpmPackage {
  inherit npmDepsHash version pname;

  src = "${src}/src";

  installPhase = ''
    runHook preInstall
    cp -r dist/trip/browser $out
    runHook postInstall
  '';
}
