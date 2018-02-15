package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.testcases.Scenario

/**
 * Sends an unhandled exception to Bugsnag, which includes Session data.
 */
internal class UnhandledExceptionSessionScenario : Scenario() {

    override fun run() {
        disableSessionDelivery()
        Bugsnag.startSession()
        throw RuntimeException("HandledExceptionSessionScenario")
    }

}