package com.bugsnag.android.mazerunner

import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.widget.Button
import com.bugsnag.android.*
import java.lang.Exception

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val button = findViewById<Button>(R.id.trigger_error)
        button.setOnClickListener { Bugsnag.notify(Exception("HandledException!")) }
    }

    override fun onResume() {
        super.onResume()
        initialiseBugsnag()
    }

    private fun initialiseBugsnag() {
        val config = Configuration("12312312312312312312312312312312")
        config.endpoint = "http://localhost:9339"
        config.sessionEndpoint = "http://localhost:9339"

        Bugsnag.init(this, config)
        Bugsnag.setLoggingEnabled(true)
    }

}
