import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:html/dom.dart' as html_dom; // Alias the `html/dom.dart` import
import 'package:html/parser.dart' as html_parser;
import 'package:x51/models/organization.dart';
import 'package:x51/repository/firebase_repository.dart';
import 'package:x51/utils/utils.dart';

import '../../models/storage_file.dart';
import '../../models/user_model.dart';

class QuillEditorExample extends StatefulWidget {
  final Organization organization;
  final BuildContext context;
  final UserModel userModel;
  final StorageFile storageFile;
  final String content;
  final Function(String result) onResult;

  // Constructor with the four parameters
  QuillEditorExample({
    required this.organization,
    required this.context,
    required this.userModel,
    required this.storageFile,
    required this.content,
    required this.onResult,
  });

  @override
  _QuillEditorExampleState createState() => _QuillEditorExampleState();
}

class _QuillEditorExampleState extends State<QuillEditorExample> {
  QuillController _controller = QuillController.basic();
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  bool isLoading = false;

  // HTML content to load
  String htmlContent = """
<p><b>Patient Name:</b> Vishen</p>
<p><b>Physician Name:</b> Dr. XYZ</p>
<p><b>Date of Visit:</b> [Date of the transcript]</p>
<p><b>Chief Complaint:</b> Severe headaches for the past four days</p>
<p><b>History of Present Illness:</b></p>
<ul>
  <li><b>Duration:</b> 4 days</li>
  <li><b>Character:</b> Severe</li>
  <li><b>Associated Symptoms:</b> Stress, poor sleep</li>
  <li><b>Precipitating Factors:</b> None reported</li>
  <li><b>Alleviating Factors:</b> Partial/temporary relief with ibuprofen and aspirin</li>
  <li><b>Severity of Pain:</b> Severe enough to seek medical attention</li>
</ul>
<p><b>Past Medical History:</b> Not provided</p>
<p><b>Medication History:</b></p>
<ul>
  <li>Ibuprofen (over-the-counter)</li>
  <li>Aspirin (over-the-counter)</li>
  <li><b>Response to Medication:</b> Temporary relief for about 30 minutes</li>
</ul>
<p><b>Physical Examination:</b> [Details not provided in the transcript]</p>
<p><b>Diagnostic Evaluation:</b> Not discussed in the transcript</p>
<p><b>Assessment / Plan:</b></p>
<ol>
  <li><b>Bed Rest:</b> Advised to take complete bed rest for the next 48 hours.</li>
  <li><b>Medication:</b>
    <ul>
      <li>Two injections of Vilidin (dosage not specified in the transcript).</li>
      <li>IV therapy with 500cc fluid (type of fluid not specified).</li>
      <li>Sedation (specific medication for sedation not mentioned).</li>
    </ul>
  </li>
  <li><b>Follow-Up:</b> Continuous monitoring over the next few days.</li>
</ol>
<p><b>Additional Notes:</b> Patient should be monitored for the effectiveness of the treatment plan and any side effects or adverse reactions to medications. Further evaluation might be necessary if symptoms persist or worsen.</p>
""";

  @override
  void initState() {
    super.initState();
    loadHtmlIntoQuill(htmlContent);
  }

