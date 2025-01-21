# Flutter Call Trigger with VideoSDK

## Step 1: Firebase Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project if you don't have one already. Once your project is created, navigate to the "Add app" section.
3. Choose the Flutter option to proceed.
4. Use npm to globally install the Firebase CLI. Run the following command in your terminal:

   ```bash
   npm install -g firebase-tools
   ```

5. Log in to your Firebase account using the Firebase CLI by running:

   ```bash
   firebase login
   ```

![Firebase CLI Setup](./assets/image-9.png)

## Step 2: iOS Side Setup

### CallKit and PushKit Setup

- CallKit enables you to display the system-calling UI for your app's VoIP services and manage communication between your app, the system, and other apps. [See more details](https://developer.apple.com/documentation/callkit).
- PushKit sends notifications, including VoIP invitations. It is essential for VoIP apps. Visit [PushKit](https://developer.apple.com/documentation/pushkit) for additional details.

### Configure PushKit

You must upload an APNs Auth Key in order to implement push notifications. We need the following details about your app when sending push notifications via an APNs Auth Key:

- Auth Key file
- Team ID
- Key ID
- Your app’s bundle ID

To create an APNs auth key, follow the steps below.

Visit the Apple [Developer Member Center](https://developer.apple.com/account/)

![plot](./assets/image-4.png)

Click on `Certificates, Identifiers & Profiles`. Go to Keys from the left side. Create a new Auth Key by clicking on the plus button in the top right side.

![plot](./assets/image-5.png)

On the following page, add a Key Name, and select APNs.

![plot](./assets/image-6.png)

Click on the Register button.

![plot](./assets/image-7.png)

You can download your auth key file from this page and upload this file to Firebase dashboard without changing its name.

![plot](./assets/image-8.png)

In your firebase project, go to `Settings` and select the `Cloud Messaging` tab. Scroll down to `iOS app configuration`and click upload under `APNs Authentication Key`

![plot](./assets/FIR_1.png)

Enter Key ID and Team ID. Key ID is in the file name, `AuthKey_{Key ID}.p8` and is 10 characters. Your Team ID is in the Apple Member Center under the [membership tab](https://developer.apple.com/account/#/membership) or displayed always under your account name in the top right corner.

![plot](./assets/FIR_2.png)

### Note:

Enable Push Notifications in Capabilities

![plot](./assets/xcd-2.png)

![plot](./assets/xcd-3.png)

Enable selcted permission in Background Modes

![plot](./assets/xcd-1.png)
## Step 3: Android Side Setup

### Modify `AndroidManifest.xml`

1. Add the required permissions:

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
   ```

2. Inside the `<application>` tag, add the Firebase Messaging service:

   ```xml
   <service
       android:name="com.google.firebase.messaging.FirebaseMessagingService"
       android:exported="true">
       <intent-filter>
           <action android:name="com.google.firebase.MESSAGING_EVENT" />
       </intent-filter>
   </service>
   ```

## Step 4: Server Setup

### Steps to Set Up Server

1. **Create a new project directory:**
   ```bash
   mkdir server
   cd server
   npm init -y
   ```

2. **Install required dependencies:**
   ```bash
   npm install express cors morgan firebase-admin uuid
   ```
3.  **Setup Firebase Admin SDK for managing FCM**

Download private Key from firebase and add the `.json` file in the server folder.
![plot](https://cdn.videosdk.live/docs/images/android/call_keep/firebase_server_sdk.jpeg)

4.  **Configure Firebase Admin in Server Code**

```js
// Path to your service account key file for Firebase Admin SDK
var serviceAccount = require("add_path_here");
```
