import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../services/auth_services.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_textfield.dart';
import 'detail.dart';

class Signup extends StatelessWidget {
  Signup({super.key, this.email});

  final String? email;
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

  // sign user in method
  void signUserIn() {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Toast.show("Passwords do not match",
            duration: Toast.lengthLong, gravity: Toast.bottom);
        return;
      }

      if (EmailValidator.validate(emailController.text.trim())) {
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .then((userCredential) async {
          AuthServices.createUserProfile(name: usernameController.text.trim());
        }).onError((error, stackTrace) {
          Toast.show("An Error occurred",
              duration: Toast.lengthLong, gravity: Toast.bottom);
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
    emailController.text = email ?? '';

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
                  const Text("Sign Up",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ClipRect(
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
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
                                (email != null)
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                              "Look like you don't have an account. Let's create a new account for",
                                              // ignore: prefer_const_constructors
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                              textAlign: TextAlign.start),
                                          // ignore: prefer_const_constructors
                                          Text(
                                            email!,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.start,
                                          ),
                                          const SizedBox(height: 30),
                                        ],
                                      )
                                    : const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text("Create a new account",
                                              // ignore: prefer_const_constructors
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                              textAlign: TextAlign.start),
                                          SizedBox(height: 30),
                                        ],
                                      ),
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
                                const SizedBox(height: 30),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                                fontSize: 16),
                                          ),
                                          TextSpan(
                                            text:
                                                'Terms of Service and Privacy Policy',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        const DetailPage(
                                                      showingContent:
                                                          'Privacy Policy',
                                                    ),
                                                  )),
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 71, 233, 133),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
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
}
