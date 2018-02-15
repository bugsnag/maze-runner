package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.testcases.Scenario

/**
 * Sends a manual session payload to Bugsnag.
 */
internal class ManualSessionScenario : Scenario() {

    override fun run() {
        Bugsnag.startSession()
        TODO("Need to fully implement flushing of sessions")
    }

}