package com.bugsnag.android.mazerunner.scenarios.metadata

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario

/**
 * Sends a handled exception to Bugsnag, which contains metadata that should be filtered
 */
internal class AutoFilterScenario : Scenario() {

    override fun run() {
        Bugsnag.addToTab("user", "password", "hunter2")
        Bugsnag.addToTab("custom", "password", "hunter2")
        Bugsnag.addToTab("custom", "foo", "hunter2")
        Bugsnag.notify(RuntimeException("AutoFilterScenario"))
    }

}
