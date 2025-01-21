import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
//


//import UIKit
//import Firebase
//import Flutter
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//    var initialDeepLink: String? // Store deep link for app cold start
//
//    override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        // Initialize Firebase
//        FirebaseApp.configure()
//
//        // Handle deep link if app launched with a URL
//        if let url = launchOptions?[.url] as? URL {
//            initialDeepLink = url.absoluteString
//        }
//
//        // Handle notification if app launched from push notification
//        if let userInfo = launchOptions?[.remoteNotification] as? [String: AnyObject] {
//            if let callerId = userInfo["callerId"] as? String,
//               let roomId = userInfo["roomId"] as? String {
//                initialDeepLink = "com.example.myapp://caller?callerId=\(callerId)&roomId=\(roomId)"
//            }
//        }
//        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
//        print("Device IDFV (identifierForVendor): \(deviceID)")
//        // Initialize Flutter
//        GeneratedPluginRegistrant.register(with: self)
//
//        // Pass initial deep link to Flutter
//        if let deepLink = initialDeepLink {
//            NotificationCenter.default.post(name: NSNotification.Name("DeepLinkReceived"), object: deepLink)
//        }
//
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//
//    // Handle deep link when app is launched via URL scheme
//    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        initialDeepLink = url.absoluteString
//
//        // Notify Flutter about the deep link
//        NotificationCenter.default.post(name: NSNotification.Name("DeepLinkReceived"), object: initialDeepLink)
//        return true
//    }
//
//    // Handle remote notification when app is launched
//    override   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        if let callerId = userInfo["callerId"] as? String,
//           let roomId = userInfo["roomId"] as? String {
//            initialDeepLink = "com.example.myapp://caller?callerId=\(callerId)&roomId=\(roomId)"
//
//            // Notify Flutter about the deep link
//            NotificationCenter.default.post(name: NSNotification.Name("DeepLinkReceived"), object: initialDeepLink)
//        }
//    }
//}

//import UIKit
//import Firebase
//import Flutter
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//    var initialDeepLink: String? // Store deep link for app cold start
//
//    override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        // Initialize Firebase
//        FirebaseApp.configure()
//        print("Firebase configured")
//
//        // Check if the app is launched via a push notification or URL scheme
//        if let userInfo = launchOptions?[.remoteNotification] as? [String: AnyObject] {
//            print("App launched via push notification")
//            handleNotification(userInfo: userInfo)
//        }
//
//        // Initialize Flutter
//        GeneratedPluginRegistrant.register(with: self)
//        print("Flutter plugin registered")
//
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//
//    // Handle push notifications when app is launched or resumed
//    override func application(
//        _ application: UIApplication,
//        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
//    ) {
//        print("Received remote notification")
//        handleNotification(userInfo: userInfo)
//        completionHandler(.newData)
//    }
//
//    private func handleNotification(userInfo: [AnyHashable: Any]) {
//        print("Handling notification with userInfo: \(userInfo)")
//        
//        // Extract values from the notification payload
//        if let receiverId = userInfo["receiverId"] as? String,
//           let roomId = userInfo["roomId"] as? String,
//           let token = userInfo["token"] as? String,
//           let callerId = userInfo["callerInfo"] {
//            
//            print("ReceiverId: \(receiverId), RoomId: \(roomId), Token: \(token), CallerID: \(callerId) found")
//            
//            // Construct the deep link URL
//            let deepLink = "com.example.myapp://caller?callerId=\(callerId)&roomId=\(roomId)&token=\(token)"
//            print("Deep link constructed: \(deepLink)")
//            
//            // Validate and open the URL
//            if let url = URL(string: deepLink) {
//                DispatchQueue.main.async {
//                    UIApplication.shared.open(url, options: [:]) { success in
//                        if success {
//                            print("Deep link opened successfully.")
//                        } else {
//                            print("Failed to open deep link.")
//                        }
//                    }
//                }
//            } else {
//                print("Invalid deep link URL.")
//            }
//        } else {
//            print("Missing receiverId, roomId, or token in the notification")
//        }
//    }
//    // Handle deep link when app is opened via URL scheme
//    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        print("App opened via deep link with URL: \(url.absoluteString)")
//        initialDeepLink = url.absoluteString
//        NotificationCenter.default.post(name: NSNotification.Name("DeepLinkReceived"), object: initialDeepLink)
//        return true
//    }
//}
