package com.bugsnag.android.mazerunner.scenarios

/**
 * Sends an unhandled exception which is cached on disk to Bugsnag.
 */
internal class ReportCacheScenario : Scenario() {

    override fun run() {
        throw RuntimeException("ReportCacheScenario")
    }

}