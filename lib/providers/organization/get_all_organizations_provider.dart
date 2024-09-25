import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/constants/firebase_constants.dart';
import 'package:x51/models/organization.dart';

final getAllOrganizationProvider =
    StreamProvider.autoDispose<Iterable<Organization>>((ref) {
  final controller = StreamController<Iterable<Organization>>();

  final streamSubscription = FirebaseFirestore.instance
      .collection(FirebaseConstants.organizations)
      .snapshots()
      .listen((snapshot) {
    final orgList =
        snapshot.docs.map((orgData) => Organization.fromFirestore(orgData));
    controller.sink.add(orgList);
  });

  ref.onDispose(() {
    streamSubscription.cancel();
    controller.close();
  });
  return controller.stream;
});

// Static method to retrieve an organization with its locations from Firestore
// static Future<Organization> getOrganizationWithLocations(String orgId) async {
// Get organization document
// DocumentSnapshot orgDoc = await FirebaseFirestore.instance
//     .collection('organizations')
//     .doc(orgId)
//     .get();
//
// // Get all location documents for the organization
// QuerySnapshot locationSnapshot = await FirebaseFirestore.instance
//     .collection('organizations')
//     .doc(orgId)
//     .collection('locations')
//     .get();
//
// // Convert each location document into a Location object
// List<Location> locationsList = locationSnapshot.docs
//     .map((doc) => Location.fromFirestore(doc))
//     .toList();

// Create and return the Organization object with the locations
// return Organization.fromFirestore(orgDoc.data());
// }
