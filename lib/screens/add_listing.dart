import 'dart:io';
import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:string_validator/string_validator.dart';
import 'package:sunrise/constants/constants.dart';
import 'package:sunrise/main.dart';
import 'package:sunrise/models/property.dart';
import 'package:sunrise/screens/profile.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/widgets/wide_button.dart';
import 'package:toast/toast.dart';

import '../models/account.dart';
import '../services/database_services.dart';
import '../services/storage_services.dart';
import '../theme/color.dart';
import '../widgets/custom_photo_gallery.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key, this.listing, this.userProfile});

  final Listing? listing;
  final UserProfile? userProfile;

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  ToastContext toast = ToastContext();

  bool _loading = false;
  late double halfScreen;
  late Listing? listing;

  bool _acValue = false;
  bool _powerValue = false;
  bool _heaterValue = false;
  bool _refrigeratorValue = false;
  bool _wifiValue = false;
  bool _tvCableValue = false;
  bool _gymValue = false;
  bool _outdoorShowerValue = false;
  bool _spaValue = false;
  bool _lawnValue = false;
  bool _dryerValue = false;
  bool _cookerValue = false;
  bool _petsValue = false;
  bool _poolValue = false;
  bool _sewageValue = false;
  bool _waterValue = false;
  bool _gasValue = false;
  bool _drainageValue = false;
  bool _roadValue = false;
  bool _isOwnerValue = false;

  final _formKey = GlobalKey<FormState>();

  final _key = GlobalKey();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearConstructedController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _kitchenController = TextEditingController();
  final _garagesController = TextEditingController();
  final _sizeController = TextEditingController();
  final _facilitiesController = TextEditingController();

  late String _currency = "";
  late String _status = "";
  late String _propertyType = "";
  late String _propertyUse = "";
  late int _likes = 0;
  late List _features = List.empty(growable: true);
  late final List _features2 = List.empty(growable: true);
  late String _sizeUnit = "";
  late List _images = List.empty(growable: true);
  late String _brokerId = FirebaseAuth.instance.currentUser!.uid;

  List images = List.empty(growable: true);

  List<String> listingType = [
    "Apartment",
    "Condo",
    "Family Home",
    "Land & Plots",
    "Office",
    "Mansion",
    "Shop",
    "Studio",
    "Villa",
  ];

  List<String> landType = [
    "Commercial",
    "Farm",
    "Industrial",
    "Mixed Use",
    "Residential",
  ];

  List<String> statuses = ["Not Available", "Sale", "Rent", "To Let"];

  List<Map<String, String>> currencies = [
    {"name": "UGX", "symbol": "UGX"},
    {"name": "USD", "symbol": "\$"},
    {"name": "EURO", "symbol": "£"}
  ];

  List<String> areaUnit = [
    "Sq Ft",
    "Sq Yd",
    "Sq miles",
    "Sq metres",
    "Acre",
    "Decimal",
    "Hectare",
  ];

  final List<MultiSelectItem<String>> _officeFeatures = [
    MultiSelectItem("Air Conditioning", "Air Conditioning"),
    MultiSelectItem("Wifi", "Wifi"),
    MultiSelectItem("Electricity", "Electricity"),
  ];

  final List<MultiSelectItem<String>> _homeBuyFeatures = [
    MultiSelectItem("Air Conditioning", "Air Conditioning"),
    MultiSelectItem("Refrigerator", "Refrigerator"),
    MultiSelectItem("Wifi", "Wifi"),
    MultiSelectItem("Outdoor Shower", "Outdoor Shower"),
    MultiSelectItem("TV Cable", "TV Cable"),
    MultiSelectItem("Gym", "Gym"),
    MultiSelectItem("Spa & Massage", "Spa & Massage"),
    MultiSelectItem("Lawn", "Lawn"),
    MultiSelectItem("Dryer", "Dryer"),
    MultiSelectItem("Swimming Pool", "Swimming Pool"),
    MultiSelectItem("Hot Water", "Hot Water"),
    MultiSelectItem("Cooker", "Cooker"),
  ];

  final List<MultiSelectItem<String>> _homeRentFeatures = [
    MultiSelectItem("Air Conditioning", "Air Conditioning"),
    MultiSelectItem("Refrigerator", "Refrigerator"),
    MultiSelectItem("Wifi", "Wifi"),
    MultiSelectItem("Outdoor Shower", "Outdoor Shower"),
    MultiSelectItem("TV Cable", "TV Cable"),
    MultiSelectItem("Gym", "Gym"),
    MultiSelectItem("Spa & Massage", "Spa & Massage"),
    MultiSelectItem("Lawn", "Lawn"),
    MultiSelectItem("Dryer", "Dryer"),
    MultiSelectItem("Swimming Pool", "Swimming Pool"),
    MultiSelectItem("Hot Water", "Hot Water"),
    MultiSelectItem("Cooker", "Cooker"),
    MultiSelectItem("Pets", "Pets"),
  ];

  final List<MultiSelectItem<String>> _landFeatures = [
    MultiSelectItem("Electricity", "Electricity"),
    MultiSelectItem("Sewage", "Sewage"),
    MultiSelectItem("Piped Water", "Piped Water"),
    MultiSelectItem("Gas Supply", "Gas Supply"),
    MultiSelectItem("Water Drainage", "Water Drainage"),
    MultiSelectItem("Access Road", "Access Road"),
  ];

  @override
  Widget build(BuildContext context) {
    toast.init(context);
    var screenWidth = MediaQuery.of(context).size.width;
    halfScreen = screenWidth * 0.5;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: AppColor.appBgColor,
          pinned: true,
          snap: true,
          floating: true,
          title: _buildHeader(),
        ),
        SliverToBoxAdapter(
          child: _buildBody(),
        ),
      ],
    );
  }

  _fillInData() async {
    if (widget.listing != null) {
      _nameController.text = widget.listing!.name;
      _locationController.text = widget.listing!.location;
      _priceController.text = widget.listing!.priceNormal;
      _currency = widget.listing!.currency;
      _yearConstructedController.text = widget.listing!.yearConstructed;
      _descriptionController.text = widget.listing!.description;
      _bedroomsController.text = widget.listing!.bedrooms;
      _bathroomsController.text = widget.listing!.bathrooms;
      _kitchenController.text = widget.listing!.kitchens;
      _garagesController.text = widget.listing!.garages;
      _sizeController.text = widget.listing!.size;
      _facilitiesController.text = widget.listing!.features2
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '');
      _currency = widget.listing!.currency;
      _status = widget.listing!.status;
      _propertyType = widget.listing!.propertyType;
      _propertyUse = widget.listing!.propertyUse;
      _likes = widget.listing!.likes;
      _features = widget.listing!.features2;
      _sizeUnit = widget.listing!.sizeUnit;
      _brokerId = FirebaseAuth.instance.currentUser!.uid;

      _isOwnerValue =
          (widget.listing!.isPropertyOwner == "Owner" ? true : false);

      for (String imageUrl in widget.listing!.images) {
        File? image = await urlToFile(imageUrl);
        images.add(image);
      }

      _key.currentState?.setState(() {
        CustomPhotoGallery.images.addAll(images);
      });
      _images.addAll(images);
    }
  }

  _buildHeader() {
    return const Column(
      children: [
        Text(
          "Add Listing",
          style: TextStyle(
            color: AppColor.darker,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  _numberFormat(String number) {
    var formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 2,
      symbol: '',
    ).format(double.parse(number.replaceAll(',', '')));
    return formattedNumber;
  }

  _buildBody() {
    return Material(
      color: AppColor.appBgColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            CustomPhotoGallery(
              key: _key,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: _formKey,
                child: _buildForm(),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  _buildForm() {
    return Column(
      children: [
        _buildTextField("Name", 25, _nameController),
        _textFieldWithUnit(
            "Price", "Currency", currencies, 15, _currency, _priceController,
            (dropDownValue) {
          _currency = dropDownValue!;
        }),
        _textFieldWithUnit(
            "Size", "Unit", areaUnit, 6, _sizeUnit, _sizeController,
            (dropDownValue) {
          _sizeUnit = dropDownValue!;
        }),
        _dropdownMenuEntries("Property Type", listingType, _propertyType,
            (value) {
          setState(() {
            _propertyType = value!;
          });
        }),
        const SizedBox(height: 20),
        if (_propertyType == "Land & Plots")
          _dropdownMenuEntries("Property Use", landType, _propertyUse, (value) {
            _propertyUse = value!;
          }),
        if (_propertyType == "Land & Plots") const SizedBox(height: 20),
        _textFieldWithAction(
            "Location", 20, Icons.location_on, () {}, _locationController),
        if (_propertyType != "Land & Plots")
          _numberField("Year Constructed", 4, _yearConstructedController),
        if (_propertyType != "Land & Plots") const SizedBox(height: 20),
        _dropdownMenuEntries("Status", statuses.toList(), _status, (value) {
          setState(() {
            _status = value!;
          });
        }),
        if (_propertyType != "Land & Plots" &&
            _propertyType != "Office" &&
            _propertyType != "Shop")
          _buildFeatures(),
        const SizedBox(height: 20),
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              labelText: "Facilities"),
          onTap: () => _showMultiSelect(context),
          minLines: 1,
          maxLines: 10,
          controller: _facilitiesController,
        ),
        const SizedBox(height: 20),
        _textArea("Description", _descriptionController),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: _isOwnerValue,
          onChanged: (value) {
            setState(() {
              _isOwnerValue = value!;
            });
          },
          title: const Text("Property Owner"),
        ),
        const SizedBox(height: 20),
        _formButtons(),
        const SizedBox(height: 20),
      ],
    );
  }

  _dropdownMenuEntries(String placeHolder, List list, String value,
      Function(String?) onChanged) {
    return (value.isNotEmpty)
        ? DropdownButtonFormField2<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              // Add Horizontal padding using menuItemStyleData.padding so it matches
              // the menu padding when button's width is not specified.
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              // Add more decoration..
            ),
            hint: Text(
              placeHolder,
              style: const TextStyle(fontSize: 14),
            ),
            items: (list is List<Map<String, String>>)
                ? List.generate(
                    currencies.length,
                    (index) => DropdownMenuItem<String>(
                      value: currencies[index]["symbol"],
                      child: Text(
                        currencies[index]["name"]!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ).toList()
                : list
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select $placeHolder.';
              }
              return null;
            },
            onChanged: onChanged,
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          )
        : DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              // Add Horizontal padding using menuItemStyleData.padding so it matches
              // the menu padding when button's width is not specified.
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              // Add more decoration..
            ),
            hint: Text(
              placeHolder,
              style: const TextStyle(fontSize: 14),
            ),
            items: (list is List<Map<String, String>>)
                ? List.generate(
                    currencies.length,
                    (index) => DropdownMenuItem<String>(
                      value: currencies[index]["symbol"],
                      child: Text(
                        currencies[index]["name"]!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ).toList()
                : list
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select $placeHolder.';
              }
              return null;
            },
            onChanged: onChanged,
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          );
  }

  _buildTextField(String label, maxLength, TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          maxLength: maxLength,
          decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.only(left: 20),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              labelText: label),
          // Handles Form Validation
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label can\'t be empty.';
            }
            return null;
          },
          controller: controller,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _textFieldWithUnit(
      String label,
      String unitFieldLabel,
      List units,
      maxLength,
      value,
      TextEditingController controller,
      ValueChanged<String?> onDropdownChanged) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _maskedNumberField(label, maxLength, controller),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 130,
              child: _dropdownMenuEntries(
                  unitFieldLabel, units, value, onDropdownChanged),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _textFieldWithAction(String label, maxLength, IconData icon,
      Function()? onPressed, TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.only(left: 20),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            labelText: label,
            suffixIcon: IconButton(
              onPressed: onPressed,
              icon: Icon(icon),
            ),
          ),
          // Handles Form Validation
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label can\'t be empty.';
            }
            return null;
          },
          controller: controller,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _maskedNumberField(
      String label, maxLength, TextEditingController controller) {
    return TextFormField(
      maxLength: maxLength,

      decoration: InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.only(left: 20),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          labelText: label),
      keyboardType: TextInputType.number,
      controller: controller,
      // Handles Form Validation
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label can\'t be empty.';
        } else if (isAlpha(value)) {
          return 'Only Numbers Please';
        }
        return null;
      },
      inputFormatters: [
        ThousandsFormatter(
          formatter: NumberFormat.decimalPattern(Intl.defaultLocale),
          allowFraction: true,
        )
      ],
    );
  }

  _numberField(String label, maxLength, TextEditingController controller) {
    return TextFormField(
      maxLength: maxLength,
      decoration: InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.only(left: 20),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          labelText: label),
      keyboardType: TextInputType.number,
      controller: controller,
      // Handles Form Validation
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label can\'t be empty.';
        } else if (isAlpha(value)) {
          return 'Only Numbers Please';
        }
        return null;
      },
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  _textArea(String label, TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              labelText: label),
          keyboardType: TextInputType.multiline,
          maxLines: 6,
          // Handles Form Validation
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label can\'t be empty.';
            }
            return null;
          },
          controller: controller,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _formButtons() {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.red_700),
          onPressed: () => _resetScreen(),
          child: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColor.appBgColor),
              SizedBox(
                width: 10,
              ),
              Text("Clear",
                  style: TextStyle(fontSize: 13, color: AppColor.appBgColor)),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.green_700),
          onPressed: () {
            if (widget.userProfile!.phoneNumber.isEmpty ||
                widget.userProfile!.name.isEmpty) {
              Toast.show("Add your Phone number and Name to continue",
                  duration: Toast.lengthLong, gravity: Toast.bottom);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    ProfilePage(userProfile: widget.userProfile!),
              ));
              return;
            }
            if (CustomPhotoGallery.images.isEmpty) {
              Toast.show("No images selected",
                  duration: Toast.lengthLong, gravity: Toast.bottom);
              return;
            }
            if (CustomPhotoGallery.images.length < 3) {
              Toast.show("Please select at least 3 images",
                  duration: Toast.lengthLong, gravity: Toast.bottom);
              return;
            }
            if (_formKey.currentState!.validate() && _propertyType.isNotEmpty ||
                (_propertyType.isNotEmpty && _propertyUse.isNotEmpty) &&
                    _status.isNotEmpty &&
                    CustomPhotoGallery.images.isNotEmpty &&
                    CustomPhotoGallery.images.length > 2) {
              (widget.listing != null)
                  ? _uploadListingAd(
                      widget.listing!.featured, widget.listing!.featureTime, 0)
                  : _buildAddFeaturedDialog();
            }
          },
          child: Row(
            children: [
              const Icon(Icons.check, color: AppColor.appBgColor),
              const SizedBox(
                width: 10,
              ),
              Text(
                (widget.listing != null) ? "Update" : "Next",
                style:
                    const TextStyle(fontSize: 13, color: AppColor.appBgColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildFeatures() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _numberField("Bedrooms", 4, _bedroomsController),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _numberField("Bathrooms", 4, _bathroomsController),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _numberField("Kitchens", 4, _kitchenController),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _numberField("Garages", 4, _garagesController),
            ),
          ],
        ),
      ],
    );
  }

  _uploadListing(bool feature, int time) {
    for (var feature in _features) {
      _setFeature(feature);
    }

    listing = Listing(
        userId: _brokerId,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        price: (_status == "Rent" || _status == "To Let")
            ? "${_numberFormat(_priceController.text.trim())}/month"
            : "${_numberFormat(_priceController.text.trim())}",
        priceNormal: _priceController.text.trim(),
        bedrooms: _bedroomsController.text,
        bathrooms: _bathroomsController.text,
        kitchens: _kitchenController.text,
        garages: _garagesController.text,
        sizeUnit: _sizeUnit,
        size: _sizeController.text,
        currency: _currency,
        status: _status,
        propertyType: _propertyType,
        propertyUse: _propertyUse,
        yearConstructed: _yearConstructedController.text.trim(),
        description: _descriptionController.text.trim(),
        likes: _likes,
        featureTime: time,
        featured: feature,
        show: true,
        isPropertyOwner: _getPropertyOwner(),
        features2: _features2,
        features: (_propertyType == "Shop" || _propertyType == "Office")
            ? [
                {"name": "Air conditioning", "value": _acValue},
                {
                  "name": "Electricity",
                  "value": _powerValue,
                  "icon": "electricity"
                },
                {
                  "quantity": _sizeController.text,
                  "name": _sizeUnit,
                  "icon": "rulerCombined"
                },
              ]
            : [
                {
                  "quantity": _bedroomsController.text,
                  "name": "Bedrooms",
                  "icon": "bed"
                },
                {
                  "quantity": _bathroomsController.text,
                  "name": "Bathrooms",
                  "icon": "bathtub_outlined"
                },
                {
                  "quantity": _kitchenController.text,
                  "name": "Kitchens",
                  "icon": "kitchen"
                },
                {
                  "quantity": _garagesController.text,
                  "name": "Garages",
                  "icon": "garage"
                },
                {
                  "quantity": _sizeController.text,
                  "name": _sizeUnit,
                  "icon": "rulerCombined"
                },
                {"name": "Wifi", "value": _wifiValue, "icon": "wifi"},
                {
                  "name": "Hot Water",
                  "value": _heaterValue,
                  "icon": "hotTubPerson"
                },
                {"name": "TV Cable", "value": _tvCableValue, "icon": "tv"},
                {"name": "Gym", "value": _gymValue, "icon": "dumbbell"},
                {
                  "name": "Swimming Pool",
                  "value": _poolValue,
                  "icon": "swimmingPool"
                },
                {
                  "name": "Electricity",
                  "value": _powerValue,
                  "icon": "electricity"
                },
                {"name": "Pets", "value": _petsValue, "icon": "dog"},
                {"name": "Outdoor Shower", "value": _outdoorShowerValue},
                {"name": "Spa & Massage", "value": _spaValue},
                {"name": "Lawn", "value": _lawnValue},
                {"name": "Dryer", "value": _dryerValue},
                {"name": "Cooker", "value": _cookerValue},
                {"name": "Air conditioning", "value": _acValue},
                {"name": "Sewage", "value": _sewageValue},
                {"name": "Piped Water", "value": _waterValue},
                {"name": "Gas Supply", "value": _gasValue},
                {"name": "Water Drainage", "value": _drainageValue},
                {"name": "Access Road", "value": _roadValue},
                {"name": "Refrigerator", "value": _refrigeratorValue},
              ],
        images: _images);
    if (widget.listing != null) {
      listing!.id = widget.listing!.id;
      DatabaseServices.updateListing(listing!);
    } else {
      DatabaseServices.createListing(listing!,
          _showCompleteUploadNotification(), _showFailedUploadNotification);
    }
  }

  _resetFeatures() {
    _acValue = false;
    _powerValue = false;
    _heaterValue = false;
    _refrigeratorValue = false;
    _wifiValue = false;
    _tvCableValue = false;
    _gymValue = false;
    _outdoorShowerValue = false;
    _spaValue = false;
    _lawnValue = false;
    _dryerValue = false;
    _cookerValue = false;
    _petsValue = false;
    _poolValue = false;
  }

  _setFeature(String feature) {
    switch (feature) {
      case "Air Conditioning":
        _acValue = true;
      case "Refrigerator":
        _refrigeratorValue = true;
      case "Wifi":
        _wifiValue = true;
      case "Outdoor Shower":
        _outdoorShowerValue = true;
      case "TV Cable":
        _tvCableValue = true;
      case "Gym":
        _gymValue = true;
      case "Spa & Massage":
        _spaValue = true;
      case "Lawn":
        _lawnValue = true;
      case "Dryer":
        _dryerValue = true;
      case "Swimming Pool":
        _poolValue = true;
      case "Cooker":
        _cookerValue = true;
      case "Pets":
        _petsValue = true;
      case "Electricity":
        _powerValue = true;
      case "Hot Water":
        _heaterValue = true;
      case "Sewage":
        _sewageValue = true;
      case "Piped Water":
        _waterValue = true;
      case "Gas Supply":
        _gasValue = true;
      case "Water Drainage":
        _drainageValue = true;
      case "Access Road":
        _roadValue = true;
    }
  }

  _showProgressUploadingNotification() async {
    await NotificationController.dismissNotifications();
    await NotificationController.createNewProgressNotification();
  }

  _showCompleteUploadNotification() async {
    await NotificationController.dismissNotifications();
    await NotificationController.createNewDoneNotification();
  }

  _showFailedUploadNotification(error, stacktrace) async {
    await NotificationController.dismissNotifications();
    await NotificationController.createNewFailedNotification();
    print(error);
    return error;
  }

  _buildAddFeaturedDialog() {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Column(
        children: [
          WideButton(
            "Promote Ad \$30/month",
            color: Colors.white,
            bgColor: AppColor.green_700,
            onPressed: () {
              _promoteAdConfirmDialog(30, 30);
            },
          ),
          const SizedBox(height: 10),
          WideButton(
            "Promote Ad \$10/week",
            color: Colors.white,
            bgColor: AppColor.green_500,
            onPressed: () {
              _promoteAdConfirmDialog(10, 7);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          WideButton(
            "Post Ad",
            color: AppColor.darker,
            bgColor: Colors.white,
            onPressed: () {
              _uploadListingAd(false, 0, 0);
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  _uploadListingAd(bool feature, int time, int amount) async {
    var nav = Navigator.of(context);

    setState(() {
      _loading = true;
    });
    _loading
        ? {
            showDialog(
                barrierDismissible: false,
                builder: (ctx) {
                  return _buildProgress();
                },
                context: context),
            _showProgressUploadingNotification()
          }
        : const SizedBox.shrink();

    _images =
        await StorageServices.uploadListingImages(CustomPhotoGallery.images);
    _uploadListing(feature, time);

    if (amount > 0) {
      DatabaseServices.createAccountTransaction(
          widget.userProfile!.id, amount, "withdraw", "promote listing ad", "");
    }

    nav.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => RootApp(
                  userProfile: widget.userProfile,
                )),
        (Route<dynamic> route) => false);
    CustomPhotoGallery.images.clear();
    setState(() {
      _loading = false;
    });
    // _showCompleteUploadNotification();
  }

  _buildProgress() {
    return Container(
      color: AppColor.appBgColor,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.appBgColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .5,
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  _promoteAdConfirmDialog(int amount, int time) {
    return Alert(
      closeIcon: Container(),
      context: context,
      type: AlertType.info,
      title: "Your account is to be credited \$$amount.",
      desc: "Do you wish to continue",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: AppColor.red_700,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () async {
            int balance = await walletsRef
                .select<int>('balance')
                .eq('user_id', widget.userProfile!.id);
            if (balance >= amount) {
              _billUpload(time, amount);
            } else {
              Toast.show("Insufficient funds, top up and try again",
                  duration: Toast.lengthLong, gravity: Toast.bottom);
            }
          },
          color: AppColor.green_700,
          child: const Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _billUpload(int time, int amount) {
    setState(() {
      _loading = true;
    });
    _loading
        ? {
            showDialog(
                barrierDismissible: false,
                builder: (ctx) {
                  return _buildProgress();
                },
                context: context),
            _showProgressUploadingNotification(),
          }
        : const SizedBox.shrink();

    _uploadListingAd(true, time, amount);
  }

  _getSelection() {
    if (_propertyType == "Office" || _propertyType == "Shop") {
      return _officeFeatures;
    } else if (_propertyType == "Land & Plots") {
      return _landFeatures;
    } else {
      if (_status == "Rent") {
        return _homeRentFeatures;
      } else {
        return _homeBuyFeatures;
      }
    }
  }

  void _showMultiSelect(BuildContext context) async {
    List items = [];

    if (_facilitiesController.text.isNotEmpty) {
      items = _facilitiesController.text.split(", ").toList(growable: true);
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (ctx) {
        return MultiSelectBottomSheet(
          title: const Text(
            "Select Property Facilities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          items: _getSelection(),
          initialValue: items,
          onConfirm: (values) {
            _resetFeatures();
            _features.addAll(values);
            _features2.addAll(values);
            _features = Set.from(_features).toList();
            setState(() {
              _facilitiesController.text =
                  values.toString().replaceAll('[', '').replaceAll(']', '');
            });
          },
          maxChildSize: 0.8,
        );
      },
    );
  }

  String _getPropertyOwner() {
    if (_isOwnerValue) {
      return "Owner";
    } else {
      return "Broker";
    }
  }

  _resetScreen() {
    setState(() {
      _nameController.text = "";
      _locationController.text = "";
      _priceController.text = "";
      _yearConstructedController.text = "";
      _descriptionController.text = "";
      _bedroomsController.text = "";
      _bathroomsController.text = "";
      _kitchenController.text = "";
      _garagesController.text = "";
      _sizeController.text = "";
      _facilitiesController.text = "";

      _currency = '';
      _status = '';
      _propertyType = '';
      _likes = 0;
      _features.clear();
      _sizeUnit = '';
      _images.clear();
      _brokerId = '';

      listing = null;

      _key.currentState?.setState(() {
        CustomPhotoGallery.images.clear();
      });

      _resetFeatures();
      _features.clear();
      _images.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _yearConstructedController.dispose();
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _kitchenController.dispose();
    _garagesController.dispose();
    _sizeController.dispose();
    _facilitiesController.dispose();

    super.dispose();
  }

  Future<File> urlToFile(String imageUrl) async {
    // generate random number.
    var rng = math.Random();
    // get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
    // get temporary path from temporary directory.
    String tempPath = tempDir.path;
    // create a new file in temporary path with random file name.
    File file = File('$tempPath${rng.nextInt(100)}.png');
    // call http.get method and pass imageurl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
    // write bodybytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
    // now return the file which is created with random name in
    // temporary directory and image bytes from response is written to // that file.
    return file;
  }

  @override
  void initState() {
    _fillInData();

    super.initState();
  }
}
