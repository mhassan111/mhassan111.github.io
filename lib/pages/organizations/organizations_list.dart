import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/organisation_main.dart';
import 'package:x51/pages/organizations/AddOrganizationForm.dart';
import 'package:x51/pages/organizations/DeleteOrganizationDialog.dart';
import 'package:x51/pages/users/users_selection.dart';
import 'package:x51/providers/users/get_all_users_provider.dart';
import 'package:x51/widgets/Error.dart';

import '../../../widgets/custom_text.dart';
import '../../../widgets/loader.dart';
import '../../helpers/shared_preferences_helper.dart';
import '../../providers/organization/get_all_organizations_provider.dart';

class OrganizationsPage extends ConsumerStatefulWidget {
  const OrganizationsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _OrgListState();
  }
}

class _OrgListState extends ConsumerState<OrganizationsPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: getUserModel(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Loading....');
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              var data = snapshot.data ?? '';
              UserModel userModel = data as UserModel;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (userModel.role == UserRole.superAdmin.name)
                        Row(
                          children: [
                            const Text("Add New Organization"),
                            IconButton(
                              icon: const Icon(Icons.add),
                              color: Colors.indigo,
                              onPressed: () {
                                _showFullScreenDialog(context);
                              },
                            ),
                          ],
                        )
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        OrganizationsList(
                          userModel: userModel,
                        )
                      ],
                    ),
                  ),
                ],
              );
            }
        }
      },
    );
  }
}

class OrganizationsList extends ConsumerWidget {
  final UserModel userModel;

  const OrganizationsList({required this.userModel, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(getAllOrganizationProvider);

    List<DataColumn> columns = const [
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Industry')),
      DataColumn(label: Text('Admin')),
      DataColumn(label: Text('Edit')),
      DataColumn(label: Text('Delete')),
    ];

    return organizations.when(
      data: (organizationList) {
        final DataTableSource data =
            OrganizationData(context, organizationList, userModel);

        return PaginatedDataTable(
          columns: columns,
          source: data,
          columnSpacing: 50,
          horizontalMargin: 30,
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

class OrganizationData extends DataTableSource {
  List<Map<String, dynamic>> data = [];
  Iterable<Organization> filteredOrganizations = [];

  OrganizationData(BuildContext context,
      Iterable<Organization> organizationList, UserModel userModel) {
    if (userModel.role == UserRole.orgUser.name) {
      filteredOrganizations =
          organizationList.where((it) => it.id == userModel.orgId);
    } else if (userModel.role == UserRole.orgAdmin.name) {
      filteredOrganizations =
          organizationList.where((it) => it.id == userModel.orgId);
    } else if (userModel.role == UserRole.superAdmin.name) {
      filteredOrganizations = organizationList;
    }

    for (var org in filteredOrganizations) {
      data.add({
        'name': org.name,
        'industry': org.industry,
        'admin': org.admin.email,
        'editActions': {
          'edit': () {
            print('Edit');
            _showFullScreenDialog(context, organization: org);
          }
        },
        'deleteActions': {
          'delete': () {
            print('delete');
            _showDeleteOrganizationDialog(context, organization: org);
          }
        }
      });
    }
  }

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(CustomText(text: data[index]['name'])),
      DataCell(CustomText(text: data[index]['industry'])),
      DataCell(Row(
        children: [
          if (data[index]['admin'].toString().isNotEmpty)
            CustomText(text: data[index]['admin'])
          else
            const CustomText(text: 'No Admin'),
        ],
      )),
      DataCell(Center(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.indigo,
              onPressed: data[index]['editActions']['edit'],
            ),
          ],
        ),
      )),
      DataCell(Center(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: data[index]['deleteActions']['delete'],
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

void _showFullScreenDialog(BuildContext context, {Organization? organization}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return AddOrganizationForm(organization: organization);
    },
  ));
}

void _showDeleteOrganizationDialog(BuildContext context,
    {Organization? organization}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: false,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return DeleteOrganizationDialog(organization: organization);
    },
  ));
}
