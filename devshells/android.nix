# Android / React Native toolchain with declared emulator profiles.
# A project opts in with an untracked .envrc:
#
#     watch_file ~/nixos-config/devshells/android.nix
#     use flake ~/nixos-config#android
#
# The SDK is a read-only store path, so Gradle cannot download a missing
# component: an "SDK directory is not writable" error means a version has to be
# added here. The defaults are what React Native 0.88 / Expo 58 ask for
# (node_modules/react-native/gradle/libs.versions.toml).
#
# Emulators likewise cannot pull system images at runtime, so each one is a
# profile below; its image is added to the SDK automatically. `android-emulator`
# lists them, `android-emulator <name> [emulator flags]` creates the AVD on first
# use and boots it.
{
  pkgs,
  platforms ? [
    "36"
    "37.0"
  ],
  buildTools ? [
    "36.0.0"
    "37.0.0"
  ],
  ndk ? "27.1.12297006",
  # AGP's default 3.22.1 is avoided through GRADLE_OPTS below.
  cmake ? "3.30.5",
  emulators ? [
    # What pilke-app's CI boots (e2e.yml): the Maestro suite assumes this screen.
    {
      name = "Pixel_4_API_30";
      device = "pixel_4";
      api = "30";
      ramMB = 4096;
    }
    {
      name = "Pixel_7_API_36";
      device = "pixel_7";
      api = "36";
    }
  ],
}:
let
  lib = pkgs.lib;
  # Fields a profile may leave out. `type` is the image flavour: google_apis,
  # google_apis_playstore, default, ...; `avdmanager list device -c` lists devices.
  profiles = map (
    e:
    {
      type = "google_apis";
      abi = "x86_64";
      ramMB = 2048;
      diskGB = 6;
    }
    // e
  ) emulators;

  # androidenv fetches images for every platform x type x abi listed, so each
  # extra type or abi multiplies the download across all the APIs here.
  android = pkgs.androidenv.composeAndroidPackages {
    platformVersions = lib.unique (platforms ++ map (p: p.api) profiles);
    buildToolsVersions = buildTools;
    includeNDK = true;
    ndkVersions = [ ndk ];
    cmakeVersions = [ cmake ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = lib.unique (map (p: p.type) profiles);
    abiVersions = lib.unique (map (p: p.abi) profiles);
  };

  # The SDK as a symlink tree with one file replaced: the ninja androidenv ships
  # inside cmake/ segfaults even on `--version`, so CMake gets nixpkgs' ninja.
  sdk = pkgs.runCommand "android-sdk" { } ''
    src=${android.androidsdk}/libexec/android-sdk
    mkdir $out
    for e in "$src"/*; do [ "''${e##*/}" = cmake ] || ln -s "$e" $out/; done
    cp -rsL "$src/cmake" $out/cmake
    chmod -R u+w $out/cmake
    ln -sf ${pkgs.ninja}/bin/ninja $out/cmake/${cmake}/bin/ninja
  '';

  profileCase = lib.concatMapStrings (p: ''
    ${p.name}) device=${p.device} image='system-images;android-${p.api};${p.type};${p.abi}' ram=${toString p.ramMB} disk=${toString p.diskGB} ;;
  '') profiles;
  profileList = lib.concatMapStrings (
    p: "  ${p.name}\t${p.device}, API ${p.api}, ${p.type}, ${toString p.ramMB} MB\\n"
  ) profiles;

  android-emulator = pkgs.writeShellScriptBin "android-emulator" ''
    set -euo pipefail
    if [ $# -eq 0 ] || [ "$1" = --list ]; then
      printf 'Usage: android-emulator <profile> [emulator flags, e.g. -no-window]\n\nProfiles:\n${profileList}'
      exit 0
    fi
    name=$1; shift
    case "$name" in
    ${profileCase}
      *) echo "unknown profile '$name'; run android-emulator --list" >&2; exit 1 ;;
    esac
    if ! avdmanager list avd -c 2>/dev/null | grep -qx "$name"; then
      echo no | avdmanager create avd --name "$name" --device "$device" --package "$image"
      cfg="$HOME/.android/avd/$name.avd/config.ini"
      sed -i '/^hw.ramSize/d;/^hw.keyboard/d;/^disk.dataPartition.size/d' "$cfg"
      printf 'hw.ramSize=%s\nhw.keyboard=yes\ndisk.dataPartition.size=%sG\n' "$ram" "$disk" >> "$cfg"
    fi
    exec emulator -avd "$name" -gpu auto -no-metrics -no-snapshot-save -camera-back none "$@"
  '';
in
pkgs.mkShell {
  packages = [
    android.androidsdk
    pkgs.jdk17
    pkgs.nodejs_22
    pkgs.eas-cli
    pkgs.maestro
    pkgs.watchman
    android-emulator
  ];

  ANDROID_HOME = sdk;
  ANDROID_SDK_ROOT = sdk;
  ANDROID_NDK_ROOT = "${sdk}/ndk/${ndk}";
  JAVA_HOME = pkgs.jdk17.home;
  # aapt2: the one Gradle pulls from Maven is an unpatched binary; use the SDK's.
  # cmakeVersion: read by Expo's autolinking plugin for every native module, so
  # libraries that name no version stop asking for AGP's default 3.22.1.
  GRADLE_OPTS = builtins.concatStringsSep " " [
    "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdk}/build-tools/${lib.last buildTools}/aapt2"
    "-Dorg.gradle.project.android.cmakeVersion=${cmake}"
  ];

  shellHook = ''
    export PATH="${sdk}/emulator:${sdk}/cmdline-tools/latest/bin:$PATH"
  '';
}
