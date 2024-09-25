import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:x51/constants/firebase_constants.dart';
import 'package:x51/helpers/shared_preferences_helper.dart';
import 'package:x51/models/organization.dart';

import '../constants/constants.dart';
import '../models/storage_file.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<String> registerNewUser(String userName, String email, String password,
      Organization organization) async {
    var result = '';
    try {
      UserModel? existingUser = await findUserByField("username", userName);
      if (existingUser != null) {
        return "UserName already Exits";
      }

      var createUserResult = await createUserWithEmailPassword(
          userName, email, password,
          secondaryInstance: true);

      result = createUserResult.first as String;

      UserModel? userModel = createUserResult.last as UserModel?;
      if (userModel != null) {
        userModel.orgId = organization.id;
        userModel.orgName = organization.name;
        // await saveUserModel(userModel);
        var userResult = await setUser(userModel);
        if (userResult.isNotEmpty) {
          result = Constants.registerOk;
        }
        result = Constants.registerOk;
      }
    } catch (e) {
      Utils.printMessage('registerUser error = ${e.toString()}');
      return e.toString();
    }
    return result;
  }

  Future<void> _createUserWithoutLogout(String userName, String email,
      String password, Organization organization) async {
    try {
      // Get a secondary FirebaseAuth instance
      final FirebaseAuth secondaryAuth =
          FirebaseAuth.instanceFor(app: Firebase.app());

      // Create a new user with the secondary instance
      UserCredential userCredential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Access the new user details
      User? newUser = userCredential.user;
      if (newUser != null) {
        print("New user created: ${newUser.email}");
      }
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");
    } catch (e) {
      print("Unexpected error: $e");
    }
  }

  Future<String> registerUser(
      String userName, String email, String password) async {
    var result = '';
    try {
      UserModel? existingUser = await findUserByField("username", userName);
      if (existingUser != null) {
        return "UserName already Exits";
      }

      var createUserResult =
          await createUserWithEmailPassword(userName, email, password);
      result = createUserResult.first as String;

      UserModel? userModel = createUserResult.last as UserModel?;
      if (userModel != null) {
        await saveUserModel(userModel);
        var userResult = await setUser(userModel);
        if (userResult.isNotEmpty) {
          result = Constants.registerOk;
        }
      }
    } catch (e) {
      Utils.printMessage('registerUser error = ${e.toString()}');
      return e.toString();
    }
    return result;
  }

  Future<UserModel?> findUserByField(String field, String value) async {
    try {
      UserModel? userModel;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .where(field, isEqualTo: value)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var document in querySnapshot.docs) {
          Utils.printMessage("Document ID: ${document.id}");
          Utils.printMessage("Document Data: ${document.data()}");
          userModel =
              UserModel.fromMap(document.data() as Map<String, dynamic>);
        }
        return userModel;
      } else {
        Utils.printMessage(
            "No documents found with the specified field value.");
      }
    } catch (e) {
      Utils.printMessage("Error fetching documents: $e");
    }
    return null;
  }

  Future<List<dynamic>> createUserWithEmailPassword(
      String userName, String email, String password,
      {bool secondaryInstance = false}) async {
    String result = '';
    UserModel? userModel;
    try {
      UserCredential userCredential;
      if (secondaryInstance) {
        final FirebaseAuth secondaryAuth =
            FirebaseAuth.instanceFor(app: Firebase.app());
        userCredential = await secondaryAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
      }

      User? user = userCredential.user;
      if (user != null) {
        userModel = UserModel(
            uuid: user.uid,
            username: userName,
            email: email,
            password: password,
            role: UserRole.orgUser.name,
            orgId: '',
            orgName: '',
            locId: '',
            locName: '');
      }
      result = Constants.registerOk;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        result = 'The password provided is too weak.';
        Utils.printMessage('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        result = 'The account already exists for that email.';
        Utils.printMessage('The account already exists for that email.');
      }
    } catch (e) {
      result = e.toString();
      Utils.printMessage('Something went wrong ${e.toString()}');
    }
    return [result, userModel];
  }

  Future<String> setUser(UserModel userModel) async {
    var result = '';
    try {
      if (userModel.email == Constants.superAdminEmail) {
        userModel.role = UserRole.superAdmin.name;
      }

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userModel.uuid)
          .set(userModel.toMap())
          .then((value) {
        Utils.printMessage('setUser success');
        result = 'Success';
      }).onError((e, stacktrace) {
        result = '';
      });
    } on Exception catch (e) {
      Utils.printMessage('setUser ${e.toString()}');
      result = '';
    }
    return result;
  }

  Future<String> updateUserListByEmail(
      String email, List<String> usersList) async {
    String result = '';
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(docId)
            .update({'users': usersList});

        Utils.printMessage('Users list updated for $email');
        result = 'Success';
      } else {
        Utils.printMessage('No user found with email: $email');
        result = 'User not found';
      }
    } catch (e) {
      Utils.printMessage('updateUserListByEmail Error: ${e.toString()}');
      result = 'Error';
    }

    return result;
  }

  Future<String> signInWithEmailPassword(String email, String password) async {
    var result = "";
    User? user;
    try {
      bool isAdminEmail = email == Constants.superAdminEmail;
      UserModel? existingUser = await findUserByField("email", email);
      if (!isAdminEmail && existingUser == null) {
        result = 'No user found for that email in database.';
      }

      if (isAdminEmail) {
        UserModel userModel = UserModel.emptyUser();
        userModel.email = Constants.superAdminEmail;
        userModel.role = UserRole.superAdmin.name;
        existingUser = userModel;
      }

      if (existingUser != null || isAdminEmail) {
        if (existingUser != null) {
          await saveUserModel(existingUser);
          Constants.userModel = existingUser;
        }

        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        user = userCredential.user;

        if (user != null) {
          await saveBoolPref(Constants.prefUserAuthenticated, true);
          result = Constants.loginOk;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        result = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        result = 'Wrong password provided for that user.';
      }
    } on Exception catch (e) {
      result = 'Error: ${e.toString()}';
    }
    return result;
  }

  Future<List<dynamic>> uploadFile(
      String firstName, String lastName, String path) async {
    UserModel userModel = await getUserModel();
    String imageUrl = '';
    String filePath = '';
    Uint8List fileBytes = Uint8List(0);

    // String firstName = await getStringPref(Constants.prefFirstName);
    // String lastName = await getStringPref(Constants.prefLastName);

    String fileName =
        '${firstName}_${lastName}_${DateTime.now().toString().replaceAll(" ", "__")}_${userModel.email}_${userModel.orgName}_${userModel.locName}.mp3';

    try {
      firabase_storage.UploadTask uploadTask;
      // firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
      //     .ref()
      //     .child('${DateTime.now()}.mp3');
      firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
          .ref()
          .child(userModel.orgName)
          .child(userModel.locName)
          .child(fileName);

      final metadata =
          firabase_storage.SettableMetadata(contentType: 'audio/mp3');
      Uri blobUri = Uri.parse(html.window.sessionStorage[path]!);
      http.Response response = await http.get(blobUri);
      fileBytes = response.bodyBytes;
      uploadTask = ref.putData(fileBytes, metadata);

      await uploadTask.whenComplete(() => null);
      imageUrl = await ref.getDownloadURL();
      String fullPath = ref.fullPath;
      Utils.printMessage("bucket image url = $imageUrl");
      Utils.printMessage("bucket full path = $fullPath");
      filePath =
          "gs://${firabase_storage.FirebaseStorage.instance.bucket}/$fullPath";
      Utils.printMessage("bucket full path = $filePath");
    } catch (e) {
      print(e);
    }
    return [imageUrl, fileBytes, filePath];
  }

  Future<void> uploadAndTrackFile(String filePath) async {
    await saveFilePath(filePath);
    await uploadPendingFiles();
  }

  Future<void> processSpeech(String filePath) async {
    final url = Uri.parse(
        "https://us-central1-x51-425623.cloudfunctions.net/process-speech");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"file_path": filePath}),
    );

    if (response.statusCode == 200) {
      Utils.printMessage("Upload Success: ${response.body}");
      await removeFilePath(filePath); // Remove from pending list
    } else {
      Utils.printMessage(
          "Upload Failed: ${response.statusCode}, ${response.body}");
    }
  }

  Future<void> uploadPendingFiles() async {
    List<String> pendingFiles = await getPendingFilePaths();
    if (pendingFiles.isEmpty) {
      Utils.printMessage("No pending files to upload.");
      return;
    }

    Utils.printMessage(
        "Starting upload of ${pendingFiles.length} pending files...");

    for (String filePath in List.from(pendingFiles)) {
      await processSpeech(filePath);
    }

    Utils.printMessage("All pending files uploaded.");
  }

  Future<List<StorageFile>> getFilesFromStorage(
      String orgName, String locName) async {
    List<StorageFile> fileList = [];

    try {
      // Create a reference to the orgName folder
      firabase_storage.Reference ref =
          firabase_storage.FirebaseStorage.instance.ref().child("TestingDocs");

      // List all files in the orgName directory
      firabase_storage.ListResult result = await ref.listAll();

      for (var ref in result.items) {
        print('Found file: ${ref.name}');
      }

      for (var ref in result.prefixes) {
        print('Found directory: ${ref.name}');
      }

      // Iterate through the items and get their download URLs
      for (var item in result.items) {
        String fileUrl = await item.getDownloadURL();
        // fileList.add(StorageFile(name: item.name, downloadUrl: fileUrl));
      }
    } catch (e) {
      print("Error getting files: $e");
    }

    return fileList;
  }

  Future<List<Uint8List>> downloadFiles(List<StorageFile> fileUrls) async {
    List<Uint8List> fileDataList = [];

    try {
      for (StorageFile storageFile in fileUrls) {
        // Fetch the file from the URL
        final response = await http.get(Uri.parse(storageFile.downloadUrl));

        if (response.statusCode == 200) {
          // If the request is successful, add the file data to the list
          fileDataList.add(response.bodyBytes);
        } else {
          print("Failed to load file: ${storageFile.downloadUrl}");
        }
      }
    } catch (e) {
      print("Error downloading files: $e");
    }

    return fileDataList;
  }

  Future<String> fetchTranscript(String filePath) async {
    final url =
        Uri.parse('https://edit-summary-625779460700.us-central1.run.app');
    print('fetchTranscript: path for =  $filePath');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'get',
          'file_path':
              filePath.replaceAll(RegExp(r'summary_[B-C-L]'), 'summary_A'),
          // Include the full file path
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String content = data['content'];
        String version = data['version'];
        print('fetchTranscript: Fetched version $version for $filePath');
        return content;
      } else if (response.statusCode == 404) {
        print('fetchTranscript: Summary file not found: ${response.body}');
      } else {
        print(
            'fetchTranscript: Failed to fetch $filePath. Status code: ${response.statusCode}');
        print('fetchTranscript: Response: ${response.body}');
      }
      return "";
    } catch (e) {
      print('fetchTranscript: Error fetching $filePath: $e');
      return "";
    }
  }

  // Future<String> updateTranscriptContent(
  //   String filePath,
  //   String content, // Updated content that you want to save
  // ) async {
  //   final url =
  //       Uri.parse('https://edit-summary-625779460700.us-central1.run.app');
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'file_path':
  //             filePath.replaceAll(RegExp(r'summary_[B-C-L]'), 'summary_A'),
  //         // Include the full file path
  //         'action': 'save',
  //         // Action to save the content
  //         'content': content,
  //         // Updated content
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //       // Assuming the response contains some result
  //       String status = data['status'] ?? 'success';
  //       print('Updated content for $filePath: $status');
  //       return status;
  //     } else {
  //       print(
  //           'Failed to update content for $filePath. Status code: ${response.statusCode}');
  //       print('Response: ${response.body}');
  //       return 'Failed';
  //     }
  //   } catch (e) {
  //     print('Error updating content for $filePath: $e');
  //     return 'Error';
  //   }
  // }

  Future<String> updateTranscriptContent(
    String filePath,
    String content,
    String versionName, // NEW: version letter like 'B' or 'L'
  ) async {
    final url =
        Uri.parse('https://edit-summary-625779460700.us-central1.run.app');

    print('updateTranscriptContent: saving content = $content');
    print('updateTranscriptContent: version name  = $versionName');

    // Ensure versionName is valid (single letter)
    if (!RegExp(r'^[A-Z]$').hasMatch(versionName)) {
      print('Invalid versionName: Must be a single uppercase letter');
      return 'Invalid versionName';
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'save',
          'file_path': filePath,
          // Use the target file path e.g., summary_B.docx
          'content': content,
          'versionName': versionName,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(
            'Saved content as version ${data['version']}: ${data['docx_path']}');
        return 'success';
      } else {
        print('Failed to save content. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Failed';
      }
    } catch (e) {
      print('Error saving content: $e');
      return 'Error';
    }
  }

  Future<String> signOut() async {
    await auth.signOut();
    await saveBoolPref(Constants.prefUserAuthenticated, false);
    await clearSharedPreferences();
    return Constants.logoutOk;
  }

  Future<String> setOrganization(Organization organization) async {
    var result = '';
    try {
      await _firestore
          .collection(FirebaseConstants.organizations)
          .doc(organization.id)
          .set(organization.toFirestore())
          .then((value) {
        Utils.printMessage('setOrganization success');
        result = 'Success';
      }).onError((e, stacktrace) {
        result = '';
      });
    } on Exception catch (e) {
      Utils.printMessage('setOrganization ${e.toString()}');
      result = '';
    }
    return result;
  }

  Future<Organization?> fetchAnyOrganization(orgId) async {
    final currentUserMap = await _firestore
        .collection(FirebaseConstants.organizations)
        .doc(orgId)
        .get();
    if (currentUserMap.data() != null) {
      Organization organization = Organization.fromMap(currentUserMap.data()!);
      return organization;
    }
    return null;
  }
}
