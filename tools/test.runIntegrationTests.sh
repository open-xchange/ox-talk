#!/bin/bash

# Constants
TARGET_ANDROID="android"
TARGET_IOS="ios"
LOG_FOLDER=test_driver/logs
LOG_FILE=${LOG_FOLDER}/log.txt

# Parameters
target=$1
deviceId=$2
appId=$3

# Variables
success=0
failed=0
testResult=-1
startTime=$SECONDS

# Functions
function error {
    echo >&2 $1
    exit $2
}
function isInstalled {
    command -v $1 >/dev/null 2>&1 || error "'$1' is not installed." 2
}

function setupIos {
    applesimutils --byId ${deviceId} --bundle ${appId} --setPermissions "camera=YES, contacts=YES, calendar=YES, photos=YES, speech=YES, microphone=YES, medialibrary=YES, notifications=YES, faceid=YES, homekit=YES, location=always, reminders=unset, motion=YES"
}

function setupAndroid {
    export FLUTTER_TEST_DEVICE_ID=${deviceId}
    export FLUTTER_TEST_APP_ID=${appId}
}

# Setup
if [[ "$#" = 0 ]]; then
    echo "Usage of $0:"
    echo
    echo "1. parameter:     Target [android, ios]"
    echo "2. parameter:     Emulator / device id [One of the devices listed when executing 'flutter devices'. Use one of the entries from the second column.]"
    echo "3. parameter:     App id / bundle identifier"
    echo
    echo "Example android:  ./test.runIntegrationTests.sh android emulator-8888 com.openxchange.oxcoi.dev"
    echo "Example iOS:      ./test.runIntegrationTests.sh ios abc-simulator-12345 com.openxchange.oxcoi.dev"
    exit 0
fi

if [[ -z ${target} ]]; then
    error "No target specified. Available targets are: android, ios" 1
fi

if [[ -z ${deviceId} ]]; then
    error "No emulator / device specified. Available targets can be listed via 'flutter devices'." 1
fi

if [[ -z ${appId} ]]; then
    error "No app id / bundle identifier specified." 1
fi

isInstalled flutter

if [[ ${target} = ${TARGET_ANDROID} ]]; then
    isInstalled adb
    setupAndroid
elif [[ ${target} = ${TARGET_IOS} ]]; then
    isInstalled applesimutils
fi

cd ..
if [[ ! -d "$LOG_FOLDER" ]]; then
    mkdir ${LOG_FOLDER}
fi
if [[ -f "$LOG_FILE" ]]; then
    rm ${LOG_FILE}
fi
touch ${LOG_FILE}

# Execution
for test in test_driver/*
do
    if [[ -f "$test" ]]; then
        echo "### Running test: $test"
        if [[ ${target} = ${TARGET_ANDROID} ]]; then
            flutter drive -d ${deviceId} --target=test_driver/setup/app.dart --driver=${test} --flavor development >> ${LOG_FILE} 2>&1
            testResult=$?
        elif [[ ${target} = ${TARGET_IOS} ]]; then
            setupIos
            sleep 1
            flutter drive -d ${deviceId} --target=test_driver/setup/app.dart --driver=${test} >> ${LOG_FILE} 2>&1 # TODO add flavor as soon as iOS support is given
            testResult=$?
            xcrun simctl uninstall ${deviceId} ${appId}
        fi
        if [[ ${testResult} -eq 0 ]]; then
            echo "  [OK] $test"
            ((success++))
        else
            echo "  [FAIL] $test - See (${LOG_FILE})"
            ((failed++))
        fi
    fi
done

echo

testCount=$((success + failed))
runTime=$(($SECONDS - $startTime))
warnings="No warnings found"
if grep -i "Exception" ${LOG_FILE} >/dev/null; then
   warnings="Exceptions were found in the generated log (${LOG_FILE})"
fi
echo "### Test suite finished in $runTime seconds"
echo "  [All]: $testCount"
echo "  [OK]: $success successfully finished"
echo "  [WARN]: $warnings"
echo "  [FAIL]: $failed errors occurred"
