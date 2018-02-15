package com.bugsnag.android.mazerunner.scenarios

import com.bugsnag.android.Bugsnag

/**
 * Sends a handled exception to Bugsnag, which uses a custom grouping hash
 */
internal class GroupingHashScenario : Scenario() {

    override fun run() {
        Bugsnag.notify(RuntimeException("GroupingHashScenario"), {
            it.error?.setGroupingHash("abcdefg")
        })
    }

}