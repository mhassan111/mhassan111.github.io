import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/constants/constants.dart';
import 'package:x51/models/user_model.dart';

final getAllUsersProvider =
    StreamProvider.autoDispose<Iterable<UserModel>>((ref) {
  final controller = StreamController<Iterable<UserModel>>();

  final streamSubscription = FirebaseFirestore.instance
      .collection(Constants.usersCollection)
      .snapshots()
      .listen((snapshot) {
    final users =
        snapshot.docs.map((userData) => UserModel.fromMap(userData.data()));
    controller.sink.add(users);
  });

  ref.onDispose(() {
    streamSubscription.cancel();
    controller.close();
  });
  return controller.stream;
});
