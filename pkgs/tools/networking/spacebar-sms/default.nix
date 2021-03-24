{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kcontacts
, ki18n
, kirigami2
, knotifications
, kpeople
, libqofono
, telepathy
}:

mkDerivation rec {
  pname = "spacebar";
  version = "21.05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "18fx5h1jpwdgi2if5rndllqszfzykdxcdn3aj3gl0ny3dg55pxnj";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcontacts
    ki18n
    kirigami2
    knotifications
    kpeople
    libqofono
    telepathy
  ];

  meta = with lib; {
    description = "SMS application for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/spacebar";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
