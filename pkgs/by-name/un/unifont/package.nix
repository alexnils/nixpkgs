{
  lib,
  stdenv,
  fetchurl,
  xorg,
  libfaketime,
}:

stdenv.mkDerivation rec {
  pname = "unifont";
  version = "16.0.01";

  otf = fetchurl {
    url = "mirror://gnu/unifont/${pname}-${version}/${pname}-${version}.otf";
    hash = "sha256-6jmg5hTnSGSQI5xXWeGgzYb9SeM1xLCNL9E+MTFH8CI=";
  };

  pcf = fetchurl {
    url = "mirror://gnu/unifont/${pname}-${version}/${pname}-${version}.pcf.gz";
    hash = "sha256-51YEW6CJPuLoNpsnr8AkNr7ZApnbThZyznZuBHDNmCU=";
  };

  nativeBuildInputs = [
    libfaketime
    xorg.fonttosfnt
    xorg.mkfontscale
  ];

  dontUnpack = true;

  buildPhase = ''
    # convert pcf font to otb
    faketime -f "1970-01-01 00:00:01" \
    fonttosfnt -g 2 -m 2 -v -o "unifont.otb" "${pcf}"
  '';

  installPhase = ''
    # install otb fonts
    install -m 644 -D unifont.otb "$out/share/fonts/unifont.otb"
    mkfontdir "$out/share/fonts"

    # install pcf and otf fonts
    install -m 644 -D ${pcf} $out/share/fonts/unifont.pcf.gz
    install -m 644 -D ${otf} $out/share/fonts/opentype/unifont.otf
    cd "$out/share/fonts"
    mkfontdir
    mkfontscale
  '';

  meta = with lib; {
    description = "Unicode font for Base Multilingual Plane";
    homepage = "https://unifoundry.com/unifont/";

    # Basically GPL2+ with font exception.
    license = "https://unifoundry.com/LICENSE.txt";
    maintainers = [ maintainers.rycee ];
    platforms = platforms.all;
  };
}
