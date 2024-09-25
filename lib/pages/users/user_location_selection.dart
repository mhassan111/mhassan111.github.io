import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/models/location.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/providers/organization/organization_provider.dart';
import '../../providers/users/get_all_users_provider.dart';
import '../../repository/firebase_repository.dart';
import '../../utils/utils.dart';
import '../../widgets/Error.dart';
import '../../widgets/loader.dart';

class LocationSelectionScreen extends ConsumerStatefulWidget {
  final Organization? organization;
  final UserModel userModel;
  final Function(Location? userModel) onUserSelected;

  const LocationSelectionScreen(
      {required this.userModel,
      required this.organization,
      required this.onUserSelected,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _LocationSelectionScreenState();
  }
}

class _LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  bool isLoading = false;
  final _firebaseRepository = FirebaseRepository();
  List<Location> locations = [];
  late UserModel userModel;

  // Search and selected user variables
  List<Location> filteredLocations = [];
  Location? selectedLocation;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredLocations = locations; // Initial list to display all users
    userModel = widget.userModel;
    // selectedUser = widget.organization?.admin;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredLocations = locations
          .where(
              (user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final organization =
        ref.watch(anyOrganizationProvider(widget.userModel.orgId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select your Location"),
        actions: [
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                widget.onUserSelected(selectedLocation);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        if (isLoading)
          Container(
            color: Colors.transparent,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        organization.when(
          data: (org) {
            // First time loading
            if (locations.isEmpty) {
              filteredLocations = org?.locations.toList() ?? [];
            }
            locations = org?.locations.toList() ?? [];

            if (userModel.locId.isNotEmpty) {
              selectedLocation =
                  locations.where((loc) => loc.id == userModel.locId).first;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a user...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: updateSearchQuery,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      return ListTile(
                        title: Text(location.name),
                        trailing: location.id == selectedLocation?.id
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });

                          UserModel mUserModel = userModel;
                          if (selectedLocation == null) {
                            userModel.locId = location.id;
                            userModel.locName = location.name;
                            selectedLocation = location;
                          } else if (selectedLocation!.id == location.id) {
                            userModel.locId = '';
                            userModel.locName = '';
                            selectedLocation = null;
                          } else {
                            userModel.locId = location.id;
                            userModel.locName = location.name;
                            selectedLocation = location;
                          }

                          _firebaseRepository.setUser(userModel).then((value) {
                            if (value.isNotEmpty) {
                              Utils.showSuccessSnackBar(value);
                              if (value == 'Success') {}
                            } else {
                              setState(() {
                                userModel = mUserModel;
                              });
                              Utils.showSuccessSnackBar('Failed');
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }).onError((error, stackTrace) {
                            Utils.showSuccessSnackBar('Failed');
                            setState(() {
                              userModel = mUserModel;
                              isLoading = false;
                            });
                          });
                        },
                      );
                    },
                  ),
                ),
                // if (selectedUser != null)
                //   Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: Text(
                //       "Selected UserModel: ${selectedUser!.email}",
                //       style: const TextStyle(
                //           fontSize: 16, fontWeight: FontWeight.bold),
                //     ),
                //   ),
              ],
            );
          },
          error: (error, stackTrace) {
            return ErrorText(error: error.toString());
          },
          loading: () {
            return const Loader();
          },
        ),
      ]),
    );
  }

// Show a snackbar to display selected user
// void _showSelectedUser(BuildContext context, UserModel user) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text("Selected: ${user.email}"),
//     ),
//   );
// }
}
