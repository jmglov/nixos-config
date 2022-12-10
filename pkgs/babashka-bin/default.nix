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
          "ffebe85fa9bd3575b885859e47a18a5170e5b25e81b1f80a686144df4b0a29d4";
        amd64 =
          "0bee20da7cd00452d14bfa9c41a5b1362e53cf150897248416950ed60a1f2954";
      };
      macos = {
        aarch64 =
          "763ac565a44e87ac6ef6e6be80a67887260003ad424bf76a1962ed86c5f271ea";
        amd64 =
          "7c1f5dd448ca8c52cfc65b38a5c872d8480c444626ce8ed23efc23b1745ca86e";
      };
    }.${osName}.${arch};
in stdenv.mkDerivation rec {
  pname = "babashka";
  version = "1.0.165";

  src = builtins.fetchurl {
    inherit sha256;
    url =
      "https://github.com/babashka/babashka/releases/download/v${version}/babashka-${version}-${osName}-${arch}-static.tar.gz";
  };

  dontFixup = true;
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cd $out/bin && tar xvzf $src
  '';
}
