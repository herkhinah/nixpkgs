{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kcalendarcore
, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, knotifications
, kpeople
, kservice
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "calindori";
  version = "21.05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "0jqb4wfqm01c05c4fm1hlfk266d8z5q8s3gzqiiskcfybi8cbgmw";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcalendarcore
    kconfig
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    knotifications
    kpeople
    kservice
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Calendar for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/calindori";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
