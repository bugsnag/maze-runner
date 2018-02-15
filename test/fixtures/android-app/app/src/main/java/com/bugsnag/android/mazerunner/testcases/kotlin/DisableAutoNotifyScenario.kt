package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.testcases.Scenario

/**
 * Attempts to send a handled exception to Bugsnag, when the exception handler is disabled,
 * which should result in no operation.
 */
internal class DisableAutoNotifyScenario : Scenario() {

    override fun run() {
        Bugsnag.disableExceptionHandler()
        Bugsnag.notify(RuntimeException("HandledExceptionScenario"))
    }

}