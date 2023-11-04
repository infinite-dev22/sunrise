import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../constants/constants.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_textfield.dart';
import 'detail.dart';

class Signup extends StatefulWidget {
  const Signup({super.key, this.email});

  final String? email;

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final ToastContext toast = ToastContext();

  // text editing controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final double _sigmaX = 5; // from 0-10
  final double _sigmaY = 5; // from 0-10
  final double _opacity = 0.2;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // sign user in method
  void signUserIn() {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Toast.show("Passwords do not match",
            duration: Toast.lengthLong, gravity: Toast.bottom);
        return;
      }

      if (usernameController.text.trim().isEmpty) {
        Toast.show("User name is required",
            duration: Toast.lengthLong, gravity: Toast.bottom);
        return;
      }

      if (EmailValidator.validate(emailController.text.trim())) {
        setState(() {
          _isLoading = true;
        });
        userName = usernameController.text;
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .then((userCredential) async {
          setState(() {
            _isLoading = false;
          });
        }).onError((error, stackTrace) {
          setState(() {
            _isLoading = false;
          });

          Toast.show("An Error occurred",
              duration: Toast.lengthLong, gravity: Toast.bottom);
          print('$error\n$stackTrace');
        });
      } else {
        Toast.show("Email not valid",
            duration: Toast.lengthLong, gravity: Toast.bottom);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    toast.init(context);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/auth_back.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ClipRect(
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 20, 20),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 0, 0, 1)
                                .withOpacity(_opacity),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30))),
                        width: MediaQuery.of(context).size.width * 0.9,
                        // height: MediaQuery.of(context).size.height * 0.5,
                        child: Form(
                          key: _formKey,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_isLoading)
                                          const Row(
                                            children: [
                                              SizedBox(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color.fromARGB(
                                                      255, 71, 233, 133),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        (widget.email != null)
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, top: 10),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: <TextSpan>[
                                                      const TextSpan(
                                                        text:
                                                            "Looks like you don't have an account.\nLet's create a one for\n",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14),
                                                      ),
                                                      TextSpan(
                                                        text: widget.email!,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 15),
                                                child: Text(
                                                    "Create a new account",
                                                    // ignore: prefer_const_constructors
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                    textAlign: TextAlign.start),
                                              )
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      AuthTextField(
                                        controller: usernameController,
                                        hintText: 'Username',
                                        obscureText: false,
                                      ),
                                      const SizedBox(height: 10),
                                      AuthTextField(
                                        controller: emailController,
                                        hintText: 'Email',
                                        obscureText: false,
                                        isEmail: true,
                                      ),
                                      const SizedBox(height: 10),
                                      AuthPasswordTextField(
                                        controller: passwordController,
                                        hintText: 'Password',
                                      ),
                                      const SizedBox(height: 10),
                                      AuthPasswordTextField(
                                        controller: confirmPasswordController,
                                        hintText: 'Confirm password',
                                      ),
                                      const SizedBox(height: 20),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: '',
                                              children: <TextSpan>[
                                                const TextSpan(
                                                  text:
                                                      'By selecting Agree & Continue below, I agree to our ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'Terms of Service and Privacy Policy',
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () =>
                                                            Navigator.push(
                                                                context,
                                                                CupertinoPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const DetailPage(
                                                                    showingContent:
                                                                        'Privacy Policy',
                                                                  ),
                                                                )),
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 71, 233, 133),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          AuthButtonAgree(
                                            text: "Agree and Continue",
                                            onTap: () {
                                              signUserIn();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    emailController.text = widget.email ?? '';

    super.initState();
  }
}
