import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:my_chat/contactspage/contactusermodel.dart';


class ContactsViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var firebaseUsers = <usermodel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchAllFirebaseUsers() async {
    try {
      isLoading.value = true;
      firebaseUsers.clear();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No logged-in user found');
        return;
      }

      final permissionGranted = await FlutterContacts.requestPermission(
        readonly: true,
      );

      if (!permissionGranted) {
        Get.snackbar('Permission', 'Contacts permission required');
        return;
      }

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

      final snapshot = await _firestore.collection('users').get();

      final List<usermodel> matched = snapshot.docs
          .map((doc) => usermodel.frommap(doc.data()))
          .where((user) {
            if (user.uid == currentUser.uid) return false;

            final firebasePhone = _normalizePhone(user.phonenumber);

            return phoneNumbers.contains(firebasePhone);
          })
          .toList();

      firebaseUsers.assignAll(matched);
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
