import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    final String path = await supabase.storage.from('images').upload(
      'users/${FirebaseAuth.instance.currentUser!.uid}/userProfile_$uniquePhotoId.jpg',
      image,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return 'https://tunzmvqqhrkcdlicefmi.supabase.co/storage/v1/object/public/$path';
  }

  static deleteProfilePicture() {
    supabase.storage.from('images').remove([(supabase.auth.currentUser!.id)]);
  }

  static Future<String> uploadListingImage(File imageFile) async {
    String uniquePhotoId = const Uuid().v4();
    File image = await compressImage(uniquePhotoId, imageFile);

    final String path = await supabase.storage.from('images').upload(
      'listings/${FirebaseAuth.instance.currentUser!.uid}/listing_$uniquePhotoId.jpg',
      image,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return 'https://tunzmvqqhrkcdlicefmi.supabase.co/storage/v1/object/public/$path';
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
