{ stdenv, ... }:

let
  arch = if stdenv.isAarch64 then "aarch64" else "amd64";
  osName = if stdenv.isDarwin then
    "macos"
  else if stdenv.isLinux then
    "linux"
  else
    null;
  sha256 = assert !isNull osName;
    {
      linux = {
        aarch64 =
          "bc7e733863486b334b8bff83ba13b416800e0ce45050153cb413906b46090d68";
        amd64 =
          "25975d5424e7dea9fbaef5a6551ce7d3834631b5e28bdc4caf037bf45af57dfd";
      };
      macos = {
        # No MacOS builds for ARM at the moment
        # aarch64 =
        #   "11c4b4bd0b534db1ecd732b03bc376f8b21bbda0d88cacb4bbe15b8469029123";
        amd64 =
          "792ade86e61703170f3de3082183173db66a9a98b11d01c95ace0235f0a5e345";
      };
    }.${osName}.${arch};
in stdenv.mkDerivation rec {
  pname = "babashka";
  version = "1.1.173";
  filename = if osName == "macos" then
  # No static builds for MacOS
    "babashka-${version}-${osName}-${arch}.tar.gz"
  else
    "babashka-${version}-${osName}-${arch}-static.tar.gz";

  src = builtins.fetchurl {
    inherit sha256;
    url =
      "https://github.com/babashka/babashka/releases/download/v${version}/${filename}";
  };

  dontFixup = true;
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cd $out/bin && tar xvzf $src
  '';
}
