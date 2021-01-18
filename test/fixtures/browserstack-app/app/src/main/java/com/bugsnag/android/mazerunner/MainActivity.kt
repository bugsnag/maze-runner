package com.bugsnag.android.mazerunner

import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.widget.Button
import android.widget.EditText
import com.bugsnag.android.*
import java.lang.Exception

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val button = findViewById<Button>(R.id.trigger_error)
        button.setOnClickListener {
            val metadata = findViewById<EditText>(R.id.metadata).text.toString()
            val text = if (metadata == "") "HandledException!" else metadata
            Bugsnag.notify(Exception(text))
        }
    }

    override fun onResume() {
        super.onResume()
        startBugsnag()
    }

    private fun startBugsnag() {
        val config = Configuration("12312312312312312312312312312312")
        config.autoTrackSessions = false
        config.setEndpoints(EndpointConfiguration("http://localhost:9339/notify", "http://localhost:9339/sessions"))
        config.addOnError(OnErrorCallback { event ->
            event.addMetadata("test", "boolean_false", false)
            event.addMetadata("test", "boolean_true", true)
            event.addMetadata("test", "float", 1.55)
            event.addMetadata("test", "integer", 2)

            true
        })

        Bugsnag.start(this, config)
    }

}
