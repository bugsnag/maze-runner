package com.bugsnag.android.mazerunner

import com.bugsnag.android.mazerunner.testcases.HandledExceptionCase
import com.bugsnag.android.mazerunner.testcases.TestCase

internal class TestCaseFactory {

    fun testCaseForName(eventType: String?): TestCase {
        return when (eventType) {
            "HandledException" -> HandledExceptionCase()
            else -> throw IllegalStateException("Failed to find test case for eventType $eventType")
        }
    }

}