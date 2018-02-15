package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.testcases.Scenario

/**
 * Sends a handled exception to Bugsnag, which includes Session data.
 */
internal class HandledExceptionSessionScenario : Scenario() {

    override fun run() {
        disableSessionDelivery()
        Bugsnag.startSession()
        Bugsnag.notify(RuntimeException("HandledExceptionSessionScenario"))
    }

}
