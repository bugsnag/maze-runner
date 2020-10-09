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
        button.setOnClickListener {
            Bugsnag.notify(Exception("HandledException!"), {
                val error = it.error!!
                error.metaData.addToTab("test", "boolean_false", false)
                error.metaData.addToTab("test", "boolean_true", true)
                error.metaData.addToTab("test", "float", 1.55)
                error.metaData.addToTab("test", "integer", 2)
            })
        }
    }

    override fun onResume() {
        super.onResume()
        initialiseBugsnag()
    }

    private fun initialiseBugsnag() {
        val config = Configuration("12312312312312312312312312312312")
        config.autoCaptureSessions = false
        config.setEndpoints("http://bs-local.com:9339", "http://bs-local.com:9339")

        Bugsnag.init(this, config)
        Bugsnag.setLoggingEnabled(true)
    }

}
