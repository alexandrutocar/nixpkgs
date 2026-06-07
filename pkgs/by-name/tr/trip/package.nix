{
  lib,
  fetchFromGitHub,
  python3Packages,
  callPackage,
  nix-update-script,
}:
python3Packages.buildPythonApplication (
  finalAttrs:
  let
    dependencies = with python3Packages; [
      fastapi
      uvicorn
      sqlmodel
      pydantic
      pydantic-settings
      pyjwt
      argon2-cffi
      pillow
      authlib
      alembic
      pyotp
      httpx
      python-multipart
    ];
  in
  {
    pname = "trip";
    version = "1.45.2";
    pyproject = true;

    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "itskovacs";
      repo = finalAttrs.pname;
      tag = finalAttrs.version;
      hash = "sha256-8czIsnfgWSlwWZ7UrLOhjblhvSc9IHvyq89RZ6GODMA=";
    };

    sourceRoot = "${finalAttrs.src.name}/backend";

    # Allow easier version overrides, following
    # the example of fider package e.g.:
    # pkgs.trip.overrideAttrs (prev: {
    #   version = "...";
    #   src = prev.src.override {
    #     hash = "...";
    #   };
    #   npmDepsHash = "...";
    # })
    npmDepsHash = "sha256-C87c3pc30sD2VuaXgX2ApovjSancabIrXIpd+WiOJo4=";

    frontend = callPackage ./frontend.nix {
      inherit (finalAttrs)
        npmDepsHash
        version
        pname
        src
        ;
    };

    build-system = [ python3Packages.setuptools ];
    inherit dependencies;

    postPatch = ''
      # upstream does not use [build-system] in 0.23.x, causing setuptools
      # to fail on the flat layout with multiple top-level directories
      cat > pyproject.toml << EOF
      [build-system]
      requires = ["setuptools"]
      build-backend = "setuptools.build_meta"

      [project]
      name = "trip"
      version = "${finalAttrs.version}"

      [tool.setuptools.packages]
      find.where = ["."]
      EOF

      substituteInPlace alembic.ini \
        --replace-fail "script_location = %(here)s/trip/alembic" \
                       "script_location = ${placeholder "out"}/${python3Packages.python.sitePackages}/trip/alembic"

      substituteInPlace trip/db/core.py \
        --replace-fail 'Config("alembic.ini")' \
                       'Config("${placeholder "out"}/${python3Packages.python.sitePackages}/trip/alembic.ini")'

      substituteInPlace trip/config.py \
        --replace-fail 'FRONTEND_FOLDER: str = "frontend"' \
                       'FRONTEND_FOLDER: str = "${finalAttrs.frontend}"'
    '';

    postInstall = ''
      cp alembic.ini $out/${python3Packages.python.sitePackages}/trip/alembic.ini

      makeWrapper ${python3Packages.python}/bin/python $out/bin/trip \
        --add-flags "-m uvicorn trip.main:app" \
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:${python3Packages.makePythonPath dependencies}"
    '';

    passthru = {
      updateScript = nix-update-script { };
    };

    meta = with lib; {
      changelog = "https://github.com/itskovacs/trip/releases/tag/${finalAttrs.version}";
      description = "Self-hostable minimalist Map tracker and Trip planner.";
      homepage = "https://github.com/itskovacs/trip";
      license = licenses.mit;
      mainProgram = finalAttrs.pname;
      maintainers = with maintainers; [ alexandrutocar ];
    };
  }
)
