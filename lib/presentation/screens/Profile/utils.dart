import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Opens the image picker and returns the bytes of the chosen image, or
/// null when nothing was selected.
Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  try {
    final XFile? file = await imagePicker.pickImage(source: source);
    return await file?.readAsBytes();
  } catch (_) {
    return null;
  }
}
