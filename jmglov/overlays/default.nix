{ pkgs, hostName, ... }:
let
  inherit (pkgs) fetchFromGitHub fetchurl stdenv;

  chrome = (self: super:
    let
      pkgName = "google-chrome-stable";
      # From https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/chromium/upstream-info.nix
      version = "120.0.6099.109"; # ungoogled-chromium.version
      sha256 = sha256bin64;
      sha256bin64 =
        "sha256-ScFJQB9fY1cWHtFO8GpQ8yuCLaO1AvyAV5lbnqSrPCs="; # ungoogled-chromium.hash_deb_amd64
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

  brave = (self: super:
    let
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/brave/default.nix
      version = "1.61.101";
      sha = "sha256-s+YjTZs+dT/T/MSzOAvXMHzd3pWMbLa8v9amnd2sqns=";
    in {
      brave = super.brave.overrideAttrs (_: {
        src = fetchurl {
          url =
            "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
          hash = sha;
        };
      });
    });

  discord = (self: super:
    let
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/discord/default.nix
      version = "0.0.45";
      sha = "sha256-dSDc5EyWk/aH5JFG6WYfJqnb0Y2/b46YcdNB2Z9wRn0=";
    in {
      discord = super.discord.overrideAttrs (_: {
        src = fetchurl {
          url =
            "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
          sha256 = sha;
        };
      });
    });

  slack = (self: super:
    let
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/slack/default.nix
      version = "4.35.131"; # x86_64-linux-version
      sha =
        "0mb33vvb36aavn52yvk5fiyc8f7z56cqm1siknaap707iqqfpwpb"; # x86_64-linux-sha256
    in {
      slack = super.slack.overrideAttrs (_: {
        src = fetchurl {
          url =
            "https://downloads.slack-edge.com/releases/linux/${version}/prod/x64/slack-desktop-${version}-amd64.deb";
          sha256 = sha;
        };
      });
    });

  zoom-us = (self: super:
    let
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/zoom-us/default.nix
      version = "5.16.10.668";
      hash = "sha256-dZQHbpvU8uNafmHtGoPhj6WsDhO20Dma/XwY6oa3Xes=";
    in {
      zoom-us = super.zoom-us.overrideAttrs (_: {
        inherit version;
        src = fetchurl {
          inherit hash;
          url = "https://zoom.us/client/${version}/zoom_x86_64.pkg.tar.xz";
        };
      });
    });
in [ brave chrome discord slack zoom-us ]
