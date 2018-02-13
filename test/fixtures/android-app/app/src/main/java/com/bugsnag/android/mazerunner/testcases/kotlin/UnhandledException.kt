package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.mazerunner.testcases.TestCase

internal class UnhandledException : TestCase() {

    override fun run() {
        disableAllDelivery()
        throw RuntimeException("UnhandledException")
    }

}