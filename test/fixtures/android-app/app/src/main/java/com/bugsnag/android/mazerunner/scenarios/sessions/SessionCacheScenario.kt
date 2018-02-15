package com.bugsnag.android.mazerunner.scenarios.sessions

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario

/**
 * Sends a manual session payload to Bugsnag, that has been cached on disk.
 */
internal class SessionCacheScenario : Scenario() {

    override fun run() {
        disableAllDelivery()
        Bugsnag.startSession()
        TODO("Need to fully implement flushing of sessions")
    }

}