{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules
, bison
, flex

, gmp
, mpfr

, kconfig
, kcoreaddons
, ki18n
, kirigami2
, kunitconversion
, qtfeedback
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "kalk";
  version = "21.05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "kalk";
    rev = "v${version}";
    sha256 = "159f11dl1qsl44q7j6c82l6gq243pbnhxriqy1f1z59rg7vgzqyx";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    bison
    flex
  ];

  buildInputs = [
    gmp
    mpfr

    kconfig
    kcoreaddons
    ki18n
    kirigami2
    kunitconversion
    qtfeedback
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Calculator built with kirigami";
    homepage = "https://invent.kde.org/plasma-mobile/kalk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
