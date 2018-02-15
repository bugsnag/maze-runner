package com.bugsnag.android.mazerunner.scenarios.metadata

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario

/**
 * Sends a handled exception to Bugsnag, which includes manual context.
 */
internal class ManualContextScenario : Scenario() {

    override fun run() {
        Bugsnag.setContext("FooContext")
        Bugsnag.notify(RuntimeException("ManualContextScenario"))
    }

}