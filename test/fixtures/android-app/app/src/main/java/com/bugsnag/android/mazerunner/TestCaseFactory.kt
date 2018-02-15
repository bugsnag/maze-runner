package com.bugsnag.android.mazerunner

import com.bugsnag.android.mazerunner.testcases.Scenario
import com.bugsnag.android.mazerunner.testcases.kotlin.HandledExceptionScenario
import com.bugsnag.android.mazerunner.testcases.kotlin.HandledExceptionSessionScenario
import com.bugsnag.android.mazerunner.testcases.kotlin.UnhandledExceptionScenario
import com.bugsnag.android.mazerunner.testcases.kotlin.Wait

internal class TestCaseFactory {

    fun testCaseForName(eventType: String?): Scenario {
        return when (eventType) {
            "HandledExceptionScenario" -> HandledExceptionScenario()
            "HandledExceptionSessionScenario" -> HandledExceptionSessionScenario()
            "UnhandledExceptionScenario" -> UnhandledExceptionScenario()
            "Wait" -> Wait()
            else -> throw UnsupportedOperationException("Failed to find test case for eventType $eventType")
        }
    }


//    Breadcrumbs	The notifier should attach breadcrumbs where appropriate	Which events trigger breadcrumbs? Test that the various events attach breadcrumbs and of the correct type.
//    Release-stage The notifier should respect the release stage configuration
//
//    Test that the default configuration sends error reports, test that
//    Callbacks	The notifier should attach additional meta-data through callbacks, or should not send the error if indicated	Filtering/removing metadata, adding metadata, cancelling delivery, changing error class/message, setting grouping hash ...
//    Ignored errors/exceptions	The notifier should respect ignored error/exception lists	Test that the default ignored errors are ignored, and that changes are respected
//    Stacktrace	The event should contain an appropriate stacktrace
//    Filters	The event should not contain any content that should be filtered, whether by default or user configuration	Test that default filters are respected, and can be changed
//    Auto capture sessions	When enabled, sessions should be sent automatically	Test that the session payload has the required fields, that the correct number are sent
//    MetaData	The notifier should append custom metadata to an Error Report
//    User	The notifier should send user information if this is enabled	Should send information if enabled, should not send any if disabled
//    Context	The notifier should send the context in the report	Automatic, manual
//    AutoNotify	The notifier should not send an Error Report if it has been disabled
//    App Version	The notifier should send the app version in Error report	Automatic detection, manual override
//    Other crash handlers	The notifier should send an Error Report even if another crash handler is installed	Language-default crash handler, BuddyBuild, Sentry
//    StackOverflow	The notifier should be able to send an error report of a StackOverflow
//    OutOfMemoryError	The notifier should be able to send an error report if no more memory is available
//    Empty Stacktrace	The notifier should send an error report even if there is an empty stacktrace
//    Kotlin	The notifier should send an error report thrown in Kotlin code


}