  void loadHtmlIntoQuill(String htmlContent) async {
    if (htmlContent.isEmpty) {
      print("HTML content is empty.");
      return; // Return early if content is empty
    }

    final delta = await _htmlToDelta(htmlContent);
    // If the delta is still empty after parsing, return early
    if (delta.isEmpty) {
      print("Converted Delta is empty.");
      return;
    }

    // Use setState to trigger a rebuild and update the controller
    setState(() {
      _controller = QuillController(
        document: Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    });
  }

  Future<Delta> _htmlToDelta(String html) async {
    final document =
        html_parser.parse(html); // Parse HTML using the html package
    final delta = Delta();

    // Ensure the document body is not null
    if (document.body == null) {
      print("Invalid HTML: No body tag found.");
      return delta; // Return an empty delta if the body tag is missing
    }

    // Traverse the HTML document and convert it to Delta
    _parseElement(document.body!, delta);

    // Ensure that the last inserted data ends with a newline
    if (delta.isNotEmpty) {
      final lastOp = delta.last;
      if (lastOp.isInsert) {
        final insertedData = lastOp.data;
        if (insertedData is String && !insertedData.endsWith('\n')) {
          delta.insert('\n'); // Add newline if not already present
        }
      }
    }

    return delta;
  }

  void _parseElement(html_dom.Element element, Delta delta) {
    // Loop through child elements and text nodes
    for (var child in element.nodes) {
      if (child is html_dom.Text) {
        // Add the text to the delta with corresponding attributes
        delta.insert(child.text, _getAttributes(element));
      } else if (child is html_dom.Element) {
        // Handle HTML tags and process accordingly
        _parseElement(child, delta);
      }
    }
  }

  Map<String, dynamic> _getAttributes(html_dom.Element element) {
    // Map HTML tags to Quill Delta attributes
    final attributes = <String, dynamic>{};

    if (element.localName == 'b') {
      attributes['bold'] = true;
    } else if (element.localName == 'i') {
      attributes['italic'] = true;
    } else if (element.localName == 'u') {
      attributes['underline'] = true;
    } else if (element.localName == 'strike') {
      attributes['strike'] = true;
    } else if (element.localName == 'code') {
      attributes['inlineCode'] = true;
    } else if (element.localName == 'h1') {
      attributes['header'] = 1;
    } else if (element.localName == 'h2') {
      attributes['header'] = 2;
    } else if (element.localName == 'h3') {
      attributes['header'] = 3;
    }

    return attributes;
  }

  // Function to strip HTML tags and keep plain text
  String htmlToPlainText(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Function to get content from Quill and save it
  void saveEditedContent(
      BuildContext context, UserModel userModel, Organization org) {
    setState(() {
      isLoading = true; // Show loader
    });

    bool isSupervisor =
        org.supervisors.any((supervisor) => supervisor.id == userModel.email);
    bool isUnderSupervisor = org.supervisors
        .any((supervisor) => supervisor.userEmails.contains(userModel.email));
    String versionName = isSupervisor ? 'L' : (isUnderSupervisor ? 'B' : 'L');
    if (widget.storageFile.filePath.contains('summary_B')) {
      versionName = 'L';
    }

    final editedDelta = _controller.document.toDelta();
    String updatedHtml = _deltaToHtml(editedDelta);

    print('saveEditedContent: isSupervisor = $isSupervisor');
    print('saveEditedContent: isUnderSupervisor = $isUnderSupervisor');

    print('Edited HTML Content:\n$updatedHtml');

    _firebaseRepository
        .updateTranscriptContent(
            widget.storageFile.filePath, updatedHtml, versionName)
        .then((status) {
      setState(() {
        isLoading = false; // Hide loader
      });

      if (status != null && status.isNotEmpty) {
        if (status == 'success') {
          Utils.showSuccessSnackBar("Transcript Updated");
          widget.onResult('success');
          Navigator.of(context).pop('success');
        } else {
          Utils.showSuccessSnackBar("Failed to update");
          widget.onResult('success');
          Navigator.of(context).pop('success');
        }
      } else {
        Utils.showErrorSnackBar("Unexpected status from Firebase");
      }
    }).catchError((error) {
      setState(() {
        isLoading = false; // Hide loader on error
      });
      Utils.showErrorSnackBar("Error: $error");
    });
  }

  // Convert Delta to HTML using a custom method
  String _deltaToHtml(Delta delta) {
    StringBuffer htmlContent = StringBuffer();

    for (var op in delta.toList()) {
      if (op.isInsert) {
        final insertText = op.data;
        // Check if the inserted text has formatting
        if (op.attributes != null) {
          if (op.attributes!['bold'] == true) {
            htmlContent.write('<b>$insertText</b>');
          } else if (op.attributes!['italic'] == true) {
            htmlContent.write('<i>$insertText</i>');
          } else if (op.attributes!['underline'] == true) {
            htmlContent.write('<u>$insertText</u>');
          } else if (op.attributes!['strike'] == true) {
            htmlContent.write('<strike>$insertText</strike>');
          } else {
            htmlContent.write(insertText); // Normal text without formatting
          }
        } else {
          htmlContent.write(insertText);
        }
      }
    }

    return htmlContent.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storageFile.name),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            saveEditedContent(context, widget.userModel, widget.organization);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  multiRowsDisplay: true,
                  showUndo: true,
                  showRedo: true,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showInlineCode: true,
                  showCodeBlock: true,
                  showQuote: true,
                ),
              ),
              Expanded(
                flex: 2,
                child: QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    controller: _controller,
                    autoFocus: true,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    saveEditedContent(
                        context, widget.userModel, widget.organization);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),

          // ✅ Loader Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
