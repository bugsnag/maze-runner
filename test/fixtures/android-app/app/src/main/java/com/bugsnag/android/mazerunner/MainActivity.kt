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
        // setupApiClients()
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
        val config = Configuration(intent.getStringExtra("BUGSNAG_API_KEY"))
        // Probably something smarter goes here, to also work on devices
        config.endpoint = "http://10.0.2.2:" + intent.getStringExtra("BUGSNAG_PORT")
        config.sessionEndpoint = "http://10.0.2.2:" + intent.getStringExtra("BUGSNAG_PORT")

        Bugsnag.init(this, config)
    }

    private fun executeTestCase() {
        val eventType = intent.getStringExtra("EVENT_TYPE")
        Log.d("Bugsnag", "Received test case, executing " + eventType)
        val testCase = factory.testCaseForName(eventType)
        testCase.run()
    }

    private fun onRequestCompleted() {
        //finish() // exit app after delivery
    }

}
