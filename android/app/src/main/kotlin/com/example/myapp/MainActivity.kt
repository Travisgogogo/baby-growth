package com.example.myapp

import android.app.DownloadManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.widget.Toast
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.myapp/update"
    private var downloadId: Long = -1
    private lateinit var downloadReceiver: BroadcastReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "downloadAndInstallApk" -> {
                    val url = call.argument<String>("url")
                    val fileName = call.argument<String>("fileName") ?: "app-release.apk"
                    if (url != null) {
                        downloadApk(url, fileName)
                        result.success(null)
                    } else {
                        result.error("INVALID_URL", "URL is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun downloadApk(url: String, fileName: String) {
        // Android 10+ DownloadManager 不需要存储权限
        val request = DownloadManager.Request(Uri.parse(url))
            .setTitle("正在下载更新")
            .setDescription("宝宝成长记")
            .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
            .setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
            .setAllowedOverMetered(true)
            .setAllowedOverRoaming(true)

        val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        downloadId = dm.enqueue(request)

        // 注册下载完成监听
        downloadReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val id = intent?.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1)
                if (id == downloadId) {
                    installApk(fileName)
                    unregisterReceiver(downloadReceiver)
                }
            }
        }

        registerReceiver(downloadReceiver, IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) Context.RECEIVER_NOT_EXPORTED else 0)
        Toast.makeText(this, "开始下载更新...", Toast.LENGTH_SHORT).show()
    }

    private fun installApk(fileName: String) {
        val file = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), fileName)
        if (!file.exists()) {
            Toast.makeText(this, "下载失败", Toast.LENGTH_SHORT).show()
            return
        }

        val intent = Intent(Intent.ACTION_VIEW).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            
            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                FileProvider.getUriForFile(this@MainActivity, "${packageName}.fileprovider", file)
            } else {
                Uri.fromFile(file)
            }
            setDataAndType(uri, "application/vnd.android.package-archive")
        }

        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::downloadReceiver.isInitialized) {
            try {
                unregisterReceiver(downloadReceiver)
            } catch (e: Exception) {
                // Ignore
            }
        }
    }
}
