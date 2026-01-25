{ pkgs, hostName, ... }:
let
  inherit (pkgs) fetchFromGitHub fetchurl stdenv;

  brave = (self: super:
    let
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/br/brave/package.nix
      version = "1.84.141";
      sha = "sha256-Pp/jZmu6vTMJctVYGUeRZYhzWc2LS9jC4Niz9cPvkoE=";
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
      version = "0.0.67";
      sha = "sha256-L8COdPP4SFRO+1mipjn4tjLR+xShcJbT/72yhNHdSWg=";
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
      version = "4.36.140"; # x86_64-linux-version
      sha =
        "0zahhhpcb1dxdhfmam32iqr5w3pspzbmcdv53ciqfnbkmwzkc3xr"; # x86_64-linux-sha256
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
      version = "6.1.6.1013";
      hash = "sha256-mvCJft0suOxnwTkWWuH9OYKHwTMWx61ct10P5Q/EVBM=";
    in {
      zoom-us = super.zoom-us.overrideAttrs (_: {
        inherit version;
        src = fetchurl {
          inherit hash;
          url = "https://zoom.us/client/${version}/zoom_x86_64.pkg.tar.xz";
        };
      });
    });
in [ brave discord slack zoom-us ]
