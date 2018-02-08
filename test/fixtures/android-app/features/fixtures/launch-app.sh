#!/usr/bin/env bash

#     "EVENT_TYPE=$EVENT_TYPE" \
#     "BUGSNAG_API_KEY=$BUGSNAG_API_KEY" \
#     "MOCK_API_PATH=http://localhost:$MOCK_API_PORT"


function poll_app() {
  # Detect whether app is still in the foreground (app kills its own process when completed)
  while [[ `adb shell dumpsys activity | grep "Proc # 0" | grep "com.bugsnag.android.mazerunner"` ]];
   do echo "Polling Android App"
   sleep 2
  done
}

# Clear any existing data
echo "Launching MainActivity"
adb shell clear com.bugsnag.android.mazerunner

echo "Launching MainActivity"
adb shell am start -n com.bugsnag.android.mazerunner/com.bugsnag.android.mazerunner.MainActivity
poll_app

echo "Killing app process"
adb shell am force-stop com.bugsnag.android.mazerunner

# launch again, with session sending enabled
sleep 2 # wait for app to close
echo "Launching MainActivity again"
adb shell am start -n com.bugsnag.android.mazerunner/com.bugsnag.android.mazerunner.MainActivity --es EVENT_TYPE "boo"
poll_app
echo "Android App finished"
