// ignore_for_file: use_build_context_synchronously, avoid_print, avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x51/utils/utils.dart';

import '../../../constants/constants.dart';
import '../../../constants/controllers.dart';
import '../../../constants/style.dart';
import '../../../controllers/register_controller.dart';
import '../../../routing/app_pages.dart';
import '../../../widgets/custom_text.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usernameFocus.requestFocus();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                  Text(isLoginScreen ? "Login" : "Create your account",
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
                    text: isLoginScreen
                        ? "Welcome back to the admin panel."
                        : "Create an account to access.",
                    color: lightGray,
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              !isLoginScreen
                  ? TextField(
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
                    )
                  : const SizedBox(
                      height: 1,
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
                        ? validateEmail(registerController.emailController.text)
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
                  if (!isLoginScreen) {
                    if (registerController.emailController.text.isEmpty ||
                        registerController.passwordController.text.isEmpty ||
                        registerController.usernameController.text.isEmpty) {
                      Utils.showCustomSnackBar(
                          context, "Please fill all the fields!");
                      setState(() {
                        isRegistering = false;
                      });
                      return;
                    }

                    //show snackbar if the fields are not valid and stop execution
                    if (validateEmail(
                                registerController.emailController.text) !=
                            null ||
                        validatePassword(
                                registerController.passwordController.text) !=
                            null ||
                        validateUsername(
                                registerController.usernameController!.text) !=
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

                    try {
                      setState(() {
                        isRegistering = true;
                      });

                      ref
                          .read(authProvider)
                          .registerUser(
                              registerController.usernameController.text,
                              registerController.emailController.text,
                              registerController.passwordController.text)
                          .then((value) {
                        if (value.isNotEmpty) {
                          Utils.showSuccessSnackBar(value);
                          setState(() {
                            isRegistering = false;
                          });
                          if (value == Constants.registerOk) {
                            menuController.changeActiveItemTo(
                                AppRoutes.recordDisplayName);
                            Get.offAllNamed(AppRoutes.homeRoute);
                          }
                        } else {
                          setState(() {
                            isRegistering = false;
                          });
                          Utils.showErrorSnackBar("Error! Try Again");
                        }
                      }).onError((error, stackTrace) {
                        setState(() {
                          isRegistering = false;
                        });
                        Utils.showErrorSnackBar(error.toString());
                      });
                    } catch (e) {
                      Utils.showCustomSnackBar(
                        context,
                        "Error, please try again later!",
                      );
                    }
                  } else {

                    // registerController.emailController.text =
                    // "bode111@gmail.com";
                    // registerController.passwordController.text = '123123';

                    if (registerController.emailController.text.isEmpty ||
                        registerController.passwordController.text.isEmpty) {
                      Utils.showCustomSnackBar(
                          context, "Please fill all the fields!");
                      setState(() {
                        isLoggingIn = false;
                      });
                      return;
                    }

                    try {
                      //if we are in the login screen
                      setState(() {
                        isLoggingIn = true;
                      });

                      ref
                          .read(authProvider)
                          .signInWithEmailPassword(
                              registerController.emailController.text,
                              registerController.passwordController.text)
                          .then((value) {
                        if (value.isNotEmpty) {
                          Utils.showSuccessSnackBar(value);
                          setState(() {
                            isLoggingIn = false;
                          });
                          if (value == Constants.loginOk) {
                            menuController.changeActiveItemTo(
                                AppRoutes.recordDisplayName);
                            Get.offAllNamed(AppRoutes.homeRoute);
                          }
                        } else {
                          Utils.showErrorSnackBar("Error! Try Again");
                          setState(() {
                            isLoggingIn = false;
                          });
                        }
                      }).onError((error, stackTrace) {
                        setState(() {
                          isLoggingIn = false;
                        });
                        Utils.showErrorSnackBar(error.toString());
                      });
                    } catch (e) {
                      Utils.showCustomSnackBar(context,
                          "Error please check your credentials and try again");
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: active, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isRegistering || isLoggingIn
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : CustomText(
                          text: isLoginScreen ? "Login" : "Register",
                          color: Colors.white,
                        ),
                ),
              ),
              // const SizedBox(
              //   height: 15,
              // ),
              // RichText(
              //     text: TextSpan(children: [
              //   TextSpan(
              //     text: isLoginScreen
              //         ? "Want to create your own account?   "
              //         : "Already have an account?   ",
              //   ),
              //   TextSpan(
              //       text: isLoginScreen ? "Register! " : "Log In!",
              //       style: TextStyle(color: active),
              //       recognizer: TapGestureRecognizer()
              //         ..onTap = () {
              //           setState(() {
              //             isLoginScreen = !isLoginScreen;
              //           });
              //         })
              // ])),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 15,
              ),
              isLoginScreen
                  ? Container()
                  : const SizedBox(
                      height: 10,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    usernameFocus.dispose();
    emailFocus.dispose();
    registerController.emailController.dispose();
    registerController.usernameController.dispose();
    registerController.passwordController.dispose();
  }
}
