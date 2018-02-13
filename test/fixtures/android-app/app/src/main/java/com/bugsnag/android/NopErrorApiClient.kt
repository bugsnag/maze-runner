package com.bugsnag.android

internal class NopErrorApiClient : ErrorReportApiClient {

    override fun postReport(urlString: String?,
                            report: Report?,
                            headers: MutableMap<String, String>?) {
    }
}