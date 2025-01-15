package com.example.example
import android.app.ActivityManager
import android.content.ComponentName
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.util.Log
import androidx.core.app.ActivityCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.content.pm.PackageManager
import android.Manifest
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper
class MyFirebaseMessagingService : FirebaseMessagingService() {
    companion object {
        private const val CHANNEL_ID = "call_notifications_channel"
        private const val TAG = "MyFirebaseMessagingService"
        private const val FLUTTER_CHANNEL = "ack"
        var methodChannel: MethodChannel? = null
        fun setFlutterEngine(flutterEngine: FlutterEngine) {
            methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL)
        }
    }
    private var telecomManager: TelecomManager? = null
    private var phoneAccountHandle: PhoneAccountHandle? = null
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d(TAG, "onMessageReceived native side called")
        // Check if the app is in the foreground or background
        // if (!isAppInBackground()) {
        //     Log.d(TAG, "App is in foreground, skipping native handling. Logic is handled in Flutter.")
        //     return
        // }
        Log.d(TAG, "App is in background, proceeding with native handling.")
        val data = remoteMessage.data
        Log.d(TAG, "Received notification data: $data")
        if (data.isNotEmpty()) {
            val callerId = data["callerInfo"]
            val roomId = data["roomId"]
            val type = data["type"]
            if (callerId != null && roomId != null && type == null) {
                Log.d(TAG, "Incoming call from: $callerId, Room ID: $roomId")
                handleIncomingCall(callerId, roomId)
                // Send data to Flutter on the main thread
                Handler(Looper.getMainLooper()).post {
                    sendToFlutter(callerId, roomId)
                }
            }
        }
    }
    private fun sendToFlutter(callerId: String, roomId: String) {
        if (methodChannel != null) {
            // Ensure this runs on the main thread
            Handler(Looper.getMainLooper()).post {
                methodChannel?.invokeMethod("onIncomingCall", mapOf("callerId" to callerId, "roomId" to roomId))
                Log.d(TAG, "Data sent to Flutter: Caller ID - $callerId, Room ID - $roomId")
            }
        } else {
            Log.e(TAG, "MethodChannel is not initialized.")
        }
    }
    private fun handleIncomingCall(callerId: String, roomId: String) {
        initializeTelecomManager() // Ensure telecomManager and phoneAccountHandle are initialized
        if (!isPhoneAccountRegistered()) {
            Log.w(TAG, "Phone account not registered. Cannot handle incoming call.")
            return
        }
        if (!hasReadPhoneStatePermission()) {
            Log.e(TAG, "READ_PHONE_STATE permission not granted.")
            return
        }
        val extras = Bundle().apply {
            val uri = Uri.fromParts("tel", callerId, null)
            putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, uri)
            putString("roomId",roomId)
            putString("callerId",callerId)
        }
        try {
            telecomManager?.addNewIncomingCall(phoneAccountHandle, extras)
            Log.d(TAG, "Incoming call handled successfully for Caller ID: $callerId")
        } catch (cause: Throwable) {
            Log.e(TAG, "Error handling incoming call", cause)
        }
    }
    private fun initializeTelecomManager() {
        if (telecomManager == null || phoneAccountHandle == null) {
            telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val componentName = ComponentName(this, CallConnectionService::class.java)
            phoneAccountHandle = PhoneAccountHandle(componentName, "DhirajAccountId")
            Log.d(TAG, "TelecomManager and PhoneAccountHandle initialized.")
        }
    }
    private fun isPhoneAccountRegistered(): Boolean {
        val phoneAccounts = telecomManager?.callCapablePhoneAccounts ?: return false
        return phoneAccounts.contains(phoneAccountHandle)
    }
    private fun hasReadPhoneStatePermission(): Boolean {
        return ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED
    }
    private fun isAppInBackground(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningAppProcesses = activityManager.runningAppProcesses ?: return true
        for (processInfo in runningAppProcesses) {
            if (processInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                && processInfo.processName == packageName
            ) {
                return false // App is in foreground
            }
        }
        return true // App is in background
    }
}