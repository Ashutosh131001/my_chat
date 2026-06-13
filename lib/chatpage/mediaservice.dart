import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  // Observable list so the UI can show selected images instantly
  final RxList<File> selectedImages = <File>[].obs;
  final RxBool isPickingImages = false.obs;

  Future<void> pickImagesFromGallery() async {
    if (isPickingImages.value) return;
    isPickingImages.value = true;
    
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        selectedImages.assignAll(pickedFiles.map((x) => File(x.path)).toList());
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isPickingImages.value = false;
    }
  }

  void clearImages() {
    selectedImages.clear();
  }

  Future<List<String>> uploadImages({
    required String chatId,
    required String messageId,
    required List<File> images,
  }) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [];
    
    for (int i = 0; i < images.length; i++) {
      final ref = storage.ref('chat_images/$chatId/$messageId/image_$i.jpg');
      final uploadTask = await ref.putFile(images[i]);
      urls.add(await uploadTask.ref.getDownloadURL());
    }
    
    return urls;
  }
}