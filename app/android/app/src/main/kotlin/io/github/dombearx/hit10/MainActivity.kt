package io.github.dombearx.hit10

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // docs/04 U-20: if the player already listens to something, our
        // music starts silent.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hit10/audio")
            .setMethodCallHandler { call, result ->
                if (call.method == "otherMusicPlaying") {
                    val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    result.success(am.isMusicActive)
                } else {
                    result.notImplemented()
                }
            }
    }
}
