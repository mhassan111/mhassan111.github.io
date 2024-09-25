import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x51/models/organization.dart';
import 'package:x51/models/user_model.dart';

import '../../constants/constants.dart';
import '../../constants/controllers.dart';
import '../../constants/style.dart';
import '../../controllers/register_controller.dart';
import '../../providers/users/get_all_users_provider.dart';
import '../../repository/firebase_repository.dart';
import '../../utils/utils.dart';
import '../../widgets/Error.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/loader.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  final Organization? organization;

  const AddUserScreen({required this.organization, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddUserScreenState();
  }
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  final RegisterController registerController = Get.put(RegisterController());
  final FocusNode passwordFocus = FocusNode();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();

  bool isLoginScreen = true;
  bool isEditingEmail = false;
  bool isEditingPassword = false;
  bool isEditingUsername = false;
  bool isRegistering = false;
  bool isLoggingIn = false;
  bool passwordIsVisible = false;

  String? validateEmail(String value) {
    value = value.trim();
    if (registerController.emailController.text.isNotEmpty) {
      if (value.isEmpty) {
        return 'Email can\'t be empty';
      } else if (!value.contains(RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
        return 'Enter a correct email address';
      }
    }
    return null;
  }

  String? validatePassword(String value) {
    value = value.trim();
    if (registerController.passwordController.text.isNotEmpty) {
      if (value.isEmpty) {
        return 'Password can\'t be empty';
      } else if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
    }
    return null;
  }

  String? validateUsername(String value) {
    value = value.trim();
    if (registerController.usernameController!.text.isNotEmpty) {
      if (value.isEmpty) {
        return 'Username can\'t be empty';
      } else if (value.length < 6) {
        return 'Username must be at least 6 characters';
      }
    }
    return null;
  }

  bool isLoading = false;
  List<UserModel> users = [];
  List<UserModel> selectedUsers = [];

  List<UserModel> filteredUsers = [];
  UserModel? selectedUser;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    isLoading = false;
    isRegistering = false;
    filteredUsers = users; // Initial list to display all users
    selectedUser = widget.organization?.admin;
    registerController.usernameController.text = '';
    registerController.passwordController.text = '';
    registerController.emailController.text = '';
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      List<UserModel> mUsers = users
          .where(
              (user) => user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredUsers = mUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(getAllUsersProvider);
    String title =
        "Add New ${widget.organization?.name ?? "Organization"} User";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Row(
            children: [
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go back'),
                ),
              ),
            ],
          )
        ],
      ),
      body: Stack(children: [
        if (isLoading)
          Container(
            color: Colors.transparent,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        userList.when(
          data: (usersList) {
            // First time loading
            if (users.isEmpty) {
              filteredUsers = usersList.toList();
            }
            users = usersList.toList();

            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text("Add new user",
                            style: GoogleFonts.roboto(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        CustomText(
                          text: "",
                          color: lightGray,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      focusNode: usernameFocus,
                      controller: registerController.usernameController,
                      onChanged: (value) {
                        setState(() {
                          isEditingUsername = true;
                        });
                      },
                      decoration: InputDecoration(
                          focusColor: active,
                          hoverColor: active,
                          labelText: "Username",
                          hintText: "jdoe123",
                          errorText: isEditingUsername
                              ? validateUsername(
                                  registerController.usernameController!.text)
                              : null,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      focusNode: emailFocus,
                      controller: registerController.emailController,
                      onChanged: (value) {
                        setState(() {
                          isEditingEmail = true;
                        });
                      },
                      decoration: InputDecoration(
                          focusColor: active,
                          hoverColor: active,
                          labelText: "Email",
                          hintText: "abc@domain.com",
                          errorText: isEditingEmail
                              ? validateEmail(
                                  registerController.emailController.text)
                              : null,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      focusNode: passwordFocus,
                      controller: registerController.passwordController,
                      onChanged: (value) {
                        setState(() {
                          isEditingPassword = true;
                        });
                      },
                      obscureText: !passwordIsVisible,
                      decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  passwordIsVisible = !passwordIsVisible;
                                });
                              },
                              child: Icon(
                                passwordIsVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: lightGray,
                              ),
                            ),
                          ),
                          labelText: "Password",
                          hintText: "123456",
                          errorText: isEditingPassword
                              ? validatePassword(
                                  registerController.passwordController.text)
                              : null,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                        onTap: () async {
                          setState(() {
                            isRegistering = true;
                          });

                          if (registerController.emailController.text.isEmpty ||
                              registerController
                                  .passwordController.text.isEmpty ||
                              registerController
                                  .usernameController.text.isEmpty) {
                            Utils.showCustomSnackBar(
                                context, "Please fill all the fields!");
                            setState(() {
                              isRegistering = false;
                            });
                            return;
                          }

                          //show snackbar if the fields are not valid and stop execution
                          if (validateEmail(registerController
                                      .emailController.text) !=
                                  null ||
                              validatePassword(registerController
                                      .passwordController.text) !=
                                  null ||
                              validateUsername(registerController
                                      .usernameController!.text) !=
                                  null) {
                            Utils.showCustomSnackBar(
                              context,
                              "Please input valid data!",
                            );
                            setState(() {
                              isRegistering = false;
                            });
                            return;
                          }

                          _firebaseRepository
                              .registerNewUser(
                                  registerController.usernameController.text,
                                  registerController.emailController.text,
                                  registerController.passwordController.text,
                                  widget.organization!)
                              .then((value) {
                            setState(() {
                              isRegistering = false;
                            });
                            if (value.isNotEmpty) {
                              Utils.showSuccessSnackBar(value);
                              if (value == Constants.registerOk) {
                                Navigator.pop(context);
                                // menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
                                // Get.offAllNamed(AppRoutes.homeRoute);
                              }
                            } else {
                              Utils.showErrorSnackBar("Error! Try Again");
                            }
                          }).onError((error, stackTrace) {
                            setState(() {
                              isRegistering = false;
                            });
                            Utils.showErrorSnackBar(error.toString());
                          });
                        },
                        child: Obx(
                          () => Container(
                            decoration: BoxDecoration(
                                color: active,
                                borderRadius: BorderRadius.circular(20)),
                            alignment: Alignment.center,
                            width: double.maxFinite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child:
                                isRegistering || firebaseController.isLoading()
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const CustomText(
                                        text: "Add user",
                                        color: Colors.white,
                                      ),
                          ),
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            return ErrorText(error: error.toString());
          },
          loading: () {
            return const Loader();
          },
        ),
      ]),
    );
  }

// void _registerUser() {
//   _firebaseRepository
//       .registerUser(userName, email, password)
//       .then((value) {
//     loading.value = false;
//     if (value.isNotEmpty) {
//       Utils.showSuccessSnackBar(value);
//       if (value == Constants.registerOk) {
//         menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
//         Get.offAllNamed(AppRoutes.homeRoute);
//       }
//     } else {
//       Utils.showErrorSnackBar("Error! Try Again");
//     }
//   }).onError((error, stackTrace) {
//     loading.value = false;
//     Utils.showErrorSnackBar(error.toString());
//   });
// }
}
