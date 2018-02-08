package com.bugsnag.android.mazerunner.testcases

import com.bugsnag.android.Bugsnag

internal class HandledExceptionCase: TestCase {

    override fun run() {
        Bugsnag.notify(RuntimeException("Hello World"))
    }

}
