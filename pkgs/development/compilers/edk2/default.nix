{ stdenv, buildPackages, targetPlatform, hostPlatform, fetchFromGitHub, fetchpatch, libuuid, python2 }:

let
# Given a platform, returns the edk2-valid arch.
envToArch = env:
  if env.isi686 then
    "IA32"
  else if env.isx86_64 then
    "X64"
  else if env.isAarch64 then
    "AARCH64"
  else if env.isAarch32 then
    "ARM"
  else
    throw "Unsupported architecture" 
;

buildPythonEnv = buildPackages.python2.withPackages(ps: [ps.tkinter]);
pythonEnv = python2.withPackages(ps: [ps.tkinter]);

targetArch = envToArch targetPlatform;
hostArch = envToArch hostPlatform;

edk2 = stdenv.mkDerivation {
  name = "edk2-2017-12-05";

  src = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2";
    rev = "f71a70e7a4c93a6143d7bad8ab0220a947679697";
    sha256 = "0k48xfwxcgcim1bhkggc19hilvsxsf5axvvcpmld0ng1fcfg0cr6";
  };

  patches = [
    (fetchpatch {
      name = "short-circuit-the-transfer-of-an-empty-S3_CONTEXT.patch";
      url = "https://github.com/tianocore/edk2/commit/9e2a8e928995c3b1bb664b73fd59785055c6b5f6.diff";
      sha256 = "0x24npijhgpjpsn3n74wayf8qcbaj97vi4z2iyf4almavqq8qaz4";
    })
  ];

  nativeBuildInputs = [ libuuid buildPythonEnv ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  makeFlags = [
    "-C" "BaseTools"
    # HOST_ARCH is detected through uname, better specify it.
    "HOST_ARCH=${hostArch}"
    "ARCH=${targetArch}"
  ];

  hardeningDisable = [ "format" "fortify" ];

  installPhase = ''
    mkdir -vp $out
    mv -v BaseTools $out
    mv -v EdkCompatibilityPkg $out
    mv -v edksetup.sh $out
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Intel EFI development kit";
    homepage = https://sourceforge.net/projects/edk2/;
    license = stdenv.lib.licenses.bsd2;
    branch = "UDK2017";
    platforms = ["x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux"];
  };

  passthru = {
    inherit targetArch hostArch;
    setup = projectDscPath: attrs: {
      nativeBuildInputs = [ buildPythonEnv ] ++ attrs.nativeBuildInputs or [];

      configurePhase = ''
        mkdir -v Conf

        cp ${edk2}/BaseTools/Conf/target.template Conf/target.txt
        sed -i Conf/target.txt \
          -e 's|Nt32Pkg/Nt32Pkg.dsc|${projectDscPath}|' \
          -e 's|DEBUG|RELEASE|'

        cp ${edk2}/BaseTools/Conf/tools_def.template Conf/tools_def.txt

        export WORKSPACE="$PWD"
        export EFI_SOURCE="$PWD/EdkCompatibilityPkg"
        ln -sv ${edk2}/BaseTools BaseTools
        ln -sv ${edk2}/EdkCompatibilityPkg EdkCompatibilityPkg
        . ${edk2}/edksetup.sh BaseTools
      '';

      # This probably is not enough for most builds as it won't handle
      # setting targets or other needed flags to the `build` tool.
      buildPhase = "
        build
      ";

      installPhase = "mv -v Build/*/* $out";
    } // (removeAttrs attrs [ "nativeBuildInputs" ] );
  };
};

in

edk2
