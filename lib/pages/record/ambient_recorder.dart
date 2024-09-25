import 'dart:async';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:x51/constants/constants.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/utils/utils.dart';

import '../../constants/controllers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../helpers/shared_preferences_helper.dart';
import '../../models/storage_file.dart';
import '../../models/user_model.dart';
import '../../repository/firebase_repository.dart';
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;

import '../quill/QuillEditorExample.dart';
import '../transcripts/transcripts_list.dart';

typedef _Fn = void Function();

const theSource = AudioSource.microphone;

class AmbientRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AmbientRecorder({required this.onStop, super.key});

  @override
  State<AmbientRecorder> createState() => _AmbientRecorderState();
}

class _AmbientRecorderState extends State<AmbientRecorder> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final focusNode = FocusNode();
  final focusNode2 = FocusNode();
  Codec _codec = Codec.opusWebM;
  String _mPath = 'tau_file.webm';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInitialized = false;
  bool _mRecorderIsInitialized = false;
  bool _mPlaybackReady = false;
  bool showPlayRecorder = false;
  UserModel mUserModel = UserModel.emptyUser();
  final _firebaseRepository = FirebaseRepository();
  Organization? organization;

  final RxBool isTranscriptLoading = false.obs;

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInitialized = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInitialized = true;
      });
    });

    getUserModel().then((userModel) {
      if (userModel.role == UserRole.orgUser.name) {}
    });

    firstNameController.text = "";
    firstNameController.text = "";

    showPlayRecorder = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;

    firstNameController.dispose();
    lastNameController.dispose();

    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.mp3;
      _mPath = 'tau_file.mp3';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInitialized = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInitialized = true;
  }

  void record() {
    validUserData().then((valid) {
      if (valid) {
        _mRecorder!
            .startRecorder(
          toFile: _mPath,
          codec: _codec,
          audioSource: theSource,
        )
            .then((value) {
          setState(() {});
        });
      } else {
        return;
      }
    });
  }

  Future<_Fn?> stopRecorder(BuildContext context) async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mPlaybackReady = true;
      });
      widget.onStop(_mPath);
      if (organization != null) {
        firebaseController
            .uploadFile(organization!, firstNameController.text,
                lastNameController.text, _mPath)
            .then((storageFile) {
          if (storageFile != null) {
            firstNameController.text = "";
            lastNameController.text = "";
            Utils.showSuccessSnackBar(
                "Success: File saved: ${storageFile.name}");
            isTranscriptLoading.value = true;
            Future.delayed(const Duration(seconds: 3), () {
              fetchTranscript(context, storageFile, mUserModel);
            });
            _firebaseRepository.uploadAndTrackFile(storageFile.filePath);
          } else {
            Utils.showSuccessSnackBar("Error: File not saved, try again");
          }
        });
      }
    });
    return null;
  }

  void fetchTranscript(
      BuildContext context, StorageFile storageFile, UserModel userModel) {
    isTranscriptLoading.value = true;
    storageFile.filePath = storageFile.filePath
        .replaceFirst("${userModel.orgName}/${userModel.locName}", "Summary")
        .replaceFirst(".mp3", "_summary_A.docx");

    _firebaseRepository.fetchTranscript(storageFile.filePath).then((content) {
      if (content.isNotEmpty) {
        isTranscriptLoading.value = false;
        if (isValidHtml(content) && organization != null) {
          _showEditTranscriptDialog(
              context, organization!, userModel, storageFile, content, () {});
        } else {
          Utils.showSuccessSnackBar("Invalid transcript content");
        }
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          fetchTranscript(context, storageFile, userModel);
        });
      }
    }).catchError((e) {
      Utils.showSuccessSnackBar("Error: Fetching, Go to Transcripts To Edit");
      isTranscriptLoading.value = false;
    });
  }

  void play() {
    assert(_mPlayerIsInitialized &&
        _mPlaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  Future<_Fn?> getRecorderFn(BuildContext context) async {
    if (!_mRecorderIsInitialized || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : () => stopRecorder(context);
  }

  Future<bool> validUserData() async {
    var valid = true;
    String firstName = await getStringPref(Constants.prefFirstName);
    String lastName = await getStringPref(Constants.prefFirstName);
    UserModel userModel = await getUserModel();
    // if (firstName.isEmpty || lastName.isEmpty) {
    //   valid = false;
    //   Utils.showErrorSnackBar("Please add firstName and lastName in Settings");
    // }

    if (valid && userModel.locName.isEmpty || userModel.locId.isEmpty) {
      valid = false;
      Utils.showErrorSnackBar("Please select your organization location");
    }

    if (valid && firstNameController.text.isEmpty) {
      valid = false;
      Utils.showErrorSnackBar("Please enter patient first name");
    }

    if (valid && lastNameController.text.isEmpty) {
      valid = false;
      Utils.showErrorSnackBar("Please enter patient last name");
    }

    return valid;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInitialized || !_mPlaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
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
                mUserModel = userModel;

                if (organization == null) {
                  _firebaseRepository
                      .fetchAnyOrganization(mUserModel.orgId)
                      .then((value) {
                    if (value != null) {
                      organization = value;
                    }
                  }).onError((error, stackTrace) {});
                }

                return Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Ambient Recording",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                        const Text(
                          "Ambient Recorder lets you to record the surrounding recording, please tap on Record button to start recording",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 14),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        if (userModel.locName.isNotEmpty)
                          Text(
                            "Current Location: ${userModel.locName}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        if (userModel.locName.isEmpty)
                          Text(
                            "Current Location: Not Choosed Yet",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(3),
                          height: 500,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: Colors.indigo,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              patientInfoWidget(),
                              const SizedBox(
                                height: 60,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final fn = await getRecorderFn(context);
                                        if (fn != null) fn();
                                      },
                                      //color: Colors.white,
                                      //disabledColor: Colors.grey,
                                      child: Text(
                                        _mRecorder!.isRecording
                                            ? 'Stop Recording'
                                            : 'Start Recording',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ]),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                _mRecorder!.isRecording
                                    ? 'Recording in progress'
                                    : 'Recorder is stopped',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 23),
                              ),
                            ],
                          ),
                        ),
                        if (showPlayRecorder)
                          Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(3),
                            height: 80,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              border: Border.all(
                                color: Colors.indigo,
                                width: 1,
                              ),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: getPlaybackFn(),
                                    //color: Colors.white,
                                    //disabledColor: Colors.grey,
                                    child: Text(
                                        _mPlayer!.isPlaying ? 'Stop' : 'Play'),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(_mPlayer!.isPlaying
                                      ? 'Playback in progress'
                                      : 'Player is stopped'),
                                ]),
                          ),
                        if (firebaseController.isLoading())
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Uploading file to Server...",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )
                      ],
                    ));
              }
          }
        },
      );
    }

    return Stack(
      children: [
        makeBody(),
        Obx(() {
          if (isTranscriptLoading.value) {
            return Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        "Loading transcript...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget patientInfoWidget() {
    return Column(
      children: [
        const SizedBox(
          width: 300.0,
          child: Text(
            "Enter Patient Name Before Starting Recording",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 300.0,
          child: TextFormField(
            controller: firstNameController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Enter Patient First Name',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 12),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) =>
                value != null && value.isNotEmpty ? null : 'Required',
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 300.0,
          child: TextFormField(
            controller: lastNameController,
            focusNode: focusNode2,
            decoration: const InputDecoration(
              hintText: 'Enter Patient Last Name',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 12),
            validator: (value) =>
                value != null && value.isNotEmpty ? null : 'Required',
          ),
        ),
      ],
    );
  }
}

void _showEditTranscriptDialog(
    BuildContext context,
    Organization organization,
    UserModel userModel,
    StorageFile storageFile,
    String content,
    final Function onSuccess) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return QuillEditorExample(
        organization: organization,
        context: context,
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
