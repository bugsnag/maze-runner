package com.bugsnag.android.mazerunner.scenarios.metadata

import com.bugsnag.android.BreadcrumbType
import com.bugsnag.android.Bugsnag
import com.bugsnag.android.mazerunner.scenarios.Scenario
import java.util.*

/**
 * Sends a handled exception to Bugsnag, which includes manual breadcrumbs.
 */
internal class BreadcrumbScenario : Scenario() {

    override fun run() {
        Bugsnag.leaveBreadcrumb("Hello Breadcrumb!")
        Bugsnag.leaveBreadcrumb("Another Breadcrumb", BreadcrumbType.USER, Collections.singletonMap("Foo", "Bar"))
        Bugsnag.notify(RuntimeException("BreadcrumbScenario"))
    }

}
