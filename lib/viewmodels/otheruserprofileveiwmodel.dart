import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:my_chat/models/user_model.dart';


class OtherUserProfileViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var user = Rxn<UserModel>();
  var isLoading = false.obs;

  Future<void> fetchUser(String uid) async {
    try {
      isLoading.value = true;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        Get.snackbar("Error", "User not found");
        return;
      }

      user.value = UserModel.fromMap(doc.data()!);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}