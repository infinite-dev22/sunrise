import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/screens/welcome.dart';
import 'package:toast/toast.dart';

import '../theme/color.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.email});

  final String email;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ToastContext toast = ToastContext();

  // text editing controllers
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  final double _sigmaX = 5;

  // from 0-10
  final double _sigmaY = 5;

  // from 0-10
  final double _opacity = 0.2;

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Log in",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: _sigmaX, sigmaY: _sigmaY),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, top: 10, right: 20),
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 0, 0, 1)
                                        .withOpacity(_opacity),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30))),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Form(
                                  key: _formKey,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
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
                                            if (!_isLoading)
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    "Authenticate user with email",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    )),
                                                const SizedBox(height: 5),
                                                Text(widget.email,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 10),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.04),
                                              AuthPasswordTextField(
                                                controller: passwordController,
                                                hintText: 'Password',
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.03),
                                              AuthButtonAgree(
                                                text: "Continue",
                                                onTap: () {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });

                                                  FirebaseAuth.instance
                                                      .signInWithEmailAndPassword(
                                                          email: widget.email,
                                                          password:
                                                              passwordController
                                                                  .text
                                                                  .trim())
                                                      .then((value) =>
                                                          setState(() {
                                                            _isLoading = false;
                                                          }))
                                                      .catchError((error) {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });

                                                    Toast.show(
                                                        error
                                                            .toString()
                                                            .substring(error
                                                                .toString()
                                                                .indexOf("T")),
                                                        duration:
                                                            Toast.lengthLong,
                                                        gravity: Toast.bottom,
                                                        backgroundColor:
                                                            AppColor.red_700);
                                                    return error;
                                                  });
                                                },
                                              ),
                                              const SizedBox(height: 30),
                                              TextButton(
                                                  onPressed: () {
                                                    FirebaseAuth.instance
                                                        .sendPasswordResetEmail(
                                                            email: widget.email)
                                                        .then((value) {
                                                      Toast.show(
                                                          "Password reset email sent",
                                                          duration:
                                                              Toast.lengthLong,
                                                          gravity:
                                                              Toast.bottom);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const WelcomePage()));
                                                    }).onError((error,
                                                            stackTrace) {
                                                      Toast.show(
                                                          "An error occurred, Try again.",
                                                          duration:
                                                              Toast.lengthLong,
                                                          gravity:
                                                              Toast.bottom);
                                                    });
                                                  },
                                                  child: const Text(
                                                      'Forgot Password?',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              71,
                                                              233,
                                                              133),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                      textAlign:
                                                          TextAlign.start)),
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
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
