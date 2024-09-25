import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/models/user_model.dart';

import '../../providers/users/get_all_users_provider.dart';
import '../../widgets/Error.dart';
import '../../widgets/loader.dart';

class UserSelectionScreen extends ConsumerStatefulWidget {
  final Organization? organization;
  final Function(UserModel? userModel) onUserSelected;

  const UserSelectionScreen(
      {required this.organization, required this.onUserSelected, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _UserSelectionScreenState();
  }
}

class _UserSelectionScreenState extends ConsumerState<UserSelectionScreen> {

  List<UserModel> users = [];

  // Search and selected user variables
  List<UserModel> filteredUsers = [];
  UserModel? selectedUser;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredUsers = users; // Initial list to display all users
    selectedUser = widget.organization?.admin;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = users
          .where(
              (user) => user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(getAllUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select an Admin from Users List"),
        actions: [
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                widget.onUserSelected(selectedUser);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
      body: userList.when(
        data: (usersList) {
          // First time loading
          if (users.isEmpty) {
            filteredUsers = usersList.toList();
          }
          users = usersList.toList();

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
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: updateSearchQuery,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      title: Text(user.email),
                      trailing: selectedUser?.email == user.email
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          if (selectedUser?.email == user.email) {
                            selectedUser = null;
                          } else {
                            selectedUser = user;
                          }
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
