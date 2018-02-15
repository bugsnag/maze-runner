package com.bugsnag.android.mazerunner.scenarios

/**
 * Sends an unhandled exception to Bugsnag.
 */
internal class UnhandledExceptionScenario : Scenario() {

    override fun run() {
        disableAllDelivery()
        throw RuntimeException("UnhandledExceptionScenario")
    }

}
