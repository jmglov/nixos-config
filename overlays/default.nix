{ fetchurl }:
let
  # Get from nixpgs/apps/networking/im/discord/default.nix
  discordVersion = "0.0.19";
  discordSha = "GfSyddbGF8WA6JmHo4tUM27cyHV5kRAyrEiZe1jbA5A=";
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
