import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/models/storage_file.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/pages/quill/QuillEditorExample.dart';
import 'package:x51/repository/firebase_repository.dart';
import 'package:x51/widgets/Error.dart';

import '../../../widgets/custom_text.dart';
import '../../../widgets/loader.dart';
import '../../providers/transcripts/transcripts_file_provider.dart';
import 'package:html/parser.dart' as html_parser;

import '../../providers/users/get_all_users_provider.dart';

class TranscriptList extends ConsumerStatefulWidget {
  final UserModel userModel;
  final Organization organization;

  const TranscriptList(
      {required this.userModel, required this.organization, super.key});

  @override
  ConsumerState<TranscriptList> createState() => _TranscriptListState();
}

class _TranscriptListState extends ConsumerState<TranscriptList> {
  bool _didFetchTranscripts = false;
  int? _previousUserCount;
  Iterable<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(getAllUsersProvider);
    final transcriptsState = ref.watch(transcriptsNotifierProvider);

    List<DataColumn> columns = const [
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Edit Transcript')),
    ];

    return userList.when(
      data: (users) {
        // if (widget.userModel.role == UserRole.orgAdmin.name) {
        filteredUsers = users.where((it) => it.orgId == widget.userModel.orgId);
        // }
        final int currentCount = filteredUsers.length;

        if ((_previousUserCount != currentCount) && filteredUsers.isNotEmpty) {
          _previousUserCount = currentCount;
          _didFetchTranscripts = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(transcriptsNotifierProvider.notifier).fetchTranscripts(
                  filteredUsers,
                  widget.userModel.orgId,
                  widget.userModel.orgName,
                  widget.userModel.locName,
                  widget.userModel.email,
                  widget.userModel.users,
                  widget.organization,
                );
          });
        }

        // Users are loaded, now check transcripts
        return transcriptsState.when(
          data: (transcriptList) {
            final data = TranscriptsData(
              context,
              filteredUsers,
              transcriptList,
              widget.userModel,
              widget.organization,
              () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref
                      .read(transcriptsNotifierProvider.notifier)
                      .fetchTranscripts(
                        filteredUsers,
                        widget.userModel.orgId,
                        widget.userModel.orgName,
                        widget.userModel.locName,
                        widget.userModel.email,
                        widget.userModel.users,
                        widget.organization,
                      );
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {});
                });
              },
            );

            return PaginatedDataTable(
              columns: columns,
              source: data,
              columnSpacing: 50,
              horizontalMargin: 10,
              rowsPerPage: 10,
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
      },
      error: (error, stackTrace) => ErrorText(error: error.toString()),
      loading: () => const Loader(),
    );
  }
}

class TranscriptsData extends DataTableSource {
  List<Map<String, dynamic>> data = [];
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  TranscriptsData(
      BuildContext context,
      Iterable<UserModel> usersList,
      Iterable<StorageFile> transcriptList,
      UserModel userModel,
      Organization org,
      final Function onSuccess) {
    for (var storageFile in transcriptList) {
      data.add({
        'Name': storageFile.name,
        // 'Date': storageFile.name, // Replace with actual date if available
        'actions': {
          'edit': () {
            print('Edit');
            _firebaseRepository
                .fetchTranscript(storageFile.filePath)
                .then((content) {
              if (content.isNotEmpty) {
                if (isValidHtml(content)) {
                  _showEditTranscriptDialog(
                      context, org, userModel, storageFile, content, () {
                    onSuccess();
                  });
                }
              }
            });
          },
        },
      });
    }
  }

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(CustomText(text: data[index]['Name'])),
      // DataCell(CustomText(text: data[index]['Date'])),
      DataCell(Center(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
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

bool isValidHtml(String html) {
  try {
    // Try to parse the HTML
    final document = html_parser.parse(html);

    // Check if the document is empty or has invalid structure
    if (document.body == null) {
      return false; // Body is missing in the HTML
    }

    // You can also add more checks, like checking if specific tags exist or if the body is malformed

    return true; // If no errors were thrown and the structure looks fine
  } catch (e) {
    // If an error is thrown while parsing, the HTML is invalid
    return false;
  }
}

void _showEditTranscriptDialog(
    BuildContext context,
    Organization org,
    UserModel userModel,
    StorageFile storageFile,
    String content,
    final Function onSuccess) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return QuillEditorExample(
        context: context,
        organization: org,
        userModel: userModel,
        storageFile: storageFile,
        content: content,
        onResult: (result) {
          if (result == 'success') {
            onSuccess();
          }
        },
      );
    },
  ));
}
