{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, knotifications
, plasma-framework
, qtmultimedia
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "kclock";
  version = "21.05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "kclock";
    rev = "v${version}";
    sha256 = "17y1jhh7wagzzp2npbw8bwx5fx827k8lcxrsjhajn5ami28hs6f9";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    knotifications
    plasma-framework
    qtmultimedia
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Clock app for plasma mobile";
    homepage = "https://invent.kde.org/plasma-mobile/kclock";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
