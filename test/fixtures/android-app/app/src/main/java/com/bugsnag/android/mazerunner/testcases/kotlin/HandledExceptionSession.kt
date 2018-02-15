package com.bugsnag.android.mazerunner.testcases.kotlin

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.testcases.TestCase

internal class HandledExceptionSession : TestCase() {

    override fun run() {
        disableSessionDelivery()
        Bugsnag.notify(RuntimeException("HandledExceptionSession"))
    }

}
