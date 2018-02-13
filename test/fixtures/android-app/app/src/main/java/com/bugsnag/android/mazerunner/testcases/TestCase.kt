package com.bugsnag.android.mazerunner.testcases

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.NopErrorApiClient
import com.bugsnag.android.NopSessionApiClient

abstract internal class TestCase {

    abstract fun run()

    /**
     * Sets a NOP implementation for the Session Tracking API, preventing delivery
     */
    protected fun disableSessionDelivery() {
        Bugsnag.setSessionTrackingApiClient(NopSessionApiClient())
    }

    /**
     * Sets a NOP implementation for the Error Tracking API, preventing delivery
     */
    protected fun disableReportDelivery() {
        Bugsnag.setErrorReportApiClient(NopErrorApiClient())
    }

    protected fun disableAllDelivery() {
        disableSessionDelivery()
        disableReportDelivery()
    }

}
