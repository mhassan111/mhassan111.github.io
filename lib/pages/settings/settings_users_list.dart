import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:x51/helpers/shared_preferences_helper.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/pages/users/user_location_selection.dart';
import 'package:x51/pages/users/widgets/DeleteUserAlertDialog.dart';
import 'package:x51/providers/users/get_all_users_provider.dart';
import 'package:x51/repository/firebase_repository.dart';
import 'package:x51/widgets/Error.dart';

import '../../../models/location.dart';
import '../../../models/organization.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loader.dart';
import '../../utils/utils.dart';

class AdminRightsUsersList extends ConsumerWidget {
  final UserModel userModel;

  const AdminRightsUsersList({required this.userModel, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(getAllUsersProvider);

    List<DataColumn> columns = const [
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Email')),
      DataColumn(label: Text('Organization')),
      DataColumn(label: Text('Allow Edit Summary')), // Switch column
    ];

    return users.when(
      data: (settingUsers) {
        if (settingUsers.isNotEmpty) {
          UserModel? user = settingUsers
              .toList()
              .firstWhereOrNull((user) => user.uuid == userModel.uuid);
          if (user != null) {
            saveUserModel(user);
          }
        }

        final data = UsersData(context, settingUsers, userModel);
        return PaginatedDataTable(
          columns: columns,
          source: data,
          columnSpacing: 50,
          horizontalMargin: 10,
          rowsPerPage: 10,
        );
      },
      error: (error, stackTrace) {
        return ErrorText(error: error.toString());
      },
      loading: () => const Loader(),
    );
  }
}

class UsersData extends DataTableSource {
  List<Map<String, dynamic>> data = [];
  Iterable<UserModel> filteredUsers = [];

  UsersData(BuildContext context, Iterable<UserModel> settingUsersList,
      UserModel userModel) {
    // filteredUsers = settingUsersList.where((it) =>
    // it.role == UserRole.orgAdmin.name && it.orgId == userModel.orgId);
    filteredUsers =
        settingUsersList.where((it) => it.role == UserRole.orgAdmin.name);

    for (var user in filteredUsers) {
      data.add({
        'Name': user.username,
        'Email': user.email,
        'Organization': user.orgName,
        'Allow Edit Summary': ValueNotifier<bool>(user.allowSummaryEdit == "1"),
        'isUpdating': ValueNotifier<bool>(false),
      });
    }
  }

  @override
  DataRow getRow(int index) {
    final switchNotifier =
        data[index]['Allow Edit Summary'] as ValueNotifier<bool>;
    final isUpdating = data[index]['isUpdating'] as ValueNotifier<bool>;
    final _firebaseRepository = FirebaseRepository();

    return DataRow(cells: [
      DataCell(CustomText(text: data[index]['Name'])),
      DataCell(CustomText(text: data[index]['Email'])),
      DataCell(CustomText(text: data[index]['Organization'])),
      DataCell(
        Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: isUpdating,
            builder: (context, loading, _) {
              return loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ValueListenableBuilder<bool>(
                      valueListenable: switchNotifier,
                      builder: (context, value, _) {
                        return Switch(
                          value: value,
                          onChanged: (newValue) {
                            switchNotifier.value = newValue;
                            isUpdating.value = true;

                            final email = data[index]['Email'];
                            final originalValue = !newValue;

                            UserModel? userModel = filteredUsers.firstWhere(
                              (user) => user.email == email,
                            );

                            // final previousModel = userModel.copyWith();
                            if (newValue == true) {
                              userModel.allowSummaryEdit = "1";
                            } else {
                              userModel.allowSummaryEdit = "0";
                            }

                            _firebaseRepository
                                .setUser(userModel)
                                .then((response) {
                              if (response == 'Success') {
                                Utils.showSuccessSnackBar(
                                    'Updated successfully');
                              } else {
                                Utils.showErrorSnackBar('Failed to update');
                                switchNotifier.value =
                                    originalValue; // revert UI
                              }
                              isUpdating.value = false;
                            }).onError((error, stackTrace) {
                              Utils.showErrorSnackBar(
                                  'Error: ${error.toString()}');
                              switchNotifier.value = originalValue; // revert UI
                              isUpdating.value = false;
                            });
                          },
                        );
                      },
                    );
            },
          ),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

void _showDeleteUserDialog(BuildContext context, {UserModel? userModel}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: false,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return DeleteUserAlertDialog(userModel: userModel);
    },
  ));
}

void _showLocationSelectionDialog(BuildContext context, UserModel userModel,
    {Organization? organization}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return LocationSelectionScreen(
        userModel: userModel,
        organization: organization,
        onUserSelected: (Location? userModel) {},
      );
    },
  ));
}
