{
  fetchurl,
  lib,
  stdenv,
  pkg-config,
  intltool,
  glib,
  gtk3,
  lasem,
  libgsf,
  libxml2,
  libxslt,
  cairo,
  pango,
  librsvg,
  gnome,
  autoreconfHook,
  gtk-doc,
  gnumeric,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goffice";
  version = "0.10.59";

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  src = fetchurl {
    url = "mirror://gnome/sources/goffice/${lib.versions.majorMinor finalAttrs.version}/goffice-${finalAttrs.version}.tar.xz";
    hash = "sha256-sI9xczJVlLcfu+pHajC1sxIMPa3/XAom0UDk5SSRZiI=";
  };

  nativeBuildInputs = [
    pkg-config
    intltool
    autoreconfHook
    gtk-doc
    glib # for glib-genmarshal
  ];

  propagatedBuildInputs = [
    glib
    gtk3
    libxml2
    cairo
    pango
    libgsf
    lasem
  ];

  buildInputs = [
    libxslt
    librsvg
  ];

  enableParallelBuilding = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "goffice";
      versionPolicy = "odd-unstable";
    };

    tests = {
      inherit gnumeric;
    };
  };

  meta = {
    description = "Glib/GTK set of document centric objects and utilities";

    longDescription = ''
      There are common operations for document centric applications that are
      conceptually simple, but complex to implement fully: plugins, load/save
      documents, undo/redo.
    '';

    license = lib.licenses.gpl2Plus;

    platforms = lib.platforms.unix;
  };
})
