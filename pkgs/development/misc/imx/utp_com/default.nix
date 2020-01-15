{ lib
, stdenv
, fetchFromGitHub
, sg3_utils
}:

stdenv.mkDerivation rec {
  name = "utp_com-unstable";
  version = "2020-01-15";

  buildInputs = [ sg3_utils ];

  src = fetchFromGitHub {
    owner = "ixonos";
    repo  = "${name}";
    rev = "06337f755fb907cf077668596582000219b7eca6";
    sha256 = "14lvsqqdq50sij468ic9486b5yqh0mi1982cq3xmcqj6x55ck0cl";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -m755 utp_com $out/bin;
  '';

  meta = with lib; {
    description = "Send commands to hardware via Freescale's UTP protocol.";
    homepage = https://github.com/ixonos/utp_com;
    license = licenses.gpl2;
    maintainers = with maintainers; [ mtetreault ];
    platforms = platforms.linux;
  };
}
