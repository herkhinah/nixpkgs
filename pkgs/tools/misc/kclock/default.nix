{ lib
, mkDerivation
, fetchFromGitLab
, fetchpatch

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

  patches = [
    # Ensures we're not starting the QML debugger.
    # `QML debugging is enabled. Only use this in a safe environment.`
    (fetchpatch {
      url = "https://invent.kde.org/plasma-mobile/kclock/-/commit/64931326ee991e9fc24f749944cdf6815c7426e3.patch";
      sha256 = "0gyqz8xj2l45wsjk01xyhgy9r1fqslw3q959k73ilhq9ikdx7d2c";
    })
  ];

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
