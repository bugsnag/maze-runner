package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.testcases.Scenario

/**
 * Sends a handled exception to Bugsnag, which does not include session data.
 */
internal class HandledExceptionScenario : Scenario() {

    override fun run() {
        Bugsnag.notify(RuntimeException("HandledExceptionScenario"))
    }

}
