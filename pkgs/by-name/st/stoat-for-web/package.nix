{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "stoat-for-web";
  version = "0.0.14";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "alexandrutocar";
    repo = "stoat-for-web";
    rev = "fa1005d8c435858cea2ef0bf7c892957455006b4";
    hash = "sha256-bcTuM2wVhFvX1kyx7u1Ea1nL1Wum/3cfQ0kkwAQeevs=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-vEy+SFmFsGanWffk9aEePZzvZgM/G9GWjCoa5Jr3oB4=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  buildPhase = ''
    # build dependencies
    pnpm build:deps

    # build application
    pnpm build:web
  '';

  meta = {
    changelog = "https://github.com/stoatchat/for-web/releases/tag/v${finalAttrs.version}";
    description = "Browser app for Stoat";
    homepage = "https://stoat.chat/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      alexandrutocar
    ];
  };
})
