{ stdenv, ... }:

let
  arch = if stdenv.isAarch64 then "aarch64" else "amd64";
  osName = if stdenv.isLinux then
    "linux"
  else if stdenv.isDarwin then
    "macos"
  else
    throw "Unsupported OS";
  sha256 = {
    linux = {
      aarch64 =
        "417280537b20754b675b7552d560c4c2817a93fbcaa0d51e426a1bff385e3e47";
      amd64 =
        "89431b0659e84a468da05ad78daf2982cbc8ea9e17f315fa2e51fecc78af7cc0";
    };
    macos = {
      aarch64 =
        "77eb9ec502260fa94008e1e43edc5678fab8dc1a5082b7eb3d28ae594ea54e09";
      amd64 =
        "d8854833a052bb578360294d6975b85ed917b9f86da0068fb3c263f8cbcc9e15";
    };
  }.${osName}.${arch};
in stdenv.mkDerivation rec {
  pname = "babashka";
  version = "1.3.188";
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
