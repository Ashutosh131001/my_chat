import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:my_chat/chatlist/user_model.dart'; // Your Full Profile Model (ID: 0)
import 'package:my_chat/contactspage/contactusermodel.dart'; // Your Contact Model (ID: 1)

class OtherUserProfileViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var user = Rxn<UserModel>();
  var isLoading = false.obs;

  /// ⚡ INSTANT LOAD: Convert Contact Data -> Profile Data
  void loadFromLocal(usermodel contactUser) {
    // We create a temporary UserModel using the data we already have.
    // This allows the UI to render INSTANTLY while we fetch fresh data in background.
    user.value = UserModel(
      uid: contactUser.uid,
      phoneNumber: contactUser.phonenumber,
      name: contactUser.name,
      about: contactUser.about,
      profileImageUrl: contactUser.profileImageUrl,
      isOnline: false, // Default until fetch
      createdAt: 0,
    );
  }

  /// 🔄 BACKGROUND REFRESH: Get latest details (Online only)
  Future<void> fetchUser(String uid) async {
    try {
      // Only show loading if we have absolutely NO data
      if (user.value == null) isLoading.value = true;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        user.value = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      // If offline, we just stay silent because we already loaded the local data! 🤫
      print("Background fetch failed: $e");
    } finally {
      isLoading.value = false;
    }
  }
}