import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';

import '../../services/database_services.dart';

// This class handles the Page to edit the About Me Section of the User Profile.
class EditDescriptionFormPage extends StatefulWidget {
  const EditDescriptionFormPage({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  State<EditDescriptionFormPage> createState() =>
      _EditDescriptionFormPageState();
}

class _EditDescriptionFormPageState extends State<EditDescriptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void updateUserValue(String description) {
    widget.userProfile.bio = description;
    DatabaseServices.updateUserData(widget.userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Bio"),
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
              const SizedBox(height: 20),
              const Text(
                "Briefly tell us about you",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: TextFormField(
                    minLines: 10,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.length > 304) {
                        return 'Please describe yourself but keep it under 304 characters.';
                      }
                      return null;
                    },
                    controller: descriptionController,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        hintMaxLines: 3,
                        border: OutlineInputBorder(),
                        hintText:
                            'Write a little bit about yourself. Do you like chatting? Are you a smoker? Do you bring pets with you? Etc.'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          updateUserValue(descriptionController.text);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
