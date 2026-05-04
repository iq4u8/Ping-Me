package com.pingme.pingme_flutter

import android.content.ComponentName
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.pingme.app/icon"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "changeIcon") {
                val iconName = call.argument<String>("iconName")
                if (iconName != null) {
                    changeAppIcon(iconName)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "Icon name cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun changeAppIcon(iconName: String) {
        val pm = packageManager
        
        // Define component names
        val defaultComponent = ComponentName(this, "com.pingme.pingme_flutter.MainActivity")
        val darkComponent = ComponentName(this, "com.pingme.pingme_flutter.MainActivityDark")

        // Enable chosen icon and disable the other
        if (iconName == "dark") {
            pm.setComponentEnabledSetting(
                darkComponent,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
            pm.setComponentEnabledSetting(
                defaultComponent,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        } else {
            pm.setComponentEnabledSetting(
                defaultComponent,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
            pm.setComponentEnabledSetting(
                darkComponent,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}
