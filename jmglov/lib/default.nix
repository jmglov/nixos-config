{ ... }:

rec {
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  mkPkgsMain = date: commitHash: sha256: mkPkgsMain' date commitHash sha256 { };

  mkPkgsMain' = date: commitHash: sha256: config:
    import (builtins.fetchTarball {
      inherit sha256;
      name = "nixos-main-${date}";
      url = "https://github.com/nixos/nixpkgs/archive/${commitHash}.tar.gz";
    }) ({ config.allowUnfree = true; } // config);
}
