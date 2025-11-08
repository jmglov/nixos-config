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
        "db0ce3a3e120589bce4233387d01d87a9cfd1e099e753f02c14e066635a27f0f";
      amd64 =
        "78bd6f9ba967afd4cfc6eb34fca0d9d6fc521c5b5243f4b1ed13ae2e45e6fe4d";
    };
    macos = {
      aarch64 =
        "72c306f64446255034a7d7473caf3e19e644b1666bc50a5a1e3701c928e6d6fe";
      amd64 =
        "3ec61805d070320cecfc7450c45d49f5525f7dcbfabbc26bb4e3862df08eeb9a";
    };
  }.${osName}.${arch};
in stdenv.mkDerivation rec {
  pname = "babashka";
  version = "1.12.207";
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
