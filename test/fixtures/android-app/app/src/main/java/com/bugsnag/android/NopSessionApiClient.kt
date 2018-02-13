package com.bugsnag.android

internal class NopSessionApiClient : SessionTrackingApiClient {

    override fun postSessionTrackingPayload(urlString: String?,
                                            payload: SessionTrackingPayload?,
                                            headers: MutableMap<String, String>?) {
    }

}