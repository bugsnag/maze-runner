package com.bugsnag.android.mazerunner

import android.content.Context
import android.net.ConnectivityManager
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import com.bugsnag.android.*

class MainActivity : AppCompatActivity() {

    private val factory = TestCaseFactory()
    private lateinit var errorApiClient: ErrorReportApiClient
    private lateinit var sessionApiClient: SessionTrackingApiClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setupApiClients()
        initialiseBugsnag()
        executeTestCase()
    }

    private fun setupApiClients() {
        val connectivityManager: ConnectivityManager =
                getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        errorApiClient = DecoratedErrorApiClient(connectivityManager, this::onRequestCompleted)
        sessionApiClient = DecoratedSessionApiClient(connectivityManager, this::onRequestCompleted)
    }

    private fun initialiseBugsnag() {
        Bugsnag.init(this, null)
        Bugsnag.setErrorReportApiClient(errorApiClient)
        Bugsnag.setSessionTrackingApiClient(sessionApiClient)
    }

    private fun executeTestCase() {
        val eventType = intent.getStringExtra("EVENT_TYPE")
        Log.d("Bugsnag", "Received test case, executing " + eventType)
        val testCase = factory.testCaseForName(eventType)
        testCase.run()
    }

    private fun onRequestCompleted() {
        finish() // exit app after delivery
    }

}
