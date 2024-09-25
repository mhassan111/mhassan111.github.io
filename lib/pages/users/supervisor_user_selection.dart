import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/repository/firebase_repository.dart';

import '../../models/supervisor_model.dart';
import '../../providers/users/get_all_users_provider.dart';
import '../../utils/utils.dart';
import '../../widgets/Error.dart';
import '../../widgets/loader.dart';

class SupervisorUserScreen extends ConsumerStatefulWidget {
  final Organization? organization;
  final Function(List<Supervisor> supervisors) onSupervisorsSelected;

  const SupervisorUserScreen({
    required this.organization,
    required this.onSupervisorsSelected,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SupervisorUserScreenState();
  }
}

class _SupervisorUserScreenState extends ConsumerState<SupervisorUserScreen> {
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  bool isLoading = false;

  // Supervisors data
  UserModel? selectedSupervisor;
  Map<String, List<UserModel>> supervisorUsers = {};

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredUsers = users;
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

  void updateOrganizationSupervisor() {
    if (selectedSupervisor == null) return;

    // Find if the supervisor already exists
    int index = widget.organization!.supervisors.indexWhere(
      (s) => s.id == selectedSupervisor!.email, // using email as id
    );

    Supervisor newSupervisor = Supervisor(
      id: selectedSupervisor!.email,
      name: selectedSupervisor!.username,
      userEmails: supervisorUsers[selectedSupervisor!.email]
              ?.map((e) => e.email)
              .toList() ??
          [],
    );

    setState(() {
      if (index == -1) {
        // Not found, add new
        widget.organization!.supervisors.add(newSupervisor);
      } else {
        // Found, update existing
        widget.organization!.supervisors[index] = newSupervisor;
      }
    });
  }

  void goBack() {
    List<Supervisor> selectedSupervisors = supervisorUsers.entries.map((entry) {
      return Supervisor(
        id: entry.key,
        name: entry.key,
        userEmails: entry.value.map((e) => e.email).toList(),
      );
    }).toList();

    widget.onSupervisorsSelected(selectedSupervisors);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(getAllUsersProvider);
    final _firebaseRepository = FirebaseRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Supervisor and Users"),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (selectedSupervisor != null) {
                List<Supervisor> selectedSupervisors =
                    supervisorUsers.entries.map((entry) {
                  return Supervisor(
                    id: entry.key,
                    name: entry.key,
                    userEmails: entry.value.map((e) => e.email).toList(),
                  );
                }).toList();

                List<String> users = selectedSupervisors
                    .where((supervisor) => supervisor.id == (selectedSupervisor?.email ?? ""))
                    .expand((supervisor) => supervisor.userEmails
                    .where((email) => email != supervisor.id))
                    .toList();

                if (users.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                  });

                  _firebaseRepository
                      .updateUserListByEmail(
                    selectedSupervisor?.email ?? "",
                    users,)
                      .then((value) {
                    if (value.isNotEmpty) {
                      Utils.showSuccessSnackBar(value);
                      if (value == 'Success') {
                        goBack();
                      }
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
                } else {
                  goBack();
                }
              } else {
                goBack();
              }
            },
            child: Text(
              selectedSupervisor != null ? 'Save Changes' : 'Save Changes',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          userList.when(
            data: (usersList) {
              if (users.isEmpty) {
                filteredUsers = usersList.toList();
              }
              users = usersList.toList();

              if (widget.organization != null) {
                for (Supervisor supervisor
                    in widget.organization!.supervisors) {
                  supervisorUsers[supervisor.id] =
                      supervisor.userEmails.map((email) {
                    return filteredUsers.firstWhere(
                      (user) => user.email == email,
                      orElse: () => UserModel.emptyUser(),
                    );
                  }).toList();
                }
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Supervisor",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: selectedSupervisor?.uuid,
                      items: users.map((user) {
                        return DropdownMenuItem(
                          value: user.uuid,
                          child: Text(user.email),
                        );
                      }).toList(),
                      onChanged: (uuid) {
                        setState(() {
                          selectedSupervisor =
                              users.firstWhere((user) => user.uuid == uuid);
                        });
                      },
                    ),
                  ),
                  if (selectedSupervisor != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search users to assign...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: updateSearchQuery,
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          // 🆕 Exclude supervisor himself/herself
                          final availableUsers = filteredUsers
                              .where((user) =>
                                  user.uuid != selectedSupervisor!.uuid)
                              .toList();

                          return ListView.builder(
                            itemCount: availableUsers.length,
                            itemBuilder: (context, index) {
                              final user = availableUsers[index];

                              bool isSelected =
                                  supervisorUsers[selectedSupervisor!.email]
                                          ?.any((u) => u.email == user.email) ??
                                      false;

                              return ListTile(
                                title: Text(user.email),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : const Icon(Icons.circle_outlined),
                                onTap: () {
                                  setState(() {
                                    if (supervisorUsers[
                                            selectedSupervisor!.email] ==
                                        null) {
                                      supervisorUsers[
                                          selectedSupervisor!.email] = [];
                                    }

                                    if (isSelected) {
                                      supervisorUsers[
                                              selectedSupervisor!.email]!
                                          .remove(user);
                                    } else {
                                      supervisorUsers[
                                              selectedSupervisor!.email]!
                                          .add(user);
                                    }

                                    updateOrganizationSupervisor();
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    )
                  ]
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
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
