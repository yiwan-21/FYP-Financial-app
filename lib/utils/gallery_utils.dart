import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// @return null if user cancels
// @return File if user is using mobile
// @return Uint8List if user is using web
// return type can be directly put into Firebase Storage if not null
Future<dynamic> pickFromGallery() async {
  final picker = ImagePicker();
  XFile? pickedImage = await picker.pickImage(
    source: ImageSource.gallery,
  );
  if (pickedImage != null) {
    if (kIsWeb) {
      return await pickedImage.readAsBytes();
    } else {
      return File(pickedImage.path);
    }
  }
  return null;
}

// @return null if user cancels
// @return File if user is using mobile
// @return Uint8List if user is using web
// return type can be directly put into Firebase Storage if not null
Future<dynamic> pickFromCamera() async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedImage != null) {
    if (kIsWeb) {
      return await pickedImage.readAsBytes();
    } else {
      return File(pickedImage.path);
    }
  }
  return null;
}
