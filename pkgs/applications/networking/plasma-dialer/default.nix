{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kcontacts
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, knotifications
, kpeople
, libphonenumber
, libpulseaudio
, libqofono
, protobuf
, qtquickcontrols2
, telepathy
}:

mkDerivation rec {
  pname = "plasma-dialer";
  version = "21.05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "117hsd270ccpgvscx0s3p6a15islkqk6rh3b08ix931f4sapar2b";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcontacts
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    knotifications
    kpeople
    libphonenumber
    libpulseaudio
    libqofono
    protobuf # Needed by libphonenumber
    qtquickcontrols2
    telepathy
  ];

  meta = with lib; {
    description = "Dialer for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-dialer";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
