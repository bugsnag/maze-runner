package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.mazerunner.testcases.Scenario

/**
 * Sends an unhandled exception which is cached on disk to Bugsnag
 */
internal class ReportCacheScenario : Scenario() {

    override fun run() {
        throw RuntimeException("ReportCacheScenario")
    }

}