import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';
import 'package:my_chat/chatpage/chatroommodel.dart';


class ChatListItem {
  final ChatRoomModel chatroom;
  final usermodel otheruser;

  ChatListItem({required this.chatroom, required this.otheruser});
}

class Chatlistviewmodel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var chatList = <ChatListItem>[].obs;
  var isLoading = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatSub;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(milliseconds: 300), listenchatlist);
  }

  void listenchatlist() {
    final currentuser = _auth.currentUser;
    if (currentuser == null) return;

    final uid = currentuser.uid;
    isLoading.value = true;

    _chatSub = _firestore
        .collection('chatrooms')
        .where('participants', arrayContains: uid)
        .snapshots()
        .listen((snapshot) async {
          final List<ChatListItem> templist = [];

          for (var doc in snapshot.docs) {
            final chatroom = ChatRoomModel.fromMap(doc.data());

            final otherid = chatroom.participants.firstWhere(
              (id) => id != uid,
              orElse: () => '',
            );
            if (otherid.isEmpty) continue;

            /// Fetch other user profile
            final userdoc = await _firestore
                .collection('users')
                .doc(otherid)
                .get();

            if (!userdoc.exists) continue;

            final otheruser = usermodel.frommap(userdoc.data()!);

            templist.add(
              ChatListItem(chatroom: chatroom, otheruser: otheruser),
            );
          }

          /// 🔥 Local sort (safe even if lastMessageTime is null)
          templist.sort(
            (a, b) => (b.chatroom.lastMessageTime ?? 0).compareTo(
              a.chatroom.lastMessageTime ?? 0,
            ),
          );

          chatList.assignAll(templist);
          isLoading.value = false;
        });
  }

  

  @override
  void onClose() {
    _chatSub?.cancel();
    super.onClose();
  }
}
