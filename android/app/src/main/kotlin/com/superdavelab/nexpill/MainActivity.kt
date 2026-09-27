package com.superdavelab.nexpill

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the Flutter UI, plus the "nexpill/documents" channel used for backups.
 *
 * Backups go through Android's own Save and Open pickers (the Storage Access
 * Framework). The user chooses where the file goes; Nexpill only ever touches the one
 * document the user picked, and needs no storage permission to do it. This is a
 * few lines of platform code rather than a plugin so there is no dependency
 * that could merge a permission back into the manifest.
 */
class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null
    private val main = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // The installed version, shown in Settings so a bug report can say
        // which build it's about. Straight from the package manager rather
        // than a plugin.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "version") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val info = packageManager.getPackageInfo(packageName, 0)
                val code = if (Build.VERSION.SDK_INT >= 28) {
                    info.longVersionCode
                } else {
                    @Suppress("DEPRECATION") info.versionCode.toLong()
                }
                result.success(mapOf("name" to info.versionName, "code" to code))
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (pendingResult != null) {
                    result.error("busy", "A file picker is already open.", null)
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "save" -> launchPicker(
                        result,
                        Intent(Intent.ACTION_CREATE_DOCUMENT)
                            .addCategory(Intent.CATEGORY_OPENABLE)
                            .setType(call.argument<String>("mimeType") ?: "application/json")
                            .putExtra(Intent.EXTRA_TITLE, call.argument<String>("name")),
                        REQUEST_SAVE,
                        call.argument<ByteArray>("bytes"),
                    )
                    "open" -> launchPicker(
                        result,
                        Intent(Intent.ACTION_OPEN_DOCUMENT)
                            .addCategory(Intent.CATEGORY_OPENABLE)
                            // Providers label JSON inconsistently, so offer
                            // anything and let the Dart side validate it.
                            .setType("*/*"),
                        REQUEST_OPEN,
                    )
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Opens the system picker, or replies with an error straight away if it
     * can't — some stripped-down or managed devices have no document provider.
     * Either way nothing is left pending, so the next attempt isn't "busy".
     */
    private fun launchPicker(
        result: MethodChannel.Result,
        intent: Intent,
        requestCode: Int,
        bytes: ByteArray? = null,
    ) {
        pendingResult = result
        pendingBytes = bytes
        try {
            startActivityForResult(intent, requestCode)
        } catch (e: Exception) {
            pendingResult = null
            pendingBytes = null
            result.error("no_picker", "This phone has no file picker to use.", null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_SAVE && requestCode != REQUEST_OPEN) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingResult ?: return
        val bytes = pendingBytes
        pendingResult = null
        pendingBytes = null

        val uri: Uri? = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null) // backed out
            return
        }

        // File I/O off the main thread; reply on it, as the channel requires.
        Thread {
            try {
                if (requestCode == REQUEST_SAVE) {
                    contentResolver.openOutputStream(uri, "wt")!!.use { it.write(bytes!!) }
                    main.post { result.success(true) }
                } else {
                    val read = contentResolver.openInputStream(uri)!!.use {
                        it.readAtMost(MAX_BYTES + 1)
                    }
                    main.post {
                        if (read.size > MAX_BYTES) {
                            result.error("too_large", "That file is too large to be a Nexpill backup.", null)
                        } else {
                            result.success(read)
                        }
                    }
                }
            } catch (e: Exception) {
                main.post { result.error("io", e.message, null) }
            }
        }.start()
    }

    /** Reads at most [limit] bytes, so a huge file picked by mistake can't exhaust memory. */
    private fun java.io.InputStream.readAtMost(limit: Int): ByteArray {
        val out = java.io.ByteArrayOutputStream()
        val buf = ByteArray(8192)
        while (out.size() < limit) {
            val n = read(buf, 0, minOf(buf.size, limit - out.size()))
            if (n < 0) break
            out.write(buf, 0, n)
        }
        return out.toByteArray()
    }

    private companion object {
        const val CHANNEL = "nexpill/documents"
        const val APP_CHANNEL = "nexpill/app"
        const val REQUEST_SAVE = 0x4E01
        const val REQUEST_OPEN = 0x4E02

        /** Years of dose history for several patients is well under this. */
        const val MAX_BYTES = 20 * 1024 * 1024
    }
}
