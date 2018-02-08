package com.bugsnag.android.mazerunner

import android.content.Context
import android.net.ConnectivityManager
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
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
        val config = Configuration("a35a2a72bd230ac0aa0f52715bbdc6aa") // FIXME envars
        config.endpoint = "http://localhost:1234"
        config.sessionEndpoint = "http://localhost:1234"
        Bugsnag.init(this, config)
        Bugsnag.setErrorReportApiClient(errorApiClient)
        Bugsnag.setSessionTrackingApiClient(sessionApiClient)
    }

    private fun executeTestCase() {
        val eventType = intent.getStringExtra("EVENT_TYPE")
        val testCase = factory.testCaseForName(eventType)
        testCase.run()
    }

    private fun onRequestCompleted() {
        finish() // exit app after delivery
    }

}
