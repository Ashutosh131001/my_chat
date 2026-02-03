import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 🟢 1. Import Hive
import 'package:my_chat/chatlist/user_model.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';
import 'package:my_chat/chatpage/messagemodel.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/controllers/presensecontroller.dart';

import 'firebase_options.dart';
import 'package:my_chat/chatlist/chat.dart';
import 'package:my_chat/auth/login_veiw.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🟢 2. Initialize the Local Database (Brain)
  await Hive.initFlutter();

  // 🟢 3. Open a "Box" (Database File)
  // We open this now so we don't have to wait for it later in the UI.
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(usermodelAdapter());
  Hive.registerAdapter(ChatRoomModelAdapter());  // ID: 2 (New)
  Hive.registerAdapter(ChatListItemAdapter());   // ID: 3 (New)
  Hive.registerAdapter(MessageTypeAdapter());    // ID: 4 (Enum)
  Hive.registerAdapter(MessageModelAdapter());   // ID: 5 (Model)
  await Hive.openBox('storage');
  await Hive.openBox<usermodel>('contacts_cache');
  await Hive.openBox<ChatListItem>('chat_list_cache');

  // NOTE: In the next step (Model), we will come back here
  // to add "Hive.registerAdapter(UserModelAdapter());"

  Get.put(PresenceController());

  // 🔥 Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My_Chat',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData.light(), // We will optimize this for Dark Mode later too!
      home: const AuthWrapper(),
    );
  }
}

// ... Keep the rest of your AuthWrapper code exactly the same ...

/// 🔥 Automatically decides login state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    /// 🔥 When user taps notification (app background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationNavigation(message);
    });

    /// 🔥 When app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationNavigation(message);
      }
    });
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final chatId = message.data['chatId'];

    if (chatId != null) {
      /// 🔥 Navigate to chat
      Get.to(() => ChatListPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return ChatListPage();
        }

        return PhoneLoginView();
      },
    );
  }
}
