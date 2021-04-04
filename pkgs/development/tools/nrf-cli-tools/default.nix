{ stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, substituteAll
, libudev
, libusb1
, jlink
}:

#PR: https://github.com/NixOS/nixpkgs/pull/80990


let
  vMajor = "10";
  vMinor = "12";
  vPatch = "1";
  debName = "nRF-Command-Line-Tools_${vMajor}_${vMinor}_${vPatch}_Linux-amd64.deb";

  url_base = "https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-${vMajor}-x-x/${vMajor}-${vMinor}-${vPatch}";
  architecture = {
    x86_64-linux = "x86_64";
    i686-linux = "i386";
  }.${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");

  sha256 = {
    x86_64-linux = "1141myf8nn464i1iaw79q6xm2a1mdn3hmaygwxpz1dqxcgfmi5dr";
    i686-linux = "1vdfxiwwxxr6vjybd0xl8iq79b5j7kd10bk9j22ghkg7b4mbsjrm";  
  }.${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");

  url = {
    x86_64-linux = "${url_base}/nRFCommandLineTools${vMajor}${vMinor}${vPatch}Linuxamd64.tar.gz";
    i686-linux = "${url_base}/nRFCommandLineTools${vMajor}${vMinor}${vPatch}Linuxi386.tar.gz";
  }.${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation rec {
  pname = "nrf-cli-tools";
  version = "${vMajor}.${vMinor}.${vPatch}";

  src = fetchurl {
    url = url;
    sha256 = sha256;
    curlOpts = "-d accept_license_agreement=accepted -d non_emb_ctr=confirmed";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [ 
    dpkg
    libudev
    libusb1
    jlink
  ];

  runtimeDependencies = [ 
    jlink
  ];
  dontUnpack = true;
  
  installPhase = ''
    mkdir -p $out
    dpkg -x ${debName} $out
    cp -av $out/opt/mergehex/* $out
    cp -av $out/opt/nrfjprog/* $out
    rm -rf $out/usr $out/opt $out/etc
  '';

  postFixup = ''
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* -or -name \*.node\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
    done
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.segger.com/downloads/jlink";
    description = "SEGGER J-Link";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" "armv7l-linux" ];
  };
}