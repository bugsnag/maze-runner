package com.bugsnag.android.mazerunner.testcases.kotlin

import android.util.Log
import com.bugsnag.android.mazerunner.testcases.TestCase

internal class Wait : TestCase() {

    override fun run() {
        Log.d("MazeRunner", "Waiting for test case delivery")
        Thread.sleep(1000)
    }

}
