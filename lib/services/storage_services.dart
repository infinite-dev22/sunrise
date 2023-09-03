import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sunrise/utilities/global_values.dart';
import 'package:uuid/uuid.dart';

import '../constants/constants.dart';

class StorageServices {
  static Future<String> uploadProfilePicture(String url, File imageFile) async {
    String? uniquePhotoId = const Uuid().v4();
    File image = await compressImage(uniquePhotoId, imageFile);

    if (url.isNotEmpty) {
      RegExp exp = RegExp(r'userProfile_(.*).jpg');
      uniquePhotoId = exp.firstMatch(url)?[1];
    }
    UploadTask uploadTask = storageRef
        .child('images/users/${FirebaseAuth.instance.currentUser!.uid}/userProfile_$uniquePhotoId.jpg')
        .putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static deleteProfilePicture() {
    storageRef.child("images/users/${FirebaseAuth.instance.currentUser!.uid}").delete();
  }

  static Future<String> uploadListingImage(File imageFile) async {
    String uniquePhotoId = const Uuid().v4();
    File image = await compressImage(uniquePhotoId, imageFile);

    UploadTask uploadTask = storageRef
        .child('images/listings/${FirebaseAuth.instance.currentUser!.uid}/listing_$uniquePhotoId.jpg')
        .putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<List<String>> uploadListingImages(List images) async {
    var imageUrls =
        await Future.wait(images.map((image) => uploadListingImage(image)));
    return imageUrls;
  }

  static Future<File> compressImage(String photoId, File image) async {
    final tempDirection = await getTemporaryDirectory();
    final path = tempDirection.path;

    XFile? compressedImageXFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 55,
    );

    File compressedImage = File(compressedImageXFile!.path);
    return compressedImage;
  }
}
