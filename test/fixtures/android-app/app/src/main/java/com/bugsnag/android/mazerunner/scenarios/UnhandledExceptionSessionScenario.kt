package com.bugsnag.android.mazerunner.scenarios

import com.bugsnag.android.Bugsnag

/**
 * Sends an unhandled exception to Bugsnag, which includes Session data.
 */
internal class UnhandledExceptionSessionScenario : Scenario() {

    override fun run() {
        disableSessionDelivery()
        Bugsnag.startSession()
        throw RuntimeException("UnhandledExceptionSessionScenario")
    }

}