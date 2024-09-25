import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/pages/users/add_user_screen.dart';

import '../../providers/users/get_all_users_provider.dart';
import '../../repository/firebase_repository.dart';
import '../../utils/utils.dart';
import '../../widgets/Error.dart';
import '../../widgets/loader.dart';

class OrganizationUsersScreen extends ConsumerStatefulWidget {
  final Organization? organization;

  const OrganizationUsersScreen({required this.organization, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _OrganizationUsersScreenState();
  }
}

class _OrganizationUsersScreenState
    extends ConsumerState<OrganizationUsersScreen> {
  bool isFirstTimeLoading = false;
  bool isLoading = false;
  final _firebaseRepository = FirebaseRepository();
  List<UserModel> users = [];
  List<UserModel> selectedUsers = [];
  List<UserModel> unSelectedUsers = [];

  // Search and selected user variables
  List<UserModel> filteredUsers = [];
  List<UserModel> mUserList = [];
  UserModel? selectedUser;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    isFirstTimeLoading = true;
    isLoading = false;
    filteredUsers = users; // Initial list to display all users
    selectedUser = widget.organization?.admin;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      List<UserModel> mUsers = users
          .where(
              (user) => user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredUsers = mUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(getAllUsersProvider);
    String title = "${widget.organization?.name ?? "Organization"} Users";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Row(
            children: [
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    isFirstTimeLoading = true;
                    users = [];
                    _showAddUserDialog(context,
                        organization: widget.organization);
                  },
                  child: const Text('Add User'),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          )
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
        userList.when(
          data: (usersList) {
            List<UserModel> originalUsers = usersList.toList();

            if (isFirstTimeLoading || users.isEmpty) {
              users = originalUsers;
              filteredUsers = originalUsers;
              isFirstTimeLoading = false;
            }

            // List<UserModel> mUsers = originalUsers
            //     .where((user) => user.orgId == widget.organization?.id)
            //     .toList();

            selectedUsers = filteredUsers
                .where((user) => user.orgId == widget.organization?.id)
                .toList();

            unSelectedUsers = filteredUsers
                .where((user) => user.orgId != widget.organization?.id)
                .toList();
            filteredUsers = [];
            filteredUsers.addAll(selectedUsers);
            filteredUsers.addAll(unSelectedUsers);

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
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      bool selectedUser = selectedUsers.contains(user);

                      // selectedUsers
                      //     .where((it) => it.orgId == user.orgId)
                      //     .toList();

                      return ListTile(
                        title: Text(user.email),
                        trailing: selectedUser
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });
                          if (selectedUsers.contains(user)) {
                            user.orgId = '';
                            user.orgName = '';
                            Utils.showSuccessSnackBar('Removing User');
                          } else {
                            user.orgId = widget.organization!.id;
                            user.orgName = widget.organization!.name;
                            Utils.showSuccessSnackBar('Adding User');
                          }

                          _firebaseRepository.setUser(user).then((value) {
                            if (value.isNotEmpty) {
                              Utils.showSuccessSnackBar(value);
                              if (value == 'Success') {}
                            } else {
                              Utils.showSuccessSnackBar('Failed');
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }).onError((error, stackTrace) {
                            Utils.showSuccessSnackBar('Failed');
                            setState(() {
                              isLoading = false;
                            });
                          });
                        },
                      );
                    },
                  ),
                ),
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

  void _showAddUserDialog(BuildContext context, {Organization? organization}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return AddUserScreen(organization: organization);
      },
    ));
  }
}
