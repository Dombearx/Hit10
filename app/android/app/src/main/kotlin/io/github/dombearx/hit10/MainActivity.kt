package io.github.dombearx.hit10

import android.content.Context
import android.media.AudioManager
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// A fragment activity so it can call AndroidX's enableEdgeToEdge().
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Edge to edge on every Android version, not only 15+ where it is
        // forced (Play's recommendation); the game keeps clear of the
        // system bars with SafeArea.
        enableEdgeToEdge()
    }

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
