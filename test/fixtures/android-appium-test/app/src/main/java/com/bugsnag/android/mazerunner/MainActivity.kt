package com.bugsnag.android.mazerunner

import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.widget.Button
import android.widget.EditText
import com.bugsnag.android.*
import java.io.File
import java.lang.Exception
import java.lang.Thread
import java.net.URL
import kotlin.concurrent.thread
import org.json.JSONObject
import org.json.JSONTokener

const val CONFIG_FILE_TIMEOUT = 5000

class MainActivity : AppCompatActivity() {

    var mazeAddress: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        var button = findViewById<Button>(R.id.trigger_error)
        button.setOnClickListener {
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

    private fun setMazeRunnerAddress() {
        val context = getApplicationContext()
        val externalFilesDir = context.getExternalFilesDir(null)
        val configFile = File(externalFilesDir, "fixture_config.json")
        log("Attempting to read Maze Runner address from config file ${configFile.path}")

        // Poll for the fixture config file
        val pollEnd = System.currentTimeMillis() + CONFIG_FILE_TIMEOUT
        while (System.currentTimeMillis() < pollEnd) {
            if (configFile.exists()) {
                val fileContents = configFile.readText()
                val fixtureConfig = runCatching { JSONObject(fileContents) }.getOrNull()
                mazeAddress = getStringSafely(fixtureConfig, "maze_address")
                if (!mazeAddress.isNullOrBlank()) {
                    log("Maze Runner address set from config file: $mazeAddress")
                    break
                }
            }

            Thread.sleep(250)
        }

        // Assume we are running in legacy mode on BrowserStack
        if (mazeAddress.isNullOrBlank()) {
            log("Failed to read Maze Runner address from config file, reverting to legacy BrowserStack address")
            mazeAddress = "bs-local.com:9339"
        }
    }

    // As per JSONObject.getString but returns and empty string rather than throwing if not present
    private fun getStringSafely(jsonObject: JSONObject?, key: String): String {
        return jsonObject?.optString(key) ?: ""
    }

    private fun log(msg: String) {
        Log.d("BugsnagMazeRunner", msg)
    }

    private fun startBugsnag() {
        if (mazeAddress == null) setMazeRunnerAddress()
        val config = Configuration("12312312312312312312312312312312")
        config.autoTrackSessions = false
        config.setEndpoints(EndpointConfiguration("http://$mazeAddress/notify", "http://$mazeAddress/sessions"))
        config.addOnError(OnErrorCallback { event ->
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
