package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.mazerunner.testcases.Scenario

/**
 * Sends an unhandled exception to Bugsnag.
 */
internal class UnhandledExceptionScenario : Scenario() {

    override fun run() {
        disableAllDelivery()
        throw RuntimeException("UnhandledExceptionScenario")
    }

}
