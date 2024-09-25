import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:x51/models/organization.dart';

import '../../models/storage_file.dart';
import '../../models/user_model.dart';

final transcriptsNotifierProvider =
    StateNotifierProvider<TranscriptsNotifier, AsyncValue<List<StorageFile>>>(
        (ref) {
  return TranscriptsNotifier();
});

class TranscriptsNotifier extends StateNotifier<AsyncValue<List<StorageFile>>> {
  TranscriptsNotifier() : super(const AsyncValue.loading());

  int _fetchId = 0; // Counter to track latest call

  Future<void> fetchTranscripts(
      Iterable<UserModel> filteredUsers,
      String orgId,
      String orgName,
      String locName,
      String email,
      List<String> users,
      Organization org) async {
    final currentId = ++_fetchId; // New call gets a new ID
    state = const AsyncValue.loading();

    try {
      final files = await getFilesFromStorage(
          filteredUsers, orgId, orgName, locName, email, users, org);

      // Ignore if this call is outdated
      if (_fetchId != currentId) return;

      state = AsyncValue.data(files);
    } catch (e, st) {
      // Still ignore if outdated
      if (_fetchId != currentId) return;
      state = AsyncValue.error(e, st);
    }
  }
}

Future<List<StorageFile>> getFilesFromStorage(
    Iterable<UserModel> filteredUsers,
    String orgId,
    String orgName,
    String locName,
    String email,
    List<String> users,
    Organization org) async {
  List<StorageFile> fileList = [];

  try {
    // Create a reference to the orgName folder
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child("Summary");

    // List all files in the orgName directory
    firebase_storage.ListResult result = await ref.listAll();
    for (var ref in result.items) {
      print('Found file: ${ref.name}');
    }

    for (var ref in result.prefixes) {
      print('Found directory: ${ref.name}');
    }

    // Iterate through the items and get their download URLs
    for (var item in result.items) {
      final fileName = item.name;

      String bucket = firebase_storage.FirebaseStorage.instance.bucket;

      // bool sameUser = filteredUsers.isNotEmpty &&
      //     !filteredUsers.any((user) => fileName.contains(user.email));
      //
      bool sameUser = fileName.contains(email);
      bool containsSupervisor =
          users.isNotEmpty && users.any((user) => fileName.contains(user));
      bool validFile =
          fileName.contains("summary_B") || fileName.contains("summary_C") || fileName.contains("summary_L");

      bool fetchUsers = (sameUser || containsSupervisor) && validFile && org.directEditing;
      bool onlyFetchSupervisor = !org.directEditing && sameUser;

      if (fetchUsers || onlyFetchSupervisor) {
        // Construct the full gs:// path
        String filePath = 'gs://$bucket/${item.fullPath}';
        print('Found file Path: ${filePath}');

        String fileUrl = await item.getDownloadURL();

        // Match the datetime portion using regex
        final match = RegExp(r'\d{4}-\d{2}-\d{2}__\d{2}:\d{2}:\d{2}\.\d+')
            .firstMatch(fileName);

        if (match == null) {
          print("No datetime found in filename: $fileName");
          continue;
        }

        // Replace '__' with 'T' to match ISO format
        String rawDateTime = match.group(0)!.replaceFirst('__', 'T');

        DateTime? parsedDate;
        try {
          parsedDate = DateTime.parse(rawDateTime);
        } catch (e) {
          print("Failed to parse datetime: $rawDateTime in file: $fileName");
          continue;
        }

        fileList.add(StorageFile(
            name: item.name,
            downloadUrl: fileUrl,
            filePath: filePath,
            date: parsedDate));
      }
    }

    fileList.sort((a, b) => b.date.compareTo(a.date));
  } catch (e) {
    print("Error getting files: $e");
  }

  return fileList;
}
