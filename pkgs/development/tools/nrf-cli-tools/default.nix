{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, substituteAll
, makeWrapper
, udev
, libusb1
, jlink
}:

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
    makeWrapper
    dpkg
  ];

  buildInputs = [ 
    libusb1
    udev
  ];

  runtimeDependencies = [ 
    jlink
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    mkdir -p $out/deb
    tar -xzvf ${src} -C $out/deb
  '';

  installPhase = ''
    mkdir -p $out/bin
    dpkg-deb -x $out/deb/${debName} $out/deb
    mv $out/deb/opt/mergehex $out
    mv $out/deb/opt/nrfjprog $out

    ln -s $out/mergehex/mergehex $out/bin/
    ln -s $out/nrfjprog/nrfjprog $out/bin/
    rm -rf deb
  '';

  postFixup = ''
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* -or -name \*.node\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
    done
    wrapProgram "$out/bin/nrfjprog" --prefix LD_LIBRARY_PATH ":" "${jlink}/lib"
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.nordicsemi.com/Software-and-tools/Development-Tools/nRF-Command-Line-Tools/Download";
    description = "nRF CommandLine Tools";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}