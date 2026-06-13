import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/chatlist/user_model.dart';
import 'package:my_chat/chatlist/chat.dart';

class UserVeiwModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  var usermodel = Rxn<UserModel>();
  var isloading = false.obs;
  var profileImage = Rx<File?>(null);

  // Controllers for name and about
  final nameController = TextEditingController();
  final aboutController = TextEditingController();

  // Local tracking variable to manage token updates safely
  String? _lastKnownToken;

  @override
  void onInit() {
    super.onInit();
    // Automatically start listening for background token refreshes
    initNotificationListeners();
  }

  /// 🖼️ Pick image from gallery
  Future<void> pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (picked != null) {
        profileImage.value = File(picked.path);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// 💾 Save user info
  Future<void> saveuserinfo({
    required String name,
    String? about,
    File? profileimage,
  }) async {
    try {
      isloading.value = true;

      final currentuser = _auth.currentUser;
      if (currentuser == null) {
        throw Exception('No authenticated user found');
      }

      // Upload image if available
      String? imageurl;
      final selectedImage = profileimage ?? profileImage.value;
      if (selectedImage != null) {
        imageurl = await _uploadprofileimage(currentuser.uid, selectedImage);
      }

      final userdata = UserModel(
        uid: currentuser.uid,
        phoneNumber: currentuser.phoneNumber ?? '',
        name: name.trim(),
        about: about?.trim().isNotEmpty == true
            ? about!.trim()
            : 'Hey there! I am using MyChat 💬',
        profileImageUrl: imageurl,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isOnline: true,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      );

      // 🔥 FIX 1: Added SetOptions(merge: true) here so fields like fcmTokens aren't wiped out!
      await _firestore
          .collection('users')
          .doc(currentuser.uid)
          .set(userdata.toMap(), SetOptions(merge: true));
          
      await requestNotificationPermission();
      await saveFcmToken();

      usermodel.value = userdata;
      Get.snackbar('Success', 'Profile created successfully 🎉');
      Get.offAll(() => ChatListPage());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isloading.value = false;
    }
  }

  /// 📤 Upload image to Firebase Storage
  Future<String> _uploadprofileimage(String uid, File imagefile) async {
    final ref = _storage
        .ref()
        .child('profileImages')
        .child(uid)
        .child('profile.jpg');

    await ref.putFile(imagefile);
    return await ref.getDownloadURL();
  }

  /// 🔍 Fetch user data
  Future<void> fetchUserData() async {
    try {
      isloading.value = true;
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        usermodel.value = UserModel.fromMap(data);
        
        // Refresh/re-verify the token when fetching user data
        await saveFcmToken();
      } else {
        Get.snackbar('Error', 'No data found for this user');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });

      usermodel.value = usermodel.value?.copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// 🔔 Request notification permission
  Future<void> requestNotificationPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  /// 🔑 Get FCM token
  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }

  /// 💾 Save FCM token to Firestore
  Future<void> saveFcmToken() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    _lastKnownToken = token;

    await _firestore.collection('users').doc(currentUser.uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  /// 🔄 FIX 2: Added token refresh listener to capture token changes automatically
  void initNotificationListeners() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userDoc = _firestore.collection('users').doc(currentUser.uid);

      // Clean up the old, expired token from the array
      if (_lastKnownToken != null && _lastKnownToken != newToken) {
        await userDoc.update({
          'fcmTokens': FieldValue.arrayRemove([_lastKnownToken]),
        });
      }

      // Append the new one
      await userDoc.update({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
      });

      _lastKnownToken = newToken;
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}