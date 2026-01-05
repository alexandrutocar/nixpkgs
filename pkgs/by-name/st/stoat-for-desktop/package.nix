{
  stdenv,
  lib,
  applyPatches,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "stoat-for-desktop";
  version = "1.1.12";

  src = applyPatches {
    src = fetchFromGitHub {
      fetchSubmodules = true;
      owner = "stoatchat";
      repo = "for-desktop";
      tag = "v${finalAttrs.version}";
      hash = "sha256-xyJ2yoFqMZyamvf4UEU/iUPnrQhMTFETHWQqQ91Rhpw=";
    };

    patches = [
      ./patches/0001-remove-github-publisher.patch
    ];
  };

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  strictDeps = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-0UAQJ9ka+6gjn6DUpW6HjhP6CiXVSPeNo5k+LKqrPsg=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  buildPhase = ''
    pnpm run package
  '';

  meta = {
    changelog = "https://github.com/stoatchat/for-desktop/releases/tag/v${finalAttrs.version}";
    description = "Application for Windows, macOS, and Linux";
    homepage = "https://stoat.chat";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [alexandrutocar];
    platforms = lib.platforms.linux;
  };
})
