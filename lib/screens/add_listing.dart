import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:platform_local_notifications/platform_local_notifications.dart';
import 'package:string_validator/string_validator.dart';
import 'package:sunrise/models/property.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/utilities/global_values.dart';

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

  // late String _name = (widget.listing != null) ? widget.listing!.name : "";
  // late String _location =
  //     (widget.listing != null) ? widget.listing!.location : "";
  // late String _price = (widget.listing != null) ? widget.listing!.price : "";
  late String _currency = (widget.listing != null) ? widget.listing!.currency : "";

  late String _status = (widget.listing != null) ? widget.listing!.status : "";
  late String _propertyType =
      (widget.listing != null) ? widget.listing!.propertyType : "";

  // late String _yearConstructed =
  //     (widget.listing != null) ? widget.listing!.yearConstructed : "";
  // late String _description =
  //     (widget.listing != null) ? widget.listing!.description : "";
  late int _likes = (widget.listing != null) ? widget.listing!.likes : 0;
  late final List _features = (widget.listing != null)
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
        const SizedBox(
          height: 20,
        ),
        _textFieldWithAction("Location", Icons.location_on, () {}, _location),
        _numberField("Year Constructed", _yearConstructed),
        const SizedBox(
          height: 20,
        ),
        _dropdownMenuEntries("Status", statuses.toList(), (value) {
          _status = value!;
          setState(() {});
        }),
        const SizedBox(
          height: 20,
        ),
        _textFieldWithUnit("Size", "Unit", areaUnit, _size, (dropDownValue) {
          setState(() {
            _sizeUnit = dropDownValue!;
          });
        }),
        (_propertyType == "Shop" || _propertyType == "Office")
            ? _buildWorkPlaceFeatures()
            : _buildHomeFeatures(),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
          keyboardAppearance: Brightness.dark,
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
    var nav = Navigator.of(context);
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
          onPressed: () async {
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

            if (_formKey.currentState!.validate() &&
                _propertyType.isNotEmpty &&
                _status.isNotEmpty &&
                CustomPhotoGallery.images.isNotEmpty) {
              setState(() {
                _loading = true;
              });

              _images = (await StorageServices.uploadListingImages(
                  CustomPhotoGallery.images));

              Listing listing = Listing(
                id: '',
                userId: _brokerId,
                name: _name.text.trim(),
                location: _location.text.trim(),
                price: (_status == "Rent") ? "${_numberFormat(_price.text.trim())}/month" : "${_numberFormat(_price.text.trim())}",
                currency: _currency,
                status: _status,
                propertyType: _propertyType,
                yearConstructed: _yearConstructed.text.trim(),
                description: _description.text.trim(),
                likes: _likes,
                featured: false,
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
                        {
                          "quantity": _bedrooms.text,
                          "name": "Bedrooms",
                          "icon": "bed"
                        },
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
                        {
                          "quantity": _garages.text,
                          "name": "Garages",
                          "icon": "garage"
                        },
                        {
                          "quantity": _size.text,
                          "name": _sizeUnit,
                          "icon": "rulerCombined"
                        },
                        {"name": "Wifi", "value": _wifiValue, "icon": "wifi"},
                        {
                          "name": "TV Cable",
                          "value": _tvCableValue,
                          "icon": "tv"
                        },
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
                        {
                          "name": "Outdoor Shower",
                          "value": _outdoorShowerValue
                        },
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
            } else if (_propertyType.isEmpty) {
              CherryToast(
                      title: const Text(""),
                      displayTitle: false,
                      description: const Text("Property type can't be empty"),
                      icon: Icons.error,
                      themeColor: AppColor.darker,
                      toastPosition: Position.bottom,
                      animationDuration: const Duration(milliseconds: 1000),
                      autoDismiss: true)
                  .show(context);
            } else if (_status.isEmpty) {
              CherryToast(
                      title: const Text(""),
                      displayTitle: false,
                      description: const Text("Status can't be empty"),
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
                "Create",
                style: TextStyle(fontSize: 13, color: AppColor.appBgColor),
              ),
            ],
          ),
        ),
      ],
    );
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

  _buildHomeFeatures() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _maskedNumberField("Bedrooms", _bedrooms),
            ),
            const Spacer(),
            SizedBox(
              width: halfScreen * .9,
              child: _maskedNumberField("Bathrooms", _bathrooms),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _maskedNumberField("Kitchen", _kitchen),
            ),
            const Spacer(),
            SizedBox(
              width: halfScreen * .9,
              child: _maskedNumberField("Garages", _garages),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Air Conditioning", _acValue, (value) {
                setState(() {
                  _acValue = value!;
                });
              }),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Refrigerator", _refrigeratorValue, (value) {
                setState(() {
                  _refrigeratorValue = value!;
                });
              }),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Wifi", _wifiValue, (value) {
                setState(() {
                  _wifiValue = value!;
                });
              }),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Outdoor Shower", _outdoorShowerValue, (value) {
                setState(() {
                  _outdoorShowerValue = value!;
                });
              }),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("TV Cable", _tvCableValue, (value) {
                setState(() {
                  _tvCableValue = value!;
                });
              }),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Gym", _gymValue, (value) {
                setState(() {
                  _gymValue = value!;
                });
              }),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Spa & Massage", _spaValue, (value) {
                setState(() {
                  _spaValue = value!;
                });
              }),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Lawn", _lawnValue, (value) {
                setState(() {
                  _lawnValue = value!;
                });
              }),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Dryer", _dryerValue, (value) {
                setState(() {
                  _dryerValue = value!;
                });
              }),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Swimming Pool", _poolValue, (value) {
                setState(() {
                  _poolValue = value!;
                });
              }),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox("Cooker", _cookerValue, (value) {
                setState(() {
                  _cookerValue = value!;
                });
              }),
            ),
            const SizedBox(
              width: 5,
            ),
            (_status == "Rent")
                ? SizedBox(
                    width: halfScreen * .9,
                    child: _checkBox("Pets", _petsValue, (value) {
                      setState(() {
                        _petsValue = value!;
                      });
                    }),
                  )
                : Container(),
          ],
        ),
      ],
    );
  }

  _buildWorkPlaceFeatures() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox(
                "Air Conditioning",
                _acValue,
                (value) {
                  setState(() {
                    _acValue = value!;
                  });
                },
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox(
                "Wifi",
                _wifiValue,
                (value) {
                  setState(() {
                    _wifiValue = value!;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: halfScreen * .9,
              child: _checkBox(
                "Electricity",
                _powerValue,
                (value) {
                  setState(() {
                    _powerValue = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
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
