package com.bugsnag.android.mazerunner

import com.bugsnag.android.mazerunner.testcases.TestCase
import com.bugsnag.android.mazerunner.testcases.kotlin.HandledException
import com.bugsnag.android.mazerunner.testcases.kotlin.HandledExceptionSession
import com.bugsnag.android.mazerunner.testcases.kotlin.UnhandledException
import com.bugsnag.android.mazerunner.testcases.kotlin.Wait

internal class TestCaseFactory {

    fun testCaseForName(eventType: String?): TestCase {
        return when (eventType) {
            "HandledException" -> HandledException()
            "HandledExceptionSession" -> HandledExceptionSession()
            "UnhandledException" -> UnhandledException()
            "Wait" -> Wait()
            else -> throw UnsupportedOperationException("Failed to find test case for eventType $eventType")
        }
    }

}
