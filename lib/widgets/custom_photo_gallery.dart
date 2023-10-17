import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunrise/widgets/custom_image.dart';

import '../theme/color.dart';
import 'add_listing_image_item.dart';

class CustomPhotoGallery extends StatefulWidget {
  const CustomPhotoGallery({
    super.key,
  });

  static List images = List.empty(growable: true);

  @override
  State<CustomPhotoGallery> createState() => _CustomPhotoGalleryState();
}

class _CustomPhotoGalleryState extends State<CustomPhotoGallery> {
  late bool isNetwork = false;
  int _activeImage = 0;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var imageHeight = screenHeight * 0.3;

    return (CustomPhotoGallery.images.isNotEmpty)
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: CustomImage(
                  CustomPhotoGallery.images[_activeImage],
                  isNetwork: isNetwork,
                  width: double.infinity,
                  height: imageHeight,
                  isFile: true,
                  radius: 10,
                  bgColor: AppColor.darker,
                  imageFit: BoxFit.contain,
                ),
              ),
              _buildImages(),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: AddListingImageItem(
              // height: screenHeight * .5,
              width: double.infinity,
              onTap: () {
                _buildImagePicker();
              },
            ),
          );
  }

  Widget _buildImages() {
    List<Widget> lists = List.generate(
      CustomPhotoGallery.images.length,
      (index) => Padding(
        padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
        child: CustomImage(
          CustomPhotoGallery.images[index],
          isNetwork: isNetwork,
          width: 100,
          height: 100,
          radius: 10,
          isFile: true,
          bgColor: AppColor.appBgColor,
          canClose: true,
          onTap: () {
            setState(() {
              _activeImage = index;
            });
          },
          onClose: () {
            setState(() {
              CustomPhotoGallery.images.removeAt(index);
            });
          },
        ),
      ),
    );

    lists.add(AddListingImageItem(
      onTap: () {
        _buildImagePicker();
      },
    ));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 10, right: 10),
      scrollDirection: Axis.horizontal,
      child: Row(children: lists),
    );
  }

  _buildImagePicker() async {
    try {
      List<XFile>? imageFiles =
          await ImagePicker().pickMultiImage(imageQuality: 100);
      for (var imageFile in imageFiles) {
        setState(() {
          CustomPhotoGallery.images.add(File(imageFile.path));
        });
      }
      imageFiles = null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    CustomPhotoGallery.images.clear();
    isNetwork = false;
    _activeImage = 0;

    super.dispose();
  }
}
