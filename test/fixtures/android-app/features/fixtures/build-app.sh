#!/usr/bin/env bash

function build_app() {
  pwd
  cd features/android-app
  ./gradlew clean app:assembleRelease
}

function launch_emulator() {
  echo "Launching Android Emulator"
  # see https://developer.android.com/studio/run/emulator-commandline.html#starting
  # always run from tools dir rather than android home due to rel path bug
  $ANDROID_HOME/tools/emulator @newnexus &
  EMULATOR_PID=$!
  wait_for_device
}

# Waits for boot to complete (see https://android.stackexchange.com/a/83747)
function wait_for_device() {
    echo "Waiting for device..."
    adb wait-for-device
    echo "Device booting, this may take several minutes..."

    A=$(adb shell getprop sys.boot_completed | tr -d '\r')

    while [ "$A" != "1" ]; do
        sleep 2
        echo "Polling device status"
        A=$(adb shell getprop sys.boot_completed | tr -d '\r')
    done
    echo "Device ready!"
}

function poll_app() {
  # Detect whether app is still in the foreground (app kills its own process when completed)
  while [[ `adb shell dumpsys activity | grep "Proc # 0" | grep "com.bugsnag.android.mazerunner"` ]];
   do echo "Polling Android App"
   sleep 2
  done
}

function install_apk() {
  echo "Installing APK, removing any previous versions"
  adb uninstall com.bugsnag.android.mazerunner
  adb install app/build/outputs/apk/release/app-release.apk
}

build_app
launch_emulator
install_apk
