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
import 'package:x51/widgets/Error.dart';

import '../../../models/location.dart';
import '../../../models/organization.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loader.dart';

class UsersList extends ConsumerWidget {
  final UserModel userModel;

  const UsersList({required this.userModel, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(getAllUsersProvider);

    List<DataColumn> columns = const [
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Email')),
      DataColumn(label: Text('Password')),
      DataColumn(label: Text('Organization')),
      DataColumn(label: Text('Location')),
      DataColumn(label: Text('Choose Location')),
      DataColumn(label: Text('Delete User')),
    ];

    return users.when(
      data: (usersList) {
        if (usersList.isNotEmpty) {
          // update current user
          UserModel? user = usersList
              .toList()
              .firstWhereOrNull((user) => user.uuid == userModel.uuid);
          if (user != null) {
            saveUserModel(user);
          }
        }

        final DataTableSource data = UsersData(context, usersList, userModel);

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
      loading: () {
        return const Loader();
      },
    );
  }
}

class UsersData extends DataTableSource {
  List<Map<String, dynamic>> data = [];

  UsersData(BuildContext context, Iterable<UserModel> usersList,
      UserModel userModel) {
    Iterable<UserModel> filteredUsers = [];

    if (userModel.role == UserRole.orgUser.name) {
      filteredUsers = usersList.where((it) => it.uuid == userModel.uuid);
    } else if (userModel.role == UserRole.orgAdmin.name) {
      filteredUsers = usersList.where((it) => it.orgId == userModel.orgId);
    } else if (userModel.role == UserRole.superAdmin.name) {
      filteredUsers = usersList;
    }

    for (var userModel in filteredUsers) {
      String orgText = '';
      if (userModel.orgName.isEmpty) {
        orgText = 'Not Set Yet';
      } else {
        orgText = userModel.orgName;
      }

      String locText = '';
      if (userModel.locName.isEmpty) {
        locText = 'Not Set Yet';
      } else {
        locText = userModel.locName;
      }

      data.add({
        'Name': userModel.username,
        'Email': userModel.email,
        'Password': userModel.password,
        'Organization': orgText,
        'Location': locText,
        'chooseLocation': {
          'choose': () {
            _showLocationSelectionDialog(context, userModel);
          },
        },
        'actions': {
          'edit': () {
            print('Edit');
            _showDeleteUserDialog(context, userModel: userModel);
          },
          // 'delete': () {
          //   print('Delete');
          // },
        },
      });
    }
  }

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(CustomText(text: data[index]['Name'])),
      DataCell(CustomText(text: data[index]['Email'])),
      DataCell(CustomText(text: data[index]['Password'])),
      DataCell(CustomText(text: data[index]['Organization'])),
      DataCell(CustomText(text: data[index]['Location'])),
      DataCell(Center(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.gps_fixed),
              color: Colors.indigo,
              onPressed: data[index]['chooseLocation']['choose'],
            ),
          ],
        ),
      )),
      DataCell(Center(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.indigo,
              onPressed: data[index]['actions']['edit'],
            ),
          ],
        ),
      )),
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
