{ pkgs, ... }:
let
  inherit (pkgs) fetchurl stdenv;

  chrome = (self: super:
    let
      pkgName = "google-chrome-stable";
      # From https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/chromium/upstream-info.json
      version = "110.0.5481.177";
      sha256 = sha256bin64;
      sha256bin64 = "0sylaf8b0rzr82dg7safvs5dxqqib26k4j6vlm75vs99dpnlznj2";
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
      # Get from nixpgs/apps/networking/im/discord/default.nix
      discordVersion = "0.0.25";
      discordSha = "sha256-WBcmy9fwGPq3Vs1+7lIOR7OiW/d0kZNIKp4Q5NRYBCw=";
    in {
      discord = super.discord.overrideAttrs (_: {
        src = fetchurl {
          url =
            "https://dl.discordapp.net/apps/linux/${discordVersion}/discord-${discordVersion}.tar.gz";
          sha256 = discordSha;
        };
      });
    });
in [ chrome discord ]
