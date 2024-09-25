import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:x51/models/supervisor_model.dart';
import 'package:x51/models/user_model.dart';
import 'location.dart'; // Import the Location model

class Organization {
  String id;
  String name;
  String industry;
  String owner;
  Timestamp createdAt;
  List<Location> locations;
  UserModel admin;
  List<Supervisor> supervisors;
  bool directEditing; // <-- NEW FIELD

  Organization({
    required this.id,
    required this.name,
    required this.industry,
    required this.owner,
    required this.createdAt,
    required this.locations,
    required this.admin,
    this.supervisors = const [],
    this.directEditing = false, // <-- DEFAULT VALUE
  });

  factory Organization.fromFirestore(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    var locationsList = (data['locations'] as List?)
        ?.map((locationData) =>
        Location.fromMap(locationData as Map<String, dynamic>))
        .toList() ??
        [];

    var supervisorsList = (data['supervisors'] as List?)
        ?.map((supervisorData) =>
        Supervisor.fromMap(supervisorData as Map<String, dynamic>))
        .toList() ??
        [];

    return Organization(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      industry: data['industry'] ?? '',
      owner: data['owner'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      locations: locationsList,
      admin: UserModel.fromMap(data['admin']),
      supervisors: supervisorsList,
      directEditing: data['direct_editing'] ?? false, // <-- READ FROM FIRESTORE
    );
  }

  factory Organization.fromMap(Map<String, dynamic> data) {
    var locationsList = (data['locations'] as List?)
        ?.map((locationData) =>
        Location.fromMap(locationData as Map<String, dynamic>))
        .toList() ??
        [];

    var supervisorsList = (data['supervisors'] as List?)
        ?.map((supervisorData) =>
        Supervisor.fromMap(supervisorData as Map<String, dynamic>))
        .toList() ??
        [];

    return Organization(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      industry: data['industry'] ?? '',
      owner: data['owner'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      locations: locationsList,
      admin: UserModel.fromMap(data['admin']),
      supervisors: supervisorsList,
      directEditing: data['direct_editing'] ?? false, // <-- FROM MAP
    );
  }

  Map<String, dynamic> toFirestore() {
    var locationsList =
    locations.map((locationData) => locationData.toFirestore()).toList();

    var supervisorsList =
    supervisors.map((supervisor) => supervisor.toMap()).toList();

    return {
      'id': id,
      'name': name,
      'industry': industry,
      'owner': owner,
      'created_at': createdAt,
      'locations': locationsList,
      'admin': admin.toMap(),
      'supervisors': supervisorsList,
      'direct_editing': directEditing, // <-- WRITE TO FIRESTORE
    };
  }
}

