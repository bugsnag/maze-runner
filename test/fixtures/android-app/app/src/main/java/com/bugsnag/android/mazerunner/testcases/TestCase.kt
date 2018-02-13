package com.bugsnag.android.mazerunner.testcases

import com.bugsnag.android.Bugsnag
import com.bugsnag.android.NetworkException

abstract internal class TestCase {

    abstract fun run()

    /**
     * Sets a NOP implementation for the Session Tracking API, preventing delivery
     */
    protected fun disableSessionDelivery() {
        Bugsnag.setSessionTrackingApiClient({ _, _, _ ->
            throw NetworkException("Session Delivery NOP", RuntimeException("NOP"))
        })
    }

    /**
     * Sets a NOP implementation for the Error Tracking API, preventing delivery
     */
    protected fun disableReportDelivery() {
        Bugsnag.setErrorReportApiClient({ _, _, _ ->
            throw NetworkException("Error Delivery NOP", RuntimeException("NOP"))
        })
    }

    protected fun disableAllDelivery() {
        disableSessionDelivery()
        disableReportDelivery()
    }

}
