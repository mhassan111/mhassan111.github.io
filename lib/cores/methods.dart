import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;

import 'package:get/get_connect/http/src/response/response.dart';

Future<String> putFileInStorage(file, number, fileType) async {
  final ref = FirebaseStorage.instance.ref().child("$fileType/$number");
  final upload = ref.putFile(file);
  final snapshot = await upload;
  String downloadUrl = await snapshot.ref.getDownloadURL();
  return downloadUrl;
}

Future<String> uploadAudioFile(io.File audioFile, String fileName) async {
  var ref = await FirebaseStorage.instance.ref().child('audio/$fileName');
  Uri blobUri = Uri.parse(html.window.sessionStorage[audioFile]!);
  http.Response response = await http.get(blobUri);
  var url = await ref.putData(
      response.bodyBytes, SettableMetadata(contentType: 'audio/*'));
  return url.ref.getDownloadURL();
}

Future<String> getImageUrl(io.File imageFile, String basePath) async {
  final storageRef = FirebaseStorage.instance.ref();

// Get a reference to the image file
  final imageRef = storageRef.child('recorded/file1');

// Upload the image to Firebase Storage with the MIME type
  SettableMetadata metadata = SettableMetadata(contentType: 'audio/*');

  if (kIsWeb) {
// if we use putFile for web it will cause error as discussed above
    await imageRef.putData(await imageFile.readAsBytes(), metadata);
  } else {
    await imageRef.putFile(File(imageFile.path));
  }
  final downloadURL = await imageRef.getDownloadURL();
  return downloadURL;
}

// Get the download URL for the uploaded image

Future<String> uploadFile(io.File file, String path) async {
  String imageUrl = '';
  try {
    firabase_storage.UploadTask uploadTask;
    var now = DateTime.now().millisecond;
    firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
        .ref()
        .child('recordedFiles')
        .child('${DateTime.now()}.webm');

    final metadata = firabase_storage.SettableMetadata(contentType: 'opus/webm');
    Uri blobUri = Uri.parse(html.window.sessionStorage[path]!);
    http.Response response = await http.get(blobUri);
    uploadTask = ref.putData(response.bodyBytes, metadata);

    await uploadTask.whenComplete(() => null);
    imageUrl = await ref.getDownloadURL();
    // }
  } catch (e) {
    print(e);
  }
  return imageUrl;
}

Future<String> getFileSize(String filepath, int decimals) async {
  var file = File(filepath);
  int bytes = await file.length();
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}
