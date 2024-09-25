import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/organization.dart';
import '../../providers/organization/organization_data_service.dart';
import '../../utils/utils.dart';
import '../../widgets/loader.dart';

class DeleteOrganizationDialog extends ConsumerStatefulWidget {
  final Organization? organization;

  const DeleteOrganizationDialog({required this.organization, super.key});

  @override
  ConsumerState<DeleteOrganizationDialog> createState() =>
      _DeleteOrganizationDialogState();
}

class _DeleteOrganizationDialogState
    extends ConsumerState<DeleteOrganizationDialog> {
  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    Organization? organization = widget.organization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24.0),
        Text(
          'Delete ${organization?.name ?? ""}',
          style: const TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Are you sure you want to delete ${organization?.name ?? ""}?',
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            const SizedBox(
              width: 30,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showLoader = true;
                });
                ref
                    .read(orgDataServiceProvider)
                    .deleteOrganization(organization: organization!)
                    .then((value) {
                  if (value.isNotEmpty) {
                    Navigator.pop(context, 'Yes');
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
              },
              child: const Text('Yes'),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        if (_showLoader)
          const Column(
            children: [
              Loader(),
              SizedBox(height: 6.0),
              Text("Deleting, Please wait..."),
              SizedBox(height: 24.0),
            ],
          ),
        SizedBox(height: 24.0),
      ],
    );
  }
}
