
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/repository/firebase_repository.dart';

final authProvider = Provider((ref) {
  return FirebaseRepository();
});