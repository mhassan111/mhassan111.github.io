import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:uuid/uuid.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/pages/users/organization_users.dart';
import 'package:x51/pages/users/supervisor_user_selection.dart';
import 'package:x51/providers/organization/organization_data_service.dart';
import 'package:x51/widgets/loader.dart';

import '../../models/location.dart';
import '../../models/organization.dart';
import '../../models/supervisor_model.dart';
import '../../utils/utils.dart';
import '../users/users_selection.dart';
import 'package:collection/collection.dart'; // For SetEquality

class AddOrganizationForm extends ConsumerStatefulWidget {
  final Organization? organization;

  const AddOrganizationForm({required this.organization, super.key});

  @override
  ConsumerState<AddOrganizationForm> createState() =>
      _AddOrganizationFormState();
}

class _AddOrganizationFormState extends ConsumerState<AddOrganizationForm> {
  bool _directEditing = false;
  bool _showLoader = false;
  bool createOrganization = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  UserModel adminUser = UserModel.emptyUser();

  // final TextEditingController _ownerController = TextEditingController();

  final List<Map<String, TextEditingController>> _locationControllers = [];

  @override
  void initState() {
    super.initState();
    createOrganization = widget.organization == null;
    _addLocationField(); // Start with one location field
    String userEmail = widget.organization?.admin.email ?? '';
    adminUser = widget.organization?.admin ?? UserModel.emptyUser();
    _directEditing = widget.organization?.directEditing ?? false;
  }

  // Add a location input field dynamically
  void _addLocationField({bool newEmptyLocation = false}) {
    setState(() {
      List<Location> locations = widget.organization?.locations ?? [];

      if (!newEmptyLocation) {
        _nameController.text = widget.organization?.name ?? "";
        _industryController.text = widget.organization?.industry ?? "";
      }

      if (newEmptyLocation) {
        _locationControllers.add({
          'id': TextEditingController(text: const Uuid().v4()),
          'name': TextEditingController(),
          'address': TextEditingController(),
          'city': TextEditingController(),
          'state': TextEditingController(),
          'country': TextEditingController(),
          'postalCode': TextEditingController(),
          'contactNumber': TextEditingController(),
          'manager': TextEditingController(),
        });
      } else if (locations.isNotEmpty) {
        for (Location location in locations) {
          _locationControllers.add({
            'id': TextEditingController(text: location.id),
            'name': TextEditingController(text: location.name),
            'address': TextEditingController(text: location.address),
            'city': TextEditingController(text: location.city),
            'state': TextEditingController(text: location.state),
            'country': TextEditingController(text: location.country),
            'postalCode': TextEditingController(text: location.postalCode),
            'contactNumber':
                TextEditingController(text: location.contactNumber),
            'manager': TextEditingController(text: location.manager),
          });
        }
      }
    });
  }

