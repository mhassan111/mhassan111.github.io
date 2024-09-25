import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/constants/firebase_constants.dart';
import 'package:x51/models/location.dart';

import '../../../models/organization.dart';
import '../../../utils/utils.dart';
import '../../models/user_model.dart';

final usersDataServiceProvider = Provider(
      (ref) => UsersDataService(firestore: FirebaseFirestore.instance),
);

class UsersDataService {
  final FirebaseFirestore _firestore;

  UsersDataService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<String> deleteUser(
      {required UserModel userModel}) async {
    var result = '';
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userModel.uuid)
          .delete()
          .then((value) {
        Utils.printMessage('deleteUser success');
        result = 'deleteUser Deleted';
      }).onError((e, stacktrace) {
        result = '';
      });
    } on Exception catch (e) {
      Utils.printMessage('deleteUser ${e.toString()}');
      result = '';
    }
    return result;
  }
}
