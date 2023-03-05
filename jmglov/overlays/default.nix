{ fetchurl }:
let
  # Get from nixpgs/apps/networking/im/discord/default.nix
  discordVersion = "0.0.25";
  discordSha = "sha256-WBcmy9fwGPq3Vs1+7lIOR7OiW/d0kZNIKp4Q5NRYBCw=";
in [
  (self: super: {
    discord = super.discord.overrideAttrs (_: {
      src = fetchurl {
        url =
          "https://dl.discordapp.net/apps/linux/${discordVersion}/discord-${discordVersion}.tar.gz";
        sha256 = discordSha;
      };
    });
  })
]
