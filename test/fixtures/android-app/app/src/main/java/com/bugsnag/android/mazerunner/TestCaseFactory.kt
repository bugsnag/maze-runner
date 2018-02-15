package com.bugsnag.android.mazerunner

import com.bugsnag.android.mazerunner.scenarios.*
import com.bugsnag.android.mazerunner.scenarios.metadata.*
import com.bugsnag.android.mazerunner.scenarios.sessions.AutoSessionScenario
import com.bugsnag.android.mazerunner.scenarios.sessions.ManualSessionScenario
import com.bugsnag.android.mazerunner.scenarios.sessions.SessionCacheScenario

internal class TestCaseFactory {

    fun testCaseForName(eventType: String?): Scenario {
        return when (eventType) {
            "AutoContextScenario" -> AutoContextScenario()
            "AutoFilterScenario" -> AutoFilterScenario()
            "BreadcrumbScenario" -> BreadcrumbScenario()
            "DisableAutoNotifyScenario" -> DisableAutoNotifyScenario()
            "ManualContextScenario" -> ManualContextScenario()
            "MetaDataScenario" -> MetaDataScenario()
            "UserDisabledScenario" -> UserDisabledScenario()
            "UserEnabledScenario" -> UserEnabledScenario()
            "AutoSessionScenario" -> AutoSessionScenario()
            "ManualSessionScenario" -> ManualSessionScenario()
            "SessionCacheScenario" -> SessionCacheScenario()
            "CrashHandlerScenario" -> CrashHandlerScenario()
            "EmptyStacktraceScenario" -> EmptyStacktraceScenario()
            "GroupingHashScenario" -> GroupingHashScenario()
            "HandledExceptionScenario" -> HandledExceptionScenario()
            "HandledExceptionSessionScenario" -> HandledExceptionSessionScenario()
            "IgnoredExceptionScenario" -> IgnoredExceptionScenario()
            "InsideReleaseStageScenario" -> InsideReleaseStageScenario()
            "OomScenario" -> OomScenario()
            "OutsideReleaseStageScenario" -> OutsideReleaseStageScenario()
            "ReportCacheScenario" -> ReportCacheScenario()
            "StackOverflowScenario" -> StackOverflowScenario()
            "UnhandledExceptionScenario" -> UnhandledExceptionScenario()
            "UnhandledExceptionSessionScenario" -> UnhandledExceptionSessionScenario()
            "Wait" -> Wait()
            else -> throw UnsupportedOperationException("Failed to find test case for eventType $eventType")
        }
    }

}
