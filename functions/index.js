const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = onDocumentCreated(
  "chatrooms/{chatId}/messages/{messageId}",
  async (event) => {
    const messageData = event.data.data();
    if (!messageData) return;

    const senderId = messageData.senderId;
    const isEncrypted = messageData.isEncrypted === true;
    const chatId = event.params.chatId;

    // 1. Get Sender Info for the notification title
    const senderDoc = await admin
      .firestore()
      .collection("users")
      .doc(senderId)
      .get();
    const senderName = senderDoc.exists ? senderDoc.data().name : "New Message";

    // 2. Get Chatroom to identify the receiver
    const chatDoc = await admin
      .firestore()
      .collection("chatrooms")
      .doc(chatId)
      .get();
    if (!chatDoc.exists) return;

    const participants = chatDoc.data().participants;
    const receiverId = participants.find((id) => id !== senderId);
    if (!receiverId) return;

    // 3. Get Receiver FCM tokens
    const receiverDoc = await admin
      .firestore()
      .collection("users")
      .doc(receiverId)
      .get();
    const tokens = receiverDoc.exists ? receiverDoc.data().fcmTokens || [] : [];
    if (tokens.length === 0) return;

    // 4. Handle Content Preview
    // We check if it's encrypted. If it is, we show a generic "Secure Message"
    // to protect privacy and avoid showing gibberish.
    let notificationBody;
    if (isEncrypted) {
      notificationBody = "🔒 Secure message";
    } else {
      notificationBody = messageData.text || "📷 Attachment received";
    }

    const payload = {
      notification: {
        title: senderName, // Much better UX
        body: notificationBody,
      },
      data: {
        chatId: chatId,
        senderId: senderId,
        click_action: "FLUTTER_NOTIFICATION_CLICK", // Standard for Flutter
      },
    };

    // 5. Send
    await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      ...payload,
    });
  },
);
