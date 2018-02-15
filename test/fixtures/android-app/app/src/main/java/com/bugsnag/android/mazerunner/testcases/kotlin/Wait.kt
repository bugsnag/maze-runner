package com.bugsnag.android.mazerunner.testcases.kotlin

import android.util.Log
import com.bugsnag.android.mazerunner.testcases.Scenario

internal class Wait : Scenario() {

    override fun run() {
        Log.d("MazeRunner", "Waiting for test case delivery")
        Thread.sleep(1000)
    }

}
