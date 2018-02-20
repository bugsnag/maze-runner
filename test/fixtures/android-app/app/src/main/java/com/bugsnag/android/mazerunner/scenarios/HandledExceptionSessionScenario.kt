package com.bugsnag.android.mazerunner.scenarios

import com.bugsnag.android.Bugsnag

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
