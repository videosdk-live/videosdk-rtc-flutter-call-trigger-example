
package com.example.example
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.telecom.Connection
import android.telecom.ConnectionRequest
import android.telecom.ConnectionService
import android.telecom.TelecomManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
class CallConnectionService : ConnectionService() {
companion object {
        private const val CHANNEL = "com.example.example/calls"
        private var methodChannel: MethodChannel? = null
        fun setFlutterEngine(flutterEngine: FlutterEngine) {
            methodChannel = MethodChannel(flutterEngine.dartExecutor, CHANNEL)
        }
    }
    override fun onCreateIncomingConnection(
        connectionManagerPhoneAccount: android.telecom.PhoneAccountHandle?,
        request: ConnectionRequest?
    ): Connection {
        val connection = object : Connection() {
            override fun onAnswer() {
                super.onAnswer()

                val extras = request?.extras
                val roomId = extras?.getString("roomId")
                val callerId = extras?.getString("callerId")

                Log.d("CallConnectionService", "Call Answered")
                Log.d("Room ID:", roomId ?: "null")
                Log.d("Caller ID:", callerId ?: "null")

                // Generate deep link for the meeting screen
                val deepLink = "exampleapp://open/meeting?roomId=$roomId&callerId=$callerId"

                val intent = Intent(Intent.ACTION_VIEW).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    data = Uri.parse(deepLink)
                }
                startActivity(intent)
                destroy()
            }

            override fun onReject() {
                super.onReject()

                val extras = request?.extras
                val callerId = extras?.getString("callerId")

                Log.d("CallConnectionService", "Call Rejected")
                Log.d("Caller ID:", callerId ?: "null")

                // Generate deep link for the home screen
                val deepLink = "exampleapp://open/home?callerId=$callerId"

                val intent = Intent(Intent.ACTION_VIEW).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    data = Uri.parse(deepLink)
                }
                startActivity(intent)
                destroy()
            }
        }
        connection.setAddress(request?.address, TelecomManager.PRESENTATION_ALLOWED)
        connection.setCallerDisplayName("Incoming Call", TelecomManager.PRESENTATION_ALLOWED)
        connection.setInitializing()
        connection.setActive()
        return connection
    }
}

