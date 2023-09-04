import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'package:sunrise/services/database_services.dart';
import 'package:sunrise/services/storage_services.dart';
import 'package:sunrise/widgets/user_profile/display_image_widget.dart';
import 'package:sunrise/widgets/user_profile/edit_description.dart';
import 'package:sunrise/widgets/user_profile/edit_email.dart';
import 'package:sunrise/widgets/user_profile/edit_name.dart';
import 'package:sunrise/widgets/user_profile/edit_phone.dart';
import 'package:toast/toast.dart';

import '../models/account.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ToastContext toast = ToastContext();

  @override
  Widget build(BuildContext context) {
    toast.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your User Profile"),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Column(
      children: [
        InkWell(
            child: DisplayImage(
          imagePath: widget.userProfile.profilePicture,
          onPressed: () async {
            final image =
                await ImagePicker().pickImage(source: ImageSource.gallery);

            if (image == null) return;

            final location = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${location.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            StorageServices.deleteProfilePicture();

            String newImageUrl = await StorageServices.uploadProfilePicture(
                widget.userProfile.profilePicture, newImage);

            setState(() => widget.userProfile.profilePicture = newImageUrl);
            DatabaseServices.updateUserData(widget.userProfile);
            Toast.show("Profile picture updated successfully",
                duration: Toast.lengthLong, gravity: Toast.bottom);
          },
        )),
        buildUserInfoDisplay(
            widget.userProfile.name,
            'Name',
            EditNameFormPage(
              userProfile: widget.userProfile,
            )),
        buildUserInfoDisplay(
            widget.userProfile.phoneNumber,
            'Phone',
            EditPhoneFormPage(
              userProfile: widget.userProfile,
            )),
        buildUserInfoDisplay(
            widget.userProfile.email,
            'Email',
            EditEmailFormPage(
              userProfile: widget.userProfile,
            )),
        Expanded(
          flex: 4,
          child: buildAbout(widget.userProfile),
        )
      ],
    );
  }

  Widget buildUserInfoDisplay(String getValue, String title, Widget editPage) =>
      Container(
          padding: const EdgeInsets.only(
            top: 30,
            left: 10,
            right: 10,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "$title:",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  getValue,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              IconButton(
                onPressed: () {
                  navigateSecondPage(editPage);
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                  size: 30.0,
                ),
              ),
            ],
          ));

  Widget buildAbout(UserProfile userProfile) => Container(
      padding: const EdgeInsets.only(
        top: 30,
        left: 10,
        right: 10,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell Us About Yourself',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    navigateSecondPage(EditDescriptionFormPage(
                      userProfile: userProfile,
                    ));
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.userProfile.bio,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  navigateSecondPage(EditDescriptionFormPage(
                    userProfile: userProfile,
                  ));
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                  size: 30.0,
                ),
              ),
            ],
          ),
        ],
      ));

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }
}
