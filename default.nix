{ writeScriptBin, bash, coreutils, sane-backends, tesseract4, evince, gnused
, extraScanimageOptions ? "" # Extra options to provide to scanimage, e.g.: "--source 'Automatic Document Feeder(centrally aligned,Duplex)'"
}:

writeScriptBin "brscan-pull" ''
  #!${bash}/bin/bash
  set -euo pipefail
  PATH=${coreutils}/bin

  # Enumerating printers with scanimage -L is too slow (~12 seconds on my
  # machine), so instead we look in the brother config files and try to guess
  # the scanner's device name.  I'm not sure if this is really legitimate, but
  # it seems like they just used the zero-based line number where the printer is
  # found.

  BROTHER_LINE_NUMBER="$(cat /etc/opt/brother/scanner/brscan4/brsanenetdevice4.cfg | ${gnused}/bin/sed -n "/^DEVICE=$1 ,/=")"
  DEVICE_NUMBER=$(( $BROTHER_LINE_NUMBER - 1 ))
  SANE_DEVICE_NAME="brother4:net1;dev$DEVICE_NUMBER"

  PREFIX="$HOME/Documents/Scans"

  TMPDIR="$(mktemp -d 2>/dev/null)"
  trap "rm -rf \"$TMPDIR\"" EXIT

  cd "$TMPDIR"

  ${sane-backends}/bin/scanimage -d "$SANE_DEVICE_NAME" --batch="page.%d.png" --format=png ${extraScanimageOptions}

  ls page.*.png | sort --field-separator=. -g -k 2 | ${tesseract4}/bin/tesseract - out pdf

  ${evince}/bin/evince out.pdf >/dev/null 2>/dev/null &

  read -e -p "Enter filename without '.pdf' (Ctrl-C to delete scan): " NAME

  mkdir -p "$PREFIX/$(dirname "$NAME")"
  mkdir "$PREFIX/$NAME" # Should fail if the name already exists
  mv -n page.*.png "$PREFIX/$NAME/"
  mv -n out.pdf "$PREFIX/$NAME.pdf"
''
