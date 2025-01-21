const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");
const serviceAccount = require("./callkit-xxxx.json"); // Path to your Firebase service account key

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://callkit-xxxxx.firebaseio.com", // Replace with your Firebase database URL
});

app.get("/", (req, res) => {
    res.send("Hello Coding");
  });
  const dataStore = {};

app.post("/register-device", async (req, res) => {
  const { uniqueId, fcmToken } = req.body;

  try {
    // Save device details to Firebase Realtime Database
    await admin.database().ref(`/users/${uniqueId}`).set({ fcmToken });
    res.status(200).send("Device registered successfully");
  } catch (error) {
    console.error("Error registering device:", error);
    res.status(500).send("Error registering device");
  }
});

app.post("/api/add", (req, res) => {
  const { callerId, roomId, calleeId } = req.body;

  if (!callerId || !roomId || !calleeId) {
    return res
      .status(400)
      .json({ error: "callerId, roomId, and calleeId are required." });
  }

  // Store data with callerId as the key
  dataStore[callerId] = { roomId, calleeId };

  res.status(201).json({ message: "Data added successfully." });
});

// GET: Fetch data by calleeId
app.get("/api/getByCallee/:calleeId", (req, res) => {
  const { calleeId } = req.params;

  // Find the first matching entry for the calleeId
  const entry = Object.entries(dataStore).find(
    ([_, value]) => value.calleeId === calleeId
  );

  if (!entry) {
    return res.status(404).json({ error: "No data found for the provided calleeId." });
  }

  const [callerId, { roomId }] = entry;

  res.status(200).json({ callerId, roomId, calleeId });
});

app.post("/send-call-status", async (req, res) => {
  const { callerId, status, roomId } = req.body;

  try {
    // Validate inputs
    if (!callerId || !status || !roomId) {
      return res.status(400).json({ message: "callerId, status, and roomId are required" });
    }

    // Fetch the FCM token from Firebase Realtime Database
    const snapshot = await admin.database().ref(`/users/${callerId}`).once("value");

    if (!snapshot.exists()) {
      return res.status(404).json({ message: "Caller ID not found in the database" });
    }

    const { fcmToken } = snapshot.val();

   // Notification messages for each status
    const statusMessages = {
      CALL_ACCEPTED: "The call was accepted",
      CALL_REJECTED: "The call was rejected",
      CALL_ENDED: "The call has ended",
    };
const notificationMessage = statusMessages[status] || "Call status updated";
    // 
    // Construct the notification payload
    const message = {
      notification: {
        title: "Call Update",
        body: notificationMessage,
      },
      android: {
        priority: "high",
      },
      token: fcmToken,
      data: {
        callerId: callerId, // Include the callerId in the data payload
        type: status,       // Example: CALL_ACCEPTED, CALL_REJECTED
        roomId: roomId,     // Include the roomId in the data payload
      },
    };

    // Send the notification
    const response = await admin.messaging().send(message);
    console.log(`Successfully sent '${status}' notification:`, response);

    res.status(200).json({
      message: `'${status}' notification sent successfully`,
      response,
    });
  } catch (error) {
    console.error(`Error sending '${status}' notification:`, error);
    res.status(500).json({ message: `Error sending '${status}' notification` });
  }
});




app.post("/send-notification", async (req, res) => {
  const { callerId, callerInfo, videoSDKInfo } = req.body;

  try {
    if (!callerId || !videoSDKInfo?.roomId) {
      return res.status(400).send({ error: "Missing callerId or roomId in the request body" });
    }
    console.log("Successfully  yet to sent test notification:qwdqwdqwdqw"); 
    const snapshot = await admin.database().ref(`/users/${callerId}`).once("value");
    console.log("Successfully  yet to sent test notification:"); 
    if (!snapshot.exists()) {
      return res.status(404).send({ error: "Caller ID not found in the database" });
    }

    const { fcmToken } = snapshot.val();

    const message = {
     
      android: {
        priority: "high"
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
      
        payload: {
          aps: {
            alert: {
              title: req.body.title || "Incoming Call",
              body: req.body.body || "Join the room to continue.",
            },
            sound: "default",
            "content-available": true,
          },
        },
      },
      token: fcmToken,
      data: {
        receiverId: callerId,
        callerInfo: callerInfo?.id || "N/A",
        roomId: videoSDKInfo.roomId,
        token: videoSDKInfo.token,
      },
    };
    console.log("Successfully  yet to sent test notification:"); 
    const response = await admin.messaging().send(message);

    console.log("Successfully sent test notification:", response);

    res.status(200).json({
      message: "Test notification sent successfully",
      details: {
        receiverId: callerId,
        roomId: videoSDKInfo.roomId,
        token: videoSDKInfo.token,
        callerId : callerInfo,
      },
    });
  } catch (error) {
    console.error("Error sending test notification:", error);
    res.status(500).send({ error: "Error sending test notification" });
  }
});


// GET endpoint to fetch call status for a specific callerId

// Start the Server
const PORT = process.env.PORT || 9000;
const LOCAL_IP = 'Your IP';  // Replace with your actual local IP address

app.listen(PORT, LOCAL_IP, () => {
  console.log(`Server running on http://${LOCAL_IP}:${PORT}`);
});
