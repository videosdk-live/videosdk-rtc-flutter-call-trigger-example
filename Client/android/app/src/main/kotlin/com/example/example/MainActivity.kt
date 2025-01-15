package com.example.example

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception
import com.google.firebase.FirebaseApp

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.example/calls"
    private var telecomManager: TelecomManager? = null
    private var phoneAccountHandle: PhoneAccountHandle? = null
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FirebaseApp.initializeApp(this)
        Log.d("MainActivity", "Firebase Initialized")
        telecomManager = getSystemService(TELECOM_SERVICE) as TelecomManager
        val componentName = ComponentName(this, CallConnectionService::class.java)
        phoneAccountHandle = PhoneAccountHandle(componentName, "DhirajAccountId")
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
         Log.d("MainActivity", "Above the call connection Service!!!")
        CallConnectionService.setFlutterEngine(flutterEngine)
        MyFirebaseMessagingService.setFlutterEngine(flutterEngine)
        Log.d("MainActivity", "Below the call connection Service!!!")
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "registerPhoneAccount" -> {
                    try {
                        registerPhoneAccount()
                        result.success("Phone account registered successfully")
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to register phone account", e.message)
                    }
                }
                "handleIncomingCall" -> {
                    val callerId = call.argument<String>("callerId")
                    handleIncomingCall(callerId)
                    result.success("Incoming call handled successfully")
                }
                "openPhoneAccountSettings" -> 
                {
                    openPhoneAccountSettings()
                    result.success("Incoming call phone account");
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d("MainActivity", "Initializing Firebase")
       
        super.onCreate(savedInstanceState)
    }
    
    override fun onPause() {
        super.onPause()
        Log.d("MainActivity", "App is paused. Performing necessary tasks.")
        // Perform any cleanup or save operations
    }

    override fun onResume() {
        super.onResume()
        Log.d("MainActivity", "App is resumed. Restoring state or resources.")
        // Restore any states or resources
    }

    override fun onStop() {
        super.onStop()
        Log.d("MainActivity", "App is stopped. Releasing resources.")
        
        // Check for incoming call and handle it
        val callerId = intent.getStringExtra("callerId") // Correct key
        Log.d("MainActivity", "Incoming call from: $callerId")
        if (callerId != null) {
            handleIncomingCall(callerId)
        }
    }

    override fun onStart() {
        super.onStart()
        Log.d("MainActivity", "App is started. Preparing resources.")
        // Initialize or prepare resources
    }

    // Register the phone account with the telecom manager
    private fun registerPhoneAccount() {
        val phoneAccount = PhoneAccount.builder(phoneAccountHandle, "VideoSdk")
            .setCapabilities(PhoneAccount.CAPABILITY_CALL_PROVIDER)
            .build()
        telecomManager?.registerPhoneAccount(phoneAccount)
    }

    // Check if the phone account is registered
    private fun isPhoneAccountRegistered(): Boolean {
        val phoneAccounts = telecomManager?.callCapablePhoneAccounts ?: return false
        return phoneAccounts.contains(phoneAccountHandle)
    }

    // Handle the incoming call or open settings if the account is not registered
    private fun handleIncomingCall(callerId: String?) {
        if (!isPhoneAccountRegistered()) {
            // Open phone account settings if not registered
            openPhoneAccountSettings()
            return
        }
        val extras = Bundle().apply {
            val uri = Uri.fromParts("tel", callerId, null)
            putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, uri)
        }
        try {
            telecomManager?.addNewIncomingCall(phoneAccountHandle, extras)
        } catch (cause: Throwable) {
            Log.e("handleIncomingCall", "Error in addNewIncomingCall", cause)
        }
    }

    // Simulate an incoming call (e.g., during app stop)
    private fun simulateIncomingCall() {
        Log.d("MainActivity", "Simulating an incoming call in onStop.")

        // Simulate a caller ID for testing
        val testCallerId = "1234567890"
        handleIncomingCall(testCallerId)
    }

    // Open phone account settings
    private fun openPhoneAccountSettings() {
        try {
            val intent = Intent(TelecomManager.ACTION_CHANGE_PHONE_ACCOUNTS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("openPhoneAccountSettings", "Unable to open settings", e)
        }
    }
}
