package com.bugsnag.android

import android.net.ConnectivityManager

internal class DecoratedErrorApiClient(connectivityManager: ConnectivityManager?,
                                       private val callback: () -> Unit) : ErrorReportApiClient {

    private val httpClient = DefaultHttpClient(connectivityManager)

    override fun postReport(urlString: String?,
                            report: Report?,
                            headers: MutableMap<String, String>?) {
        try {
            httpClient.postReport(urlString, report, headers)

        } catch (e: Exception) {
            callback()
        }
        callback()
    }

}
