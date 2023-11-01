{ pkgs, ... }:
let
  inherit (pkgs) fetchurl stdenv;

  chrome = (self: super:
    let
      pkgName = "google-chrome-stable";
      # From https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/chromium/upstream-info.nix
      version = "118.0.5993.117"; # ungoogled-chromium.version
      sha256 = sha256bin64;
      sha256bin64 =
        "sha256-RJcyIA0TdXWRk+K2GVcHSv4OSq5c6Y7InUblao3uusc="; # ungoogled-chromium.hash_deb_amd64
    in {
      google-chrome = super.google-chrome.override {
        chromium = {
          upstream-info.version = version;

          # From pkgs/apps/networking/browsers/chromium
          chromeSrc = fetchurl {
            urls = map
              (repo: "${repo}/${pkgName}/${pkgName}_${version}-1_amd64.deb") [
                "https://dl.google.com/linux/chrome/deb/pool/main/g"
                "http://95.31.35.30/chrome/pool/main/g"
                "http://mirror.pcbeta.com/google/chrome/deb/pool/main/g"
                "http://repo.fdzh.org/chrome/deb/pool/main/g"
              ];
            inherit sha256;
          };
        };
      };
    });

  discord = (self: super:
    let
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/discord/default.nix
      version = "0.0.28";
      sha = "sha256-JwxVVm/QIBLoVyQ2Ff/MX06UNgZ+dAsD960GsCg1M+U=";
    in {
      discord = super.discord.overrideAttrs (_: {
        src = fetchurl {
          url =
            "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
          sha256 = sha;
        };
      });
    });

  zoom-us = (self: super:
    let
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/zoom-us/default.nix
      version = "5.15.5.5603";
      hash = "sha256-JIS+jxBiW/ek47iz+yCcmoCZ8+UBzEXMC1Yd7Px0ofg=";
    in {
      zoom-us = super.zoom-us.overrideAttrs (_: {
        inherit version;
        src = fetchurl {
          inherit hash;
          url = "https://zoom.us/client/${version}/zoom_x86_64.pkg.tar.xz";
        };
      });
    });
in [ chrome discord zoom-us ]
