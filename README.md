# brscan-pull: pull-based scanning for Brother devices

## Usage

```bash
brscan-pull FRIENDLY-NAME
```

Where `FRIENDLY-NAME` is a printer that was configured by a command like `brsaneconfig4 -a name=FRIENDLY-NAME model=MODEL-NAME ip=xx.xx.xx.xx` or a NixOS configuration like:

```nix
  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        FRIENDLY-NAME = {
          ip = "1.2.3.4";
          model = "MFC-L1234CDW";
        };
      };
    };
  };
```

## Installation

Clone this repo:

```bash
cd /etc/nixos
sudo git clone https://github.com/ryantrinkle/brscan-pull
```

Add something like this to your NixOS configuration:

```nix
  environment.systemPackages = [
    (pkgs.callPackage ./brscan-pull {})
  ];
```

You can also install brscan-pull using `home-manager` or `nix-env -i`.

## Configuration

If you want to pass additional arguments to `scanimage` when you scan, you can do so by adding an argument to the invocation of brscan-pull, like so:

```nix
  environment.systemPackages = [
    (pkgs.callPackage ./brscan-pull { extraScanimageOptions = "--source 'Automatic Document Feeder(centrally aligned,Duplex)'"; })
  ];
```

(It is not currently possible to pass additional arguments at runtime; this would be a welcome improvement!)
