{ stdenv, ... }:

# See https://github.com/babashka/babashka/releases for the latest

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
        "da4a7660ba5449922db46bc74966f2bb1041340edaf1b107fd6af66464764e97";
      amd64 =
        "d8371697a727495749f9481414a2fdba5fe702dfc1b74a8ec58195f0a646abd5";
    };
    macos = {
      aarch64 =
        "9ed01a7f36e26274d1ba5c5881c04c2866caa5c4b4ed9b447cb47978f44846a6";
      amd64 =
        "8aaba607989944cdcef53964d7322abad7ec46db1fdf5bcc94b3bf02cdc7b4b2";
    };
  }.${osName}.${arch};
in stdenv.mkDerivation rec {
  pname = "babashka";
  version = "1.4.192";
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
