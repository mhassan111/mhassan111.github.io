import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/constants/firebase_constants.dart';
import 'package:x51/models/location.dart';
import 'package:x51/models/supervisor_model.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/repository/firebase_repository.dart';

import '../../models/organization.dart';
import '../../utils/utils.dart';

final orgDataServiceProvider = Provider(
  (ref) => OrganizationDataService(firestore: FirebaseFirestore.instance),
);

class OrganizationDataService {
  final FirebaseFirestore _firestore;
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  OrganizationDataService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<String> addOrganizationDataToFirestore(
      {required String id,
      required String name,
      required String industry,
      String? owner,
      List<Location>? locations,
      List<Supervisor>? supervisors,
      required bool directEditing,
      required UserModel user}) async {
    var result = '';
    Organization organization = Organization(
        id: id,
        name: name,
        industry: industry,
        owner: owner ?? "",
        createdAt: Timestamp.now(),
        locations: locations ?? [],
        supervisors: supervisors ?? [],
        directEditing: directEditing,
        admin: user);

    try {
      if (user.email.isNotEmpty) {
        await _firebaseRepository.setUser(user);
      }

      await _firestore
          .collection(FirebaseConstants.organizations)
          .doc(organization.id)
          .set(organization.toFirestore())
          .then((value) {
        Utils.printMessage('addOrganizationDataToFirestore success');
        result = 'Organization Updated Successfully';
      }).onError((e, stacktrace) {
        result = '';
      });
    } on Exception catch (e) {
      Utils.printMessage('addOrganizationDataToFirestore ${e.toString()}');
      result = '';
    }
    return result;
  }

  Future<String> deleteOrganization(
      {required Organization organization}) async {
    var result = '';
    try {
      await _firestore
          .collection(FirebaseConstants.organizations)
          .doc(organization.id)
          .delete()
          .then((value) {
        Utils.printMessage('deleteOrganization success');
        result = 'Organization Deleted';
      }).onError((e, stacktrace) {
        result = '';
      });
    } on Exception catch (e) {
      Utils.printMessage('deleteOrganization ${e.toString()}');
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
