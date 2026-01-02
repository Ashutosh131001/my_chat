const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * 🔔 Send notification when a new message is created
 */
exports.sendChatNotification = onDocumentCreated(
  "chatrooms/{chatId}/messages/{messageId}",
  async (event) => {
    const messageData = event.data.data();

    if (!messageData) return;

    const senderId = messageData.senderId;
    const text = messageData.text;
    const chatId = messageData.chatId;

    // Get chatroom
    const chatDoc = await admin
      .firestore()
      .collection("chatrooms")
      .doc(chatId)
      .get();

    if (!chatDoc.exists) return;

    const participants = chatDoc.data().participants;

    // Receiver = the one who is NOT sender
    const receiverId = participants.find((id) => id !== senderId);
    if (!receiverId) return;

    // Get receiver user document
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(receiverId)
      .get();

    if (!userDoc.exists) return;

    const tokens = userDoc.data().fcmTokens || [];
    if (tokens.length === 0) return;

    const payload = {
      notification: {
        title: "New Chat Message",
        body: text || "New message received",
      },
      data: {
        chatId: chatId,
        senderId: senderId,
      },
    };

    await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      ...payload,
    });
  }
);