  // Remove a location input field
  void _removeLocationField(int index) {
    setState(() {
      _locationControllers.removeAt(index);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Gather organization data
      String orgName = _nameController.text;
      String industry = _industryController.text;
      String owner = '';

      List<Location> locations = _locationControllers.map((locationFields) {
        List<Location> widgetLocations = widget.organization?.locations ?? [];
        Location? location = widgetLocations
            .firstWhereOrNull((loc) => loc.id == locationFields['id']!.text);

        return Location(
          id: locationFields['id']!.text,
          name: locationFields['name']!.text,
          address: locationFields['address']!.text,
          city: locationFields['city']!.text,
          state: locationFields['state']!.text,
          country: locationFields['country']!.text,
          postalCode: locationFields['postalCode']!.text,
          contactNumber: locationFields['contactNumber']!.text,
          manager: locationFields['manager']!.text,
          createdAt: location?.createdAt ?? Timestamp.now(),
        );
      }).toList();

      var orgId = '';
      if (createOrganization) {
        orgId = const Uuid().v4();
      } else {
        orgId = widget.organization?.id ?? "";
      }

      if (widget.organization?.admin != null) {
        widget.organization?.admin.role = UserRole.orgAdmin.name;
        widget.organization?.admin.orgId = widget.organization?.id ?? "";
        widget.organization?.admin.orgName = widget.organization?.name ?? "";
      }

      ref
          .read(orgDataServiceProvider)
          .addOrganizationDataToFirestore(
            id: orgId,
            name: orgName,
            industry: industry,
            locations: locations,
            user: adminUser ?? UserModel.emptyUser(),
            supervisors: widget.organization?.supervisors ?? [],
            directEditing: _directEditing,
          )
          .then((value) {
        if (value.isNotEmpty) {
          Utils.showSuccessSnackBar(value);
        } else {
          Utils.showErrorSnackBar("Error! Try Again");
        }
        setState(() {
          _showLoader = false;
        });
      }).onError((error, stackTrace) {
        Utils.showErrorSnackBar("Error: While Adding Organization");
        setState(() {
          _showLoader = false;
        });
      });
    }
  }

  void setAdmin(UserModel? userModel) {
    setState(() {
      widget.organization?.admin = userModel ?? UserModel.emptyUser();
      adminUser = userModel ?? UserModel.emptyUser();
    });
  }

  void setSupervisors(List<Supervisor>? newSupervisors) {
    final oldSupervisors = widget.organization?.supervisors ?? [];
    final oldIds = oldSupervisors.map((s) => s.id).toSet();
    final newIds = (newSupervisors ?? []).map((s) => s.id).toSet();
    final isDifferent = !const SetEquality().equals(oldIds, newIds);

    if (isDifferent) {
      setState(() {
        widget.organization?.supervisors = newSupervisors ?? [];
      });
      _submitForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: false,
          title: const Row(
            children: [
              SizedBox(width: 8),
              Text('Add Organization'),
            ],
          ),
          actions: [
            Row(
              children: [
                const Text('Allow Supervisor Edits'),
                Switch(
                  value: _directEditing,
                  onChanged: (value) {
                    setState(() {
                      _directEditing = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _showManageUsersSelectionDialog(context,
                  organization: widget.organization),
              child: const Text('Manage Users'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _showSupervisorSelectionDialog(
                  context, setSupervisors,
                  organization: widget.organization),
              child: const Text('Manage Supervisors'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              child: const Text('Update Organization'),
              onPressed: () {
                setState(() {
                  _showLoader = true;
                });
                _submitForm();
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Organization name input
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                    labelText: 'Organization Name'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an organization name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16.0),

                              // Industry input
                              TextFormField(
                                controller: _industryController,
                                decoration: const InputDecoration(
                                    labelText: 'Industry'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an industry';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),

                              // Locations input
                              const SizedBox(height: 15.0),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Admin',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (adminUser.email.isEmpty)
                                    Row(
                                      children: [
                                        const Text('No Admin set yet'),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: ElevatedButton(
                                            child: const Text('Select Admin'),
                                            onPressed: () {
                                              _showAdminSelectionDialog(
                                                  context, setAdmin,
                                                  organization:
                                                      widget.organization);
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      children: [
                                        Text(adminUser.email),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: ElevatedButton(
                                            child: const Text('Change Admin'),
                                            onPressed: () {
                                              _showAdminSelectionDialog(
                                                  context, setAdmin,
                                                  organization:
                                                      widget.organization);
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),

                              const SizedBox(height: 30.0),

                              const Text(
                                'Locations',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 15.0),

                              ..._locationControllers
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                var locationFields = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 18,
                                    ),

                                    Text('Location ${index + 1}',
                                        style: const TextStyle(fontSize: 16)),
                                    const SizedBox(height: 8.0),

                                    // Location name input
                                    TextFormField(
                                      controller: locationFields['name'],
                                      decoration: const InputDecoration(
                                          labelText: 'Location Name'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a location name';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      controller: locationFields['address'],
                                      decoration: const InputDecoration(
                                          labelText: 'Address'),
                                    ),
                                    TextFormField(
                                      controller: locationFields['city'],
                                      decoration: const InputDecoration(
                                          labelText: 'City'),
                                    ),
                                    TextFormField(
                                      controller: locationFields['state'],
                                      decoration: const InputDecoration(
                                          labelText: 'State'),
                                    ),
                                    TextFormField(
                                      controller: locationFields['country'],
                                      decoration: const InputDecoration(
                                          labelText: 'Country'),
                                    ),
                                    // TextFormField(
                                    //   controller: locationFields['postalCode'],
                                    //   decoration: InputDecoration(labelText: 'Postal Code'),
                                    // ),
                                    // TextFormField(
                                    //   controller: locationFields['contactNumber'],
                                    //   decoration:
                                    //       InputDecoration(labelText: 'Contact Number'),
                                    // ),
                                    // TextFormField(
                                    //   controller: locationFields['manager'],
                                    //   decoration: InputDecoration(labelText: 'Manager'),
                                    // ),

                                    // Remove location button
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (_locationControllers.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () =>
                                              _removeLocationField(index),
                                          child: const Text('Remove Location'),
                                        ),
                                      ),
                                    // Divider(),
                                  ],
                                );
                              }),

                              // Add location button
                              const SizedBox(height: 15.0),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _addLocationField(newEmptyLocation: true),
                                  child: const Text('Add New Location'),
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              // Submit button
                              const SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (_showLoader)
              Container(
                key: const ValueKey('loaderOverlay'),
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Loader(),
                      SizedBox(height: 12),
                      Text(
                        'Updating, Please wait...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }
}

void _showAdminSelectionDialog(
    BuildContext context, ValueChanged<UserModel?> callback,
    {Organization? organization}) {
  Future.delayed(Duration.zero, () {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return UserSelectionScreen(
          organization: organization,
          onUserSelected: (userModel) {
            callback(userModel);
          },
        );
      },
    ));
  });
}

void _showSupervisorSelectionDialog(
    BuildContext context, ValueChanged<List<Supervisor>?> callback,
    {Organization? organization}) {
  Future.delayed(Duration.zero, () {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return SupervisorUserScreen(
          organization: organization,
          onSupervisorsSelected: (List<Supervisor> supervisors) {
            callback(supervisors);
          },
        );
      },
    ));
  });
}

void _showManageUsersSelectionDialog(BuildContext context,
    {Organization? organization}) {
  Future.delayed(Duration.zero, () {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return OrganizationUsersScreen(organization: organization);
      },
    ));
  });
}
