{ stdenv
, edk2
, iasl
, nasm
, seabios
, openssl
, secureBoot ? false
}:

let
  projectDscPath = if stdenv.isi686 then
    "OvmfPkg/OvmfPkgIa32.dsc"
  else if stdenv.isx86_64 then
    "OvmfPkg/OvmfPkgX64.dsc"
  else if stdenv.isAarch64 || stdenv.isAarch32 then
    "ArmVirtPkg/ArmVirtQemu.dsc"
  else
    throw "Unsupported architecture";

  version = (builtins.parseDrvName edk2.name).version;

  inherit (edk2) src;
in

stdenv.mkDerivation (edk2.setup projectDscPath {
  name = "OVMF-${version}";

  inherit src;

  workspace = [
    src
  ];

  outputs = [ "out" "fd" ];

  # TODO: properly include openssl for secureBoot
  buildInputs = [ ] ++ stdenv.lib.optionals (secureBoot == true) [ openssl ];

  nativeBuildInputs = [ iasl nasm ];

  hardeningDisable = [ "stackprotector" "pic" "fortify" "format" ];

  buildFlags = []
    ++ stdenv.lib.optionals (seabios != null) [ "-D" "CSM_ENABLE" "-D" "FD_SIZE_2MB" ]
    ++ stdenv.lib.optionals secureBoot ["-DSECURE_BOOT_ENABLE=TRUE"]
  ;

  # Makes the `.fd` output.
  postFixup = if stdenv.isAarch64 || stdenv.isAarch32 then ''
    mkdir -vp $fd/FV
    mkdir -vp $fd/AAVMF
    mv -v $out/FV/QEMU_{EFI,VARS}.fd $fd/FV

    # Uses Fedora dir layout: https://src.fedoraproject.org/cgit/rpms/edk2.git/tree/edk2.spec
    # FIXME: why is it different from Debian dir layout? https://anonscm.debian.org/cgit/pkg-qemu/edk2.git/tree/debian/rules
    dd of=$fd/AAVMF/QEMU_EFI-pflash.raw       if=/dev/zero bs=1M    count=64
    dd of=$fd/AAVMF/QEMU_EFI-pflash.raw       if=$fd/FV/QEMU_EFI.fd conv=notrunc
    dd of=$fd/AAVMF/vars-template-pflash.raw if=/dev/zero bs=1M    count=64
  '' else ''
    mkdir -vp $fd/FV
    mv -v $out/FV/OVMF{,_CODE,_VARS}.fd $fd/FV
  '';

  dontPatchELF = true;

  meta = {
    description = "Sample UEFI firmware for QEMU and KVM";
    homepage = https://github.com/tianocore/tianocore.github.io/wiki/OVMF;
    license = stdenv.lib.licenses.bsd2;
    platforms = ["x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux"];
  };
})
