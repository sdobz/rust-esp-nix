{ pkgs ? import <nixpkgs> {} }:

let
  # , stdenv, fetchurl, makeWrapper, buildFHSUserEnv
  stdenv = pkgs.stdenv;
  fetchurl = pkgs.fetchurl;
  fetchzip = pkgs.fetchzip;
  buildFHSUserEnv = pkgs.buildFHSUserEnv;
  makeWrapper = pkgs.makeWrapper;
  lib = pkgs.lib;

  fhsEnv = buildFHSUserEnv {
    name = "esp32-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib libusb1 ];
    runScript = "";
  };
  toolHashes = {
    "xtensa-esp32-elf" = "06b6hw4m1jy79yw1mkj3kgibssrw4d4c5kbipbnckrivw107acw0";
    # "xtensa-esp32s2-elf"
    "esp32ulp-elf" = "02rnzkha3fvzx631y27l9nkzls2qky0v645d4pw888lxkx8p5il9";
    # "esp32s2ulp-elf"
    "openocd-esp32" = "00529xj2pmzy49w3j0wzxlw0phcbmx4vpkqbi0la88smwnqv0nqd";
  };
  version = "0a03a55c1eb44a354c9ad5d91d91da371fe23f84";

  tools = let
    toolInfoFile = fetchurl {
      url = "https://raw.githubusercontent.com/espressif/esp-idf/${version}/tools/tools.json";
      sha256 = "19dlp282mb6lpnwxc7l5i50cnqdj1qlqm5y9k98pr7wyixgj409g";
    };
    toolInfo = builtins.fromJSON (builtins.readFile toolInfoFile);
    filteredTools = builtins.filter (tool: builtins.hasAttr tool.name toolHashes) toolInfo.tools;
    
    fetchTool = tool:
      let
        fileInfo = (builtins.elemAt tool.versions 0).linux-amd64;
      in {
        name = tool.name;
        src = fetchzip {
          url = fileInfo.url;
          sha256 = toolHashes.${tool.name};
        };
      };
  in
    builtins.map fetchTool filteredTools;
in

pkgs.runCommand "esp32-toolchain" {
  buildInputs = [ makeWrapper ];
  meta = with stdenv.lib; {
    description = "ESP32 toolchain";
    homepage = https://docs.espressif.com/projects/esp-idf/en/stable/get-started/linux-setup.html;
    license = licenses.gpl3;
  };
} ''
${lib.strings.concatStrings (builtins.map ({name, src}: ''
mkdir -p $out/tools
TOOLDIR=$out/tools/${name}
cp -r ${src} $TOOLDIR
chmod u+w $TOOLDIR/bin
for FILE in $(ls $TOOLDIR/bin); do
  FILE_PATH="$TOOLDIR/bin/$FILE"
  if [[ -x $FILE_PATH ]]; then
    mv $FILE_PATH $FILE_PATH-unwrapped
    makeWrapper ${fhsEnv}/bin/esp32-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
  fi
done
chmod u-w $TOOLDIR/bin
'') tools)}
''
