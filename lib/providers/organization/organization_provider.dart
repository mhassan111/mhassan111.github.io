import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/providers/organization/organization_data_service.dart';

final anyOrganizationProvider = FutureProvider.family((ref, orgId) async {
  final Organization? organization =
      await ref.watch(orgDataServiceProvider).fetchAnyOrganization(orgId);
  return organization;
});
