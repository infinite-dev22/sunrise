import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:toast/toast.dart';

import '../../models/account.dart';
import '../../services/database_services.dart';

class EditPhoneFormPage extends StatefulWidget {
  const EditPhoneFormPage({Key? key, required this.userProfile})
      : super(key: key);

  final UserProfile userProfile;

  @override
  State<EditPhoneFormPage> createState() => _EditPhoneFormPageState();
}

class _EditPhoneFormPageState extends State<EditPhoneFormPage> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  ToastContext toast = ToastContext();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void updateUserValue(String phone) {
    String formattedPhoneNumber = "";

    if (phone.length == 12) {
      formattedPhoneNumber = "+(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6, phone.length)}";
    } else if(phone.length == 11) {
      formattedPhoneNumber = "+${phone.substring(0, 1)} (${phone.substring(1, 4)}) ${phone.substring(4, phone.length)}";
    } else  if(phone.length == 10) {
      formattedPhoneNumber = "+${phone.substring(0, 3)} ${phone.substring(3, phone.length)}";
    }
    widget.userProfile.phoneNumber = formattedPhoneNumber;
    DatabaseServices.updateUserData(widget.userProfile);
  }

  @override
  Widget build(BuildContext context) {
    toast.init(context);
    phoneController.text = widget.userProfile.phoneNumber;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit phone number"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                width: double.infinity,
                child: Text(
                  "Your Phone Number",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        return 'Please enter your phone number';
                      } else if (isAlpha(value)) {
                        return 'Only Numbers Please';
                      } else if (value.length < 10) {
                        return 'Please enter a VALID phone number';
                      }
                      return null;
                    },
                    controller: phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.number,
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
                        if (_formKey.currentState!.validate() &&
                            isNumeric(phoneController.text)) {
                          updateUserValue(phoneController.text);
                          Toast.show("Phone number updated successfully",
                              duration: Toast.lengthLong, gravity: Toast.bottom);
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
