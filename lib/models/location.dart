import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  String id;
  String name;
  String address;
  String city;
  String state;
  String country;
  String postalCode;
  String contactNumber;
  String manager;
  Timestamp createdAt;

  Location({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.contactNumber,
    required this.manager,
    required this.createdAt,
  });

  factory Location.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Location(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      postalCode: data['postal_code'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      manager: data['manager'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  factory Location.fromMap(Map<String, dynamic> data) {
    return Location(
      id: data['id'],
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      postalCode: data['postal_code'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      manager: data['manager'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  // Converts Location object to a map to store in Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id' : id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'contact_number': contactNumber,
      'manager': manager,
      'created_at': createdAt,
    };
  }
}
