package com.bugsnag.android.mazerunner

import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.widget.Button
import android.widget.EditText
import com.bugsnag.android.*
import java.lang.Exception
import java.net.URL
import kotlin.concurrent.thread
import org.json.JSONObject
import org.json.JSONTokener

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        Log.d("BugsnagMazeRunner", "Starting maze-runner")
        val button = findViewById<Button>(R.id.trigger_error)
        button.setOnClickListener {
            Log.d("BugsnagMazeRunner", "Trigger error clicked")
            val metadata = findViewById<EditText>(R.id.metadata).text.toString()
            val text = if (metadata == "") "HandledException!" else metadata
            Bugsnag.notify(Exception(text))
        }

        // Run command button
        button = findViewById<Button>(R.id.run_command)
        button.setOnClickListener {
            thread(start = true) {
                val command = URL("http://maze-local:9339/command").readText()
                val jsonObject = JSONTokener(command).nextValue() as JSONObject
                val metadata = jsonObject.getString("metadata")

                Bugsnag.notify(Exception(metadata))
            }
        }
    }

    override fun onResume() {
        super.onResume()
        startBugsnag()
    }

    private fun startBugsnag() {
        val config = Configuration("12312312312312312312312312312312")
        config.autoTrackSessions = false
        config.setEndpoints(EndpointConfiguration("http://maze-local:9339/notify", "http://maze-local:9339/sessions"))
        config.addOnError(OnErrorCallback { event ->
            Log.d("BugsnagMazeRunner", "CallbackRun")
            event.addMetadata("test", "boolean_false", false)
            event.addMetadata("test", "boolean_true", true)
            event.addMetadata("test", "float", 1.55)
            event.addMetadata("test", "integer", 2)
            event.addMetadata("test", "null", null)

            true
        })

        Bugsnag.start(this, config)
    }

}
