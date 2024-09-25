import 'package:flutter/material.dart';
import 'package:x51/pages/transcripts/transcripts_list.dart';

import '../../helpers/shared_preferences_helper.dart';
import '../../models/organization.dart';
import '../../models/user_model.dart';
import '../../repository/firebase_repository.dart';
//import 'package:get/get.dart';

class TranscriptPage extends StatefulWidget {
  const TranscriptPage({super.key});

  @override
  State<TranscriptPage> createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  final _firebaseRepository = FirebaseRepository();
  Organization? organization;

  @override
  void initState() {
    super.initState();
  }

  Future<Organization?> _loadOrganization(String orgId) async {
    final value = await _firebaseRepository.fetchAnyOrganization(orgId);
    if (value != null) {
      setState(() {
        organization = value;
      });
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<UserModel>(
          future: getUserModel(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Text('Loading...');
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  UserModel userModel = snapshot.data as UserModel;

                  if (organization == null) {
                    _loadOrganization(userModel.orgId);
                    return const Text('Loading organization...');
                  }

                  return Expanded(
                    child: ListView(
                      children: [
                        TranscriptList(
                          userModel: userModel,
                          organization: organization!,
                        ),
                      ],
                    ),
                  );
                }
            }
          },
        ),
      ],
    );
  }
}
