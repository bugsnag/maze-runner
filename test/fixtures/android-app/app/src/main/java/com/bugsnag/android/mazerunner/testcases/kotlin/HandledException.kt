package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.testcases.TestCase

internal class HandledException : TestCase() {

    override fun run() {
        Bugsnag.notify(RuntimeException("HandledException"))
    }

}
