{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kconfig
, kcoreaddons
, ki18n
, kirigami2
, qtquickcontrols2
, syndication
}:

mkDerivation rec {
  pname = "alligator";
  version = "21.05";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "07i28c0x2c5awfincmizh5h9z5q95xsmv792w3iwqp4jq7afzk4c";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    ki18n
    kirigami2
    qtquickcontrols2
    syndication
  ];

  meta = with lib; {
    description = "RSS reader made with kirigami";
    homepage = "https://invent.kde.org/plasma-mobile/alligator";
    # https://invent.kde.org/plasma-mobile/alligator/-/commit/db30f159c4700244532b17a260deb95551045b7a
    #  * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
    license = with licenses; [ gpl2Only gpl3Only ];
    maintainers = with maintainers; [ samueldr ];
  };
}
