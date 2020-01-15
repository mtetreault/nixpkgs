{ lib
, stdenv
, fetchFromGitHub
, libusb1
, pkgconfig
, zlib
}:

stdenv.mkDerivation rec {
  name = "imx_usb_loader-unstable";
  version = "2020-01-15";

  buildInputs = [ libusb1 pkgconfig ];
  installFlags = [ "prefix=$(out)" ];

  src = fetchFromGitHub {
    owner = "boundarydevices";
    repo  = "${name}";
    rev = "f009770d841468204ab104bf7d3b0c5bc8425dbb";
    sha256 = "14yf9kfxrg3pxs6pwhds7z2mn78mch8nyk21myalr3m55bxkif9k";
  };

  meta = with lib; {
    description = "i.MX/Vybrid recovery utility.";
    homepage = https://github.com/boundarydevices/imx_usb_loader;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ mtetreault ];
    platforms = platforms.linux;
  };
}
