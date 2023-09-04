import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../../models/account.dart';
import '../../services/database_services.dart';

// This class handles the Page to edit the Email Section of the User Profile.
class EditEmailFormPage extends StatefulWidget {
  const EditEmailFormPage({Key? key, required this.userProfile})
      : super(key: key);

  final UserProfile userProfile;

  @override
  State<EditEmailFormPage> createState() => _EditEmailFormPageState();
}

class _EditEmailFormPageState extends State<EditEmailFormPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  ToastContext toast = ToastContext();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void updateUserValue(String email) {
    widget.userProfile.email = email;
    DatabaseServices.updateUserData(widget.userProfile);
  }

  @override
  Widget build(BuildContext context) {
    toast.init(context);
    emailController.text = widget.userProfile.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Email"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                width: double.infinity,
                child: Text(
                  "Your email address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 20,
                ),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: TextFormField(
                    // Handles Form Validation
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    controller: emailController,keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 320,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate() &&
                            EmailValidator.validate(emailController.text)) {
                          Toast.show("Email updated successfully",
                              duration: Toast.lengthLong, gravity: Toast.bottom);
                          updateUserValue(emailController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
