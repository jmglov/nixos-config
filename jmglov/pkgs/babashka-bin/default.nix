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
        "sha256:b6bc6d28a41cb303b429cdbd565311a046719c842dcb25e8ad1ed2929f9145fe";
      amd64 =
        "sha256:2926098700f6e230b21007871b47844280d29e641959b693535a5d74e4dab4a3";
    };
    macos = {
      aarch64 =
        "sha256:6a78b6489f126d8ad74ac991930712d2b153bc7b184c461b0243cae2d3f16f88";
      amd64 =
        "sha256:c47c10dbfd3e20cf006c99868779c06b60d7531995bcc0189e6cce309ea1f217";
    };
  }.${osName}.${arch};
in stdenv.mkDerivation rec {
  pname = "babashka";
  version = "1.12.214";
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
