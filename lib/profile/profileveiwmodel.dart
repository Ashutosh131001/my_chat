// ignore: file_names
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/chatlist/user_model.dart';
import 'package:my_chat/utils/utils.dart';

class ProfileViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? currentUser;

  var name = ''.obs;
  var about = ''.obs;
  var selectedImage = Rx<File?>(null);

  var isLoading = false.obs;
  var isSaving = false.obs;
  var hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return;

      currentUser = UserModel.fromMap(doc.data()!);

      name.value = currentUser!.name ?? '';
      about.value = currentUser!.about ?? '';
      selectedImage.value = null;

      hasChanges.value = false;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    selectedImage.value = File(picked.path);
    hasChanges.value = true;
  }

  void onNameChanged(String value) {
    name.value = value;
    hasChanges.value = true;
  }

  void onAboutChanged(String value) {
    about.value = value;
    hasChanges.value = true;
  }

  Future<void> saveProfile() async {
    if (!hasChanges.value || currentUser == null) return;

    try {
      isSaving.value = true;

      String? imageUrl = currentUser!.profileImageUrl;

      // Upload new profile image if selected
      if (selectedImage.value != null) {
        final uid = currentUser!.uid;

        final ref = _storage
            .ref()
            .child('profileImages')
            .child(uid)
            .child('profile.jpg');

        await ref.putFile(selectedImage.value!);

        imageUrl = await ref.getDownloadURL();
      }

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'name': name.value.trim(),
        'about': about.value.trim(),
        'profileImageUrl': imageUrl,
      });

      currentUser = currentUser!.copyWith(
        name: name.value.trim(),
        about: about.value.trim(),
        profileImageUrl: imageUrl,
      );

      hasChanges.value = false;

      Utils.showsnackbar(
        message: 'Profile updated Successfully',
        type: SnackbarType.info,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
