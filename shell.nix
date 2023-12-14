{pkgs ? import <nixpkgs> {config.android_sdk.accept_license = true;}}: let
  android = pkgs.callPackage ./nix/android.nix {};
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      # from pkgs
      flutter
      jdk11
      #from ./nix/*
      android.platform-tools
    ];

    ANDROID_HOME = "${android.androidsdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${android.androidsdk}/libexec/android-sdk";
    JAVA_HOME = pkgs.jdk11;
    ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${android.androidsdk}/libexec/android-sdk/build-tools/33.0.1/aapt2";
  }
