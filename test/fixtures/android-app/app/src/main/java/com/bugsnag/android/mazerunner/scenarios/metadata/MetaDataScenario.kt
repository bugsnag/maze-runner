package com.bugsnag.android.mazerunner.scenarios.metadata

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario

/**
 * Sends a handled exception to Bugsnag, which includes custom metadata
 */
internal class MetaDataScenario : Scenario() {

    override fun run() {
        Bugsnag.notify(RuntimeException("MetaDataScenario"), {
            it.error?.addToTab("Custom", "foo", "Hello World!")
        })
    }

}
