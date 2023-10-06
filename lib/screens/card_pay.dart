import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutterwave_standard/view/view_utils.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:sunrise/widgets/wide_button.dart';
import 'package:toast/toast.dart';

import '../models/account.dart';
import '../services/database_services.dart';
import '../theme/color.dart';

class CardPayPage extends StatefulWidget {
  const CardPayPage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<CardPayPage> createState() => _CardPayPageState();
}

class _CardPayPageState extends State<CardPayPage> {
  void _loadDotEnv() async {
    await dotenv.load(fileName: ".env");
  }

  @override
  void initState() {
    super.initState();
    _loadDotEnv();
  }

  final String txRef = "TXN-${Random().nextInt(1000000)}";

  TextEditingController amount = TextEditingController();

  String bankName = '';
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useBackgroundImage = true;
  bool useFloatingAnimation = true;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ToastContext toast = ToastContext();
    toast.init(context);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Bank Card pay wall'),
          backgroundColor: AppColor.appBgColor),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.appBgColor,
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(color: AppColor.appBgColor),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  CreditCardWidget(
                    enableFloatingCard: useFloatingAnimation,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    bankName: bankName,
                    frontCardBorder: Border.all(color: Colors.grey),
                    backCardBorder: Border.all(color: Colors.grey),
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isHolderNameVisible: true,
                    cardBgColor: AppColor.cardBgColor,
                    backgroundImage:
                        useBackgroundImage ? 'assets/images/card_bg.png' : null,
                    isSwipeGestureEnabled: true,
                    onCreditCardWidgetChange:
                        (CreditCardBrand creditCardBrand) {},
                    customCardTypeIcons: <CustomCardTypeIcon>[
                      CustomCardTypeIcon(
                        cardType: CardType.mastercard,
                        cardImage: Image.asset(
                          'assets/images/mastercard.png',
                          height: 48,
                          width: 48,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              onChanged: (value) => setState(() {
                                bankName = value;
                              }),
                              decoration: const InputDecoration(
                                  hintText: 'eg. Centenary Bank',
                                  labelText: 'Bank Name'),
                            ),
                          ),
                          CreditCardForm(
                            formKey: formKey,
                            obscureCvv: true,
                            obscureNumber: true,
                            cardNumber: cardNumber,
                            cvvCode: cvvCode,
                            isHolderNameVisible: true,
                            isCardNumberVisible: true,
                            isExpiryDateVisible: true,
                            cardHolderName: cardHolderName,
                            expiryDate: expiryDate,
                            inputConfiguration: const InputConfiguration(
                              cardNumberDecoration: InputDecoration(
                                labelText: 'Number',
                                hintText: 'XXXX XXXX XXXX XXXX',
                              ),
                              expiryDateDecoration: InputDecoration(
                                labelText: 'Expired Date',
                                hintText: 'XX/XX',
                              ),
                              cvvCodeDecoration: InputDecoration(
                                labelText: 'CVV',
                                hintText: 'XXX',
                              ),
                              cardHolderDecoration: InputDecoration(
                                labelText: 'Card Holder',
                              ),
                            ),
                            onCreditCardModelChange: onCreditCardModelChange,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: amount,
                              decoration: const InputDecoration(
                                  hintText: 'eg. 10,000', labelText: 'Amount'),
                              inputFormatters: [ThousandsFormatter()],
                            ),
                          ),
                          const SizedBox(height: 180),
                        ],
                      ),
                    ),
                  ),
                  WideButton(
                    "Proceed",
                    color: Colors.white,
                    bgColor: AppColor.primary,
                    onPressed: _onValidate,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      if (kDebugMode) {
        print('valid!');
      }
      handlePaymentInitialization(cardNumber, amount.text);
    } else {
      Toast.show("Invalid Card",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  handlePaymentInitialization(String phoneNumber, String amount) async {
    final Customer customer = Customer(
        name: widget.userProfile.name,
        phoneNumber: phoneNumber,
        email: widget.userProfile.email);

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: dotenv.env['PUBLIC_KEY']!,
        currency: "UGX",
        txRef: txRef,
        amount: amount,
        customer: customer,
        paymentOptions: "ussd, card, barter, payattitude",
        customization: Customization(title: "Test Payment"),
        isTestMode: true,
        redirectUrl: 'https://tunzmvqqhrkcdlicefmi.supabase.co');

    final ChargeResponse response = await flutterwave.charge();

    _payProgress(response, amount);
  }

  _payProgress(ChargeResponse response, String amount) {
    if (response.success! && response.txRef == txRef) {
      DatabaseServices.upsertUserWallet(widget.userProfile, amount as int);
      DatabaseServices.createAccountTransaction(
          widget.userProfile.id, amount as int, "deposit", "", "card");
      return FlutterwaveViewUtils.showToast(context, "Payment successful");
    } else {
      return FlutterwaveViewUtils.showToast(context, "Payment unsuccessful");
    }
  }
}
