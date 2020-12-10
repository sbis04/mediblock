import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileSelector {
  Future<FilePickerResult> chooseFile() async {
    // File file;
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'txt'],
    );

    // if (result != null) {
    //   file = File(result.files.single.path);

    // }

    return result;
  }
}
