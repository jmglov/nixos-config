# jmglov's NixOS config

I use this config to manage my two NixOS laptops. If you find anything useful
here, help yourself with my compliments! 😀

## Upgrading NixOS

``` text
sudo nix-channel --add https://nixos.org/channels/nixos-23.11 nixos  # or latest version
sudo nix-channel update
sudo nixos-rebuild switch --upgrade
```

### Troubleshooting

Sometimes there can be changes that require new kernel params or some such. If
you get an odd error similar to this one:

``` text
× systemd-backlight@leds:dell::kbd_backlight.service - Load/Save Screen Backlight Brightness of leds:dell::kbd_backlight
     Loaded: loaded (/etc/systemd/system/systemd-backlight@.service; static)
    Drop-In: /nix/store/2iz1crfvdigal54kblzhrdaic0nl37jy-system-units/systemd-backlight@.service.d
             └─overrides.conf
     Active: failed (Result: exit-code) since Tue 2024-01-09 17:52:05 CET; 2s ago
       Docs: man:systemd-backlight@.service(8)
    Process: 2961690 ExecStart=/nix/store/i0sdqs34r68if9s4sfmpixnnj36npiwj-systemd-254.6/lib/systemd/systemd-backlight load leds:dell::kbd_backlight (code=exited, status=
1/FAILURE)
   Main PID: 2961690 (code=exited, status=1/FAILURE)
         IP: 0B in, 0B out
        CPU: 13ms

Jan 09 17:52:05 laurana systemd[1]: Starting Load/Save Screen Backlight Brightness of leds:dell::kbd_backlight...
Jan 09 17:52:05 laurana systemd-backlight[2961690]: dell::kbd_backlight: Failed to read current brightness: Invalid argument
Jan 09 17:52:05 laurana systemd[1]: systemd-backlight@leds:dell::kbd_backlight.service: Main process exited, code=exited, status=1/FAILURE
Jan 09 17:52:05 laurana systemd[1]: systemd-backlight@leds:dell::kbd_backlight.service: Failed with result 'exit-code'.
Jan 09 17:52:05 laurana systemd[1]: Failed to start Load/Save Screen Backlight Brightness of leds:dell::kbd_backlight.
warning: error(s) occurred while switching to the new configuration
```

Try regenerating the hardware config and then rebuilding again:

``` text
sudo nixos-generate-config
sudo nixos-rebuild switch --upgrade
```
