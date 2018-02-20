package com.bugsnag.android.mazerunner.scenarios.metadata

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario

/**
 * Sends a handled exception to Bugsnag, which includes automatic context.
 */
internal class AutoContextScenario : Scenario() {

    override fun run() {
        Bugsnag.notify(RuntimeException("AutoContextScenario"))
    }

}
