import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';

import '../../services/database_services.dart';

class EditNameFormPage extends StatefulWidget {
  const EditNameFormPage({Key? key, required this.userProfile})
      : super(key: key);

  final UserProfile userProfile;

  @override
  State<EditNameFormPage> createState() => EditNameFormPageState();
}

class EditNameFormPageState extends State<EditNameFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void updateUserValue(String name) {
    widget.userProfile.name = name;
    DatabaseServices.updateUserData(widget.userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Username"),
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
                  "Your Username",
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Username';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Username', border: OutlineInputBorder()),
                    controller: nameController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 330,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          updateUserValue(nameController.text.trim());
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
