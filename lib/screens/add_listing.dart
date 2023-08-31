import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:platform_local_notifications/platform_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:string_validator/string_validator.dart';
import 'package:sunrise/models/property.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/utilities/global_values.dart';
import 'package:sunrise/widgets/wide_button.dart';

import '../models/account.dart';
import '../services/database_services.dart';
import '../services/storage_services.dart';
import '../theme/color.dart';
import '../widgets/custom_image.dart';
import '../widgets/custom_photo_gallery.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key, this.listing, required this.userProfile});

  final Listing? listing;
  final UserProfile userProfile;

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  bool _loading = false;
  late double halfScreen;

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

  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _yearConstructed = TextEditingController();
  final _description = TextEditingController();
  final _bedrooms = TextEditingController();
  final _bathrooms = TextEditingController();
  final _kitchen = TextEditingController();
  final _garages = TextEditingController();
  final _size = TextEditingController();
  final _facilitiesController = TextEditingController();

  // late String _name = (widget.listing != null) ? widget.listing!.name : "";
  // late String _location =
  //     (widget.listing != null) ? widget.listing!.location : "";
  // late String _price = (widget.listing != null) ? widget.listing!.price : "";
  late String _currency =
      (widget.listing != null) ? widget.listing!.currency : "";

  late String _status = (widget.listing != null) ? widget.listing!.status : "";
  late String _propertyType =
      (widget.listing != null) ? widget.listing!.propertyType : "";

  // late String _yearConstructed =
  //     (widget.listing != null) ? widget.listing!.yearConstructed : "";
  // late String _description =
  //     (widget.listing != null) ? widget.listing!.description : "";
  late int _likes = (widget.listing != null) ? widget.listing!.likes : 0;
  late List _features = (widget.listing != null)
      ? widget.listing!.features
      : List.empty(growable: true);

  // late String _bedrooms;
  // late String _bathrooms;
  // late String _kitchen;
  // late String _garages;
  // late String _size;
  late String _sizeUnit;
  late List _images = (widget.listing != null)
      ? widget.listing!.images
      : List.empty(growable: true);
  late String _brokerId = getAuthUser()?.uid;

  List<String> listingType = [
    "Apartment",
    "Condo",
    "Family Home",
    "Office",
    "Mansion",
    "Shop",
    "Studio",
    "Villa",
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

  @override
  Widget build(BuildContext context) {
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

  _buildHeader() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
            CustomImage(
              widget.userProfile.profilePicture,
              width: 35,
              height: 35,
              trBackground: true,
              borderColor: AppColor.primary,
              radius: 10,
            ),
          ],
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomPhotoGallery(),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
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
    );
  }

  _buildForm() {
    return Column(
      children: [
        _buildTextField("Name", _name),
        _textFieldWithUnit("Price", "Currency", currencies, _price,
            (dropDownValue) {
          setState(() {
            _currency = dropDownValue!;
          });
        }),
        _dropdownMenuEntries("Property Type", listingType, (value) {
          _propertyType = value!;
          setState(() {});
        }),
        const SizedBox(height: 20),
        _textFieldWithAction("Location", Icons.location_on, () {}, _location),
        _numberField("Year Constructed", _yearConstructed),
        const SizedBox(height: 20),
        _dropdownMenuEntries("Status", statuses.toList(), (value) {
          _status = value!;
          setState(() {});
        }),
        const SizedBox(height: 20),
        _textFieldWithUnit("Size", "Unit", areaUnit, _size, (dropDownValue) {
          setState(() {
            _sizeUnit = dropDownValue!;
          });
        }),
        // (_propertyType == "Shop" || _propertyType == "Office")
        //     ? _buildWorkPlaceFeatures()
        //     : _buildHomeFeatures(),
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(left: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              labelText: "Facilities"),
          onTap: () => _showMultiSelect(context),
          minLines: 1,
          maxLines: 10,
          controller: _facilitiesController,
        ),
        const SizedBox(height: 20),
        _textArea("Description", _description),
        _formButtons(),
        const SizedBox(height: 100),
      ],
    );
  }

  _dropdownMenuEntries(
      String placeHolder, List list, Function(String?) onChanged) {
    return DropdownButtonFormField2<String>(
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

  _buildTextField(String label, TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
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
      TextEditingController controller,
      ValueChanged<String?> onDropdownChanged) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _maskedNumberField(label, controller),
              // child: TextFormField(
              //   decoration: InputDecoration(
              //       contentPadding: const EdgeInsets.only(left: 20),
              //       border: const OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(15))),
              //       labelText: label),
              //   // Handles Form Validation
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return '$label can\'t be empty.';
              //     }
              //     return null;
              //   },
              //   controller: controller,
              // ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 130,
              child: _dropdownMenuEntries(
                  unitFieldLabel, units, onDropdownChanged),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _textFieldWithAction(String label, IconData icon, Function()? onPressed,
      TextEditingController controller) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
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

  _maskedNumberField(String label, TextEditingController controller) {
    return TextFormField(
      decoration: InputDecoration(
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
        FilteringTextInputFormatter.digitsOnly,
        ThousandsFormatter()
      ],
    );
  }

  _numberField(String label, TextEditingController controller) {
    return TextFormField(
      decoration: InputDecoration(
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
          onPressed: () {},
          child: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColor.appBgColor),
              SizedBox(
                width: 10,
              ),
              Text("Cancel",
                  style: TextStyle(fontSize: 13, color: AppColor.appBgColor)),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.green_700),
          onPressed: () {
            if (_formKey.currentState!.validate() &&
                _propertyType.isNotEmpty &&
                _status.isNotEmpty &&
                CustomPhotoGallery.images.isNotEmpty) {
              _buildAddFeaturedDialog();
            } else if (CustomPhotoGallery.images.isEmpty) {
              CherryToast(
                      title: const Text(""),
                      displayTitle: false,
                      description: const Text("No images selected"),
                      icon: Icons.error,
                      themeColor: AppColor.darker,
                      toastPosition: Position.bottom,
                      animationDuration: const Duration(milliseconds: 1000),
                      autoDismiss: true)
                  .show(context);
            }
          },
          child: const Row(
            children: [
              Icon(Icons.check, color: AppColor.appBgColor),
              SizedBox(
                width: 10,
              ),
              Text(
                "Next",
                style: TextStyle(fontSize: 13, color: AppColor.appBgColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _uploadListing(bool feature) {
    for (var feature in _features) {
      _setFeature(feature);
    }

    Listing listing = Listing(
      id: '',
      userId: _brokerId,
      name: _name.text.trim(),
      location: _location.text.trim(),
      price: (_status == "Rent" || _status == "To Let")
          ? "${_numberFormat(_price.text.trim())}/month"
          : "${_numberFormat(_price.text.trim())}",
      currency: _currency,
      status: _status,
      propertyType: _propertyType,
      yearConstructed: _yearConstructed.text.trim(),
      description: _description.text.trim(),
      likes: _likes,
      featured: feature,
      features: (_propertyType == "Shop" || _propertyType == "Office")
          ? [
              {"name": "Air conditioning", "value": _acValue},
              {
                "name": "Electricity",
                "value": _powerValue,
                "icon": "electricity"
              },
              {
                "quantity": _size.text,
                "name": _sizeUnit,
                "icon": "rulerCombined"
              },
            ]
          : [
              {"quantity": _bedrooms.text, "name": "Bedrooms", "icon": "bed"},
              {
                "quantity": _bathrooms.text,
                "name": "Bathrooms",
                "icon": "bathtub_outlined"
              },
              {
                "quantity": _kitchen.text,
                "name": "Kitchens",
                "icon": "kitchen"
              },
              {"quantity": _garages.text, "name": "Garages", "icon": "garage"},
              {
                "quantity": _size.text,
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
              {"name": "Refrigerator", "value": _refrigeratorValue},
            ],
      images: _images,
      timestamp: Timestamp.fromDate(
        DateTime.now(),
      ),
    );
    DatabaseServices.createListing(listing);
  }

  _checkBox(String text, bool value, ValueChanged<bool?> onChanged) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Text(text)
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
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
    }
  }

  _showUploadListingNotification(String title, String body) async {
    await PlatformNotifier.I.showPluginNotification(
        ShowPluginNotificationModel(
            id: DateTime.now().second,
            title: title,
            body: body,
            payload: "test"),
        context);
  }

  _buildAddFeaturedDialog() {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          WideButton(
            "Promote Ad \$30/month",
            color: Colors.white,
            bgColor: AppColor.green_700,
            onPressed: () {
              _promoteAdConfirmDialog(30);
            },
          ),
          const SizedBox(height: 20),
          WideButton(
            "Promote Ad \$10/week",
            color: Colors.white,
            bgColor: AppColor.green_500,
            onPressed: () {
              _promoteAdConfirmDialog(10);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          WideButton(
            "Post Ad",
            color: AppColor.darker,
            bgColor: Colors.white,
            onPressed: () {
              _uploadListingAd(false);
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  _uploadListingAd(bool feature) async {
    var nav = Navigator.of(context);

    setState(() {
      _loading = true;
    });
    _loading
        ? {
            showDialog(
                barrierDismissible: false,
                builder: (ctx) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                context: context),
            _showUploadListingNotification(
                "Upload In Progress", "Uploading property listing...")
          }
        : const SizedBox.shrink();

    _images =
        (await StorageServices.uploadListingImages(CustomPhotoGallery.images));

    _uploadListing(feature);

    nav.pop();
    nav.push(CupertinoPageRoute(
      builder: (context) => RootApp(
        userProfile: widget.userProfile,
      ),
    ));
    CustomPhotoGallery.images.clear();
    setState(() {
      _loading = false;
    });
    _showUploadListingNotification(
        "Upload Progress", "Property listing upload complete.");
  }

  _promoteAdConfirmDialog(int amount) {
    return Alert(
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
          onPressed: () {
            setState(() {
              _loading = true;
            });
            _loading
                ? {
                    showDialog(
                        barrierDismissible: false,
                        builder: (ctx) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        context: context),
                    _showUploadListingNotification(
                        "Upload In Progress", "Uploading property listing...")
                  }
                : const SizedBox.shrink();

            _uploadListingAd(true);
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

  void _showMultiSelect(BuildContext context) async {
    List items = [];

    if (_facilitiesController.text.isNotEmpty) {
      items = _facilitiesController.text.split(", ").toList(growable: true);
      // .map((item) => MultiSelectItem(item, item))
      // .toList();
    }

    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      builder: (ctx) {
        return MultiSelectBottomSheet(
          title: const Text(
            "Select Property Facilities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          items: (_propertyType == "Office" || _propertyType == "Shop")
              ? _officeFeatures
              : (_status == "Rent")
                  ? _homeRentFeatures
                  : _homeBuyFeatures,
          initialValue: items,
          onConfirm: (values) {
            _resetFeatures();
            _features.addAll(values);
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

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _price.dispose();
    _yearConstructed.dispose();
    _description.dispose();
    _bedrooms.dispose();
    _bathrooms.dispose();
    _kitchen.dispose();
    _garages.dispose();
    _size.dispose();

    _currency = '';
    _status = '';
    _propertyType = '';
    _likes = 0;
    _features.clear();
    _sizeUnit = '';
    _images.clear();
    _brokerId = '';

    super.dispose();
  }
}
