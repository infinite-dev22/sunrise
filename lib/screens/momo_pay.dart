import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:flutterwave_standard/view/view_utils.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/services/database_services.dart';
import 'package:sunrise/theme/color.dart';
import 'package:toast/toast.dart';

import '../widgets/wide_button.dart';

class MomoPayPage extends StatefulWidget {
  const MomoPayPage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<MomoPayPage> createState() => _MomoPayPageState();
}

class _MomoPayPageState extends State<MomoPayPage> {
  String txRef = "TXN-${Random().nextInt(100000)}";

  @override
  Widget build(BuildContext context) {
    ToastContext toast = ToastContext();
    toast.init(context);

    TextEditingController amount = TextEditingController();
    TextEditingController phoneNumber = TextEditingController();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Mobile Money pay wall'),
          backgroundColor: AppColor.appBgColor),
      backgroundColor: AppColor.appBgColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: "Enter phone number",
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    helperText:
                        'Select country code eg. +256 and enter phone number minus country code eg. 78123456789',
                  ),
                  initialCountryCode: Platform.localeName,
                  controller: phoneNumber,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: amount,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: 'Enter amount (UGX)',
                      hintText: 'eg. 5,000'),keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsFormatter(),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          WideButton(
            "Proceed",
            color: Colors.white,
            bgColor: AppColor.primary,
            onPressed: () {
              handlePaymentInitialization(
                  context, phoneNumber.text, amount.text);
            },
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  handlePaymentInitialization(
      BuildContext context, String phoneNumber, String amount) async {
    final Customer customer = Customer(
        name: widget.userProfile.name,
        phoneNumber: phoneNumber,
        email: widget.userProfile.email);

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: "FLWPUBK_TEST-bba650c9c1177a792dcc2795f0592e5d-X",
        currency: "UGX",
        txRef: txRef,
        amount: amount,
        customer: customer,
        paymentOptions: "ussd, card, barter, payattitude",
        customization: Customization(title: "My Payment"),
        isTestMode: true,
        redirectUrl: 'https://tunzmvqqhrkcdlicefmi.supabase.co');

    final ChargeResponse response = await flutterwave.charge();

    _payProgress(response, amount);
  }

  _payProgress(ChargeResponse response, String amount) {
    if (response.success! && response.txRef == txRef) {
      DatabaseServices.upsertUserWallet(widget.userProfile, amount as int);
      DatabaseServices.createAccountTransaction(
          widget.userProfile.id, amount as int, "deposit", "", "mobile money");
      return FlutterwaveViewUtils.showToast(context, "Payment successful");
    } else {
      return FlutterwaveViewUtils.showToast(context, "Payment unsuccessful");
    }
  }

  @override
  void initState() {
    super.initState();
  }
}
