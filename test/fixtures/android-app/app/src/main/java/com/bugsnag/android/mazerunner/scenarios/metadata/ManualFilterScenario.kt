package com.bugsnag.android.mazerunner.scenarios.metadata

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario

/**
 * Sends a handled exception to Bugsnag, which contains metadata that should be filtered
 */
internal class ManualFilterScenario : Scenario() {

    override fun run() {
        Bugsnag.setFilters("foo")
        Bugsnag.addToTab("user", "foo", "hunter2")
        Bugsnag.addToTab("custom", "foo", "hunter2")
        Bugsnag.addToTab("custom", "bar", "hunter2")
        Bugsnag.notify(RuntimeException("ManualFilterScenario"))
    }

}