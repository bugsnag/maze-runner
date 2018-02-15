package com.bugsnag.android.mazerunner.scenarios.metadata

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario

/**
 * Sends a handled exception to Bugsnag, which contains metadata that should be filtered
 */
internal class AutoFilterScenario : Scenario() {

    override fun run() {
        Bugsnag.notify(RuntimeException("AutoFilterScenario"), {
            it.error?.addToTab("User", "password", "hunter2")
        })
    }

}