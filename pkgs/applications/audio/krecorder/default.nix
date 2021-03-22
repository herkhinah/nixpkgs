{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kconfig
, ki18n
, kirigami2
, qtmultimedia
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "krecorder";
  version = "21.05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "0d4daan45rbry4wvwv8n40qdkwzghr21jr5496czzkljfbpxlkzc";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    ki18n
    kirigami2
    qtmultimedia
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Audio recorder for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/krecorder";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
