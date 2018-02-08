package com.bugsnag.android

import android.net.ConnectivityManager

internal class DecoratedSessionApiClient(connectivityManager: ConnectivityManager?,
                                         private val callback: () -> Unit)
    : SessionTrackingApiClient {

    private val httpClient = DefaultHttpClient(connectivityManager)

    override fun postSessionTrackingPayload(urlString: String?,
                                            payload: SessionTrackingPayload?,
                                            headers: MutableMap<String, String>?) {
        try {
            httpClient.postSessionTrackingPayload(urlString, payload, headers)
        } catch (e: Exception) {
            callback()
        }
        callback()
    }

}
