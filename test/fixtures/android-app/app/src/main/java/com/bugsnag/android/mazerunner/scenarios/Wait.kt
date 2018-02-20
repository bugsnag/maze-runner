package com.bugsnag.android.mazerunner.scenarios

import android.util.Log

internal class Wait : Scenario() {

    override fun run() {
        Log.d("MazeRunner", "Waiting for test case delivery")
        Thread.sleep(1000)
    }

}
