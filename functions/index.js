const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    console.log("--- Funksiya işə düşdü ---");

    const messageData = snapshot.data();
    if (!messageData) {
      console.log("Mesaj datası boşdur.");
      return null;
    }

    const receiverId = messageData.receiverId;
    const senderId = messageData.senderId;
    const text = messageData.text || "";

    console.log(`Sender: ${senderId}, Receiver: ${receiverId}`);

    try {
      // 1. Göndərəni tapırıq
      const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
      const senderName = senderDoc.exists ? (senderDoc.data().name || "Yeni Mesaj") : "Yeni Mesaj";
      console.log("Göndərən adı:", senderName);

      // 2. Qəbul edəni tapırıq
      const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
      if (!receiverDoc.exists) {
        console.log("Qəbul edən istifadəçi tapılmadı!");
        return null;
      }

      const userData = receiverDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log("Qarşı tərəfin FCM Tokeni yoxdur (Firestore-da fcmToken sahəsi boşdur).");
        return null;
      }

      console.log("Token tapıldı:", fcmToken);

      // 3. Mesaj mətnini hazırlayırıq
      const messageBody = text.startsWith("data:image") ? "📷 Şəkil göndərdi" : text;

      // 4. Mesajı hazırlayırıq (HEADS-UP ÜÇÜN DÜZGÜN STRUKTUR)
      const message = {
        token: fcmToken,
        notification: {
          title: senderName,
          body: messageBody,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          chatId: context.params.chatId,
          senderId: senderId,
          type: "chat_message",
        },
        // Android üçün xüsusi parametrlər (EKRANDA GÖRÜNMƏK ÜÇÜN VACİB)
        android: {
          priority: "high", // HIGH priority - VACİBDİR!
          notification: {
            channelId: "chat_messages_channel", // Flutter-da yaratdığımız kanal
            priority: "max", // MAX priority - HEADS-UP ÜÇÜN VACİBDİR!
            defaultSound: true,
            defaultVibrateTimings: true,
            defaultLightSettings: true,
            notificationPriority: "PRIORITY_MAX", // Android notification priority
            visibility: "public", // Lock screen-də və s. görünsün
            tag: "chat_message", // Eyni tag-li bildirişlər birləşər
            color: "#2563EB", // Notification icon rəngi
          },
        },
        // iOS üçün xüsusi parametrlər
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
              alert: {
                title: senderName,
                body: messageBody,
              },
              "mutable-content": 1,
              "content-available": 1,
            },
          },
          headers: {
            "apns-priority": "10", // Yüksək prioritet
            "apns-push-type": "alert",
          },
        },
      };

      // 5. Göndəririk
      const messageId = await admin.messaging().send(message);

      console.log("✅ Mesaj uğurla göndərildi! Message ID:", messageId);
      console.log("📱 Bildiriş ekranda görünməlidir");

      return null;

    } catch (error) {
      console.error("❌ Gözlənilməz xəta baş verdi:", error);

      // Xüsusi xəta növlərini yoxlayaq
      if (error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered") {
        console.log("⚠️ Token keçərsizdir, Firestore-dan silinməlidir");
        // Köhnə tokeni silin
        await admin.firestore().collection("users").doc(receiverId).update({
          fcmToken: admin.firestore.FieldValue.delete()
        });
      }

      return null;
    }
  });

// ============================================
// ƏLAVƏ: Qrup mesajları üçün (opsional)
// ============================================

exports.sendGroupChatNotification = functions.firestore
  .document("groups/{groupId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    console.log("--- Qrup mesajı funksiyası ---");

    const messageData = snapshot.data();
    const senderId = messageData.senderId;
    const text = messageData.text || "";
    const groupId = context.params.groupId;

    try {
      // Qrup məlumatlarını tap
      const groupDoc = await admin.firestore().collection("groups").doc(groupId).get();
      if (!groupDoc.exists) return null;

      const groupData = groupDoc.data();
      const members = groupData.members || [];
      const groupName = groupData.name || "Qrup";

      // Göndərən istisna olmaqla bütün üzvlərin tokenləri
      const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
      const senderName = senderDoc.exists ? senderDoc.data().name : "Birisindən";

      const tokens = [];
      for (const memberId of members) {
        if (memberId === senderId) continue; // Özünə göndərməsin

        const memberDoc = await admin.firestore().collection("users").doc(memberId).get();
        if (memberDoc.exists && memberDoc.data().fcmToken) {
          tokens.push(memberDoc.data().fcmToken);
        }
      }

      if (tokens.length === 0) {
        console.log("Heç bir token tapılmadı");
        return null;
      }

      // Qrup mesajını göndər
      const message = {
        notification: {
          title: groupName,
          body: `${senderName}: ${text}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          groupId: groupId,
          type: "group_message",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "chat_messages_channel",
            priority: "max",
            defaultSound: true,
            defaultVibrateTimings: true,
            notificationPriority: "PRIORITY_MAX",
            visibility: "public",
            tag: `group_${groupId}`,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
          headers: {
            "apns-priority": "10",
          },
        },
        tokens: tokens, // Multicast mesaj
      };

      const response = await admin.messaging().sendMulticast(message);
      console.log(`✅ ${response.successCount} mesaj göndərildi`);
      console.log(`❌ ${response.failureCount} xəta`);

      return null;
    } catch (error) {
      console.error("❌ Qrup mesajı xətası:", error);
      return null;
    }
  });