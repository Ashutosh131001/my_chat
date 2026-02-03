import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart'; // 🟢 Import Hive
import 'package:my_chat/contactspage/contactusermodel.dart';

class ContactsViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🟢 Box for storing matched contacts
  Box<usermodel>? _contactsBox;

  var firebaseUsers = <usermodel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 🟢 1. Load data instantly from Hive
    _loadLocalCache();

    // 🟢 2. Start the heavy matching process in background
    fetchAllFirebaseUsers();
  }

  /// 📦 Load cached contacts (0ms delay)
  void _loadLocalCache() {
    try {
      if (Hive.isBoxOpen('contacts_cache')) {
        _contactsBox = Hive.box<usermodel>('contacts_cache');

        if (_contactsBox != null && _contactsBox!.isNotEmpty) {
          firebaseUsers.assignAll(_contactsBox!.values.toList());
        }
      }
    } catch (e) {
      print("Cache Error: $e");
    }
  }

  Future<void> fetchAllFirebaseUsers() async {
    try {
      // Only show loading if we have NO data (first time user)
      if (firebaseUsers.isEmpty) isLoading.value = true;

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // 1. Check Permissions
      final permissionGranted = await FlutterContacts.requestPermission(
        readonly: true,
      );
      if (!permissionGranted) {
        isLoading.value = false;
        return;
      }

      // 2. Get Phone Contacts
      final phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      final Set<String> phoneNumbers = {};
      for (var contact in phoneContacts) {
        if (contact.phones.isEmpty) continue;
        final normalized = _normalizePhone(contact.phones.first.number);
        if (normalized.isNotEmpty) {
          phoneNumbers.add(normalized);
        }
      }

      // 3. Fetch App Users
      // ⚠️ Note: Downloading all users is okay for now, but as you grow
      // you might want to use Cloud Functions for this.
      final snapshot = await _firestore.collection('users').get();

      // 4. Match Contacts
      final List<usermodel> matched = snapshot.docs
          .map((doc) => usermodel.frommap(doc.data()))
          .where((user) {
            if (user.uid == currentUser.uid) return false;
            final firebasePhone = _normalizePhone(user.phonenumber);
            return phoneNumbers.contains(firebasePhone);
          })
          .toList();

      // 5. Update UI & Save to Cache
      firebaseUsers.assignAll(matched);

      if (_contactsBox != null && _contactsBox!.isOpen) {
        await _contactsBox!.clear();
        await _contactsBox!.addAll(matched);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _normalizePhone(String phone) {
    String p = phone.replaceAll(RegExp(r'[^\d+]'), '');

    while (p.startsWith('0')) {
      p = p.substring(1);
    }

    if (!p.startsWith('+')) {
      if (p.length == 10) {
        p = '+91$p';
      } else if (p.startsWith('91')) {
        p = '+$p';
      }
    }
    return p.trim();
  }
}
