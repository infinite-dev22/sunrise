import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/theme/color.dart';
import 'package:toast/toast.dart';

import '../constants/constants.dart';
import '../widgets/account_card.dart';
import '../widgets/icon_box.dart';
import '../widgets/transaction_item.dart';
import '../widgets/wide_button.dart';
import 'card_pay.dart';
import 'momo_pay.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  ToastContext toast = ToastContext();

  late Stream<List<Map<String, dynamic>>> _transactionsStream;
  late Stream<List<Map<String, dynamic>>> _walletStream;
  late Wallet _wallet;

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    toast.init(context);

    var screenWidth = MediaQuery.of(context).size.width;
    var imageHeight = 300.0;

    return Scaffold(
        backgroundColor: AppColor.appBgColor,
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 75, 10, 20),
              width: screenWidth,
              height: imageHeight,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/back.jpg"),
                      fit: BoxFit.fill)),
              child: Column(
                children: [
                  StreamBuilder(
                    stream: _walletStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        Toast.show("An Error occurred",
                            duration: Toast.lengthLong, gravity: Toast.bottom);
                      }

                      try {
                        if (snapshot.data!.isEmpty) {
                          return Container();
                        }
                      } catch (e) {
                        return Container();
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: AccountCard(
                          card: snapshot.data!.map((doc) {
                            _wallet = Wallet.fromDoc(doc);
                            return AccountCardModel(
                                balance: _wallet.balance.toDouble());
                          }).first,
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => AppColor.primary)),
                      onPressed: () => _buildAddFeaturedDialog(),
                      child: const Text(
                        "Deposit",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColor.darker,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 25,
              left: 5,
              child: Row(
                children: [
                  IconBox(
                    onTap: () => Navigator.pop(context),
                    bgColor: AppColor.translucent,
                    child: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  SizedBox(
                    width: screenWidth * .1,
                  ),
                  const Text("My account",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: imageHeight * .9),
              child: _buildInfo(),
            ),
          ],
        ));
  }

  _buildAddFeaturedDialog() {
    return showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "Select payment method",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          WideButton(
            "Bank Card",
            color: Colors.white,
            bgColor: AppColor.primary,
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => CardPayPage(
                        userProfile: widget.userProfile,
                      )));
            },
          ),
          const SizedBox(height: 20),
          WideButton(
            "Mobile Money",
            color: Colors.white,
            bgColor: AppColor.primary,
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => MomoPayPage(
                        userProfile: widget.userProfile,
                      )));
            },
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.only(
        top: 15,
      ),
      decoration: const BoxDecoration(
        color: AppColor.appBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Text(
                    "Transactions",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                  ),
                  _showTransactions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showTransactions() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Column(
            children: [
              SizedBox(height: 80),
              Center(
                child: Text('Your transactions appear here'),
              )
            ],
          );
        }

        try {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Your transactions appear here'),
            );
          }
        } catch (e) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(bottom: 5, left: 15, right: 15),
              child: Row(
                children: snapshot.data!
                    .map((var document) {
                      Transaction transaction = Transaction.fromDoc(document);

                      return _buildTransaction(transaction);
                    })
                    .toList()
                    .cast(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  _buildTransaction(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: TransactionItem(
          transaction: transaction,
        ),
      ),
    );
  }

  _initStreams() async {
    _transactionsStream = transactionsRef
        .stream(primaryKey: ['id'])
        .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
        .order('created_at', ascending: false)
        .limit(30);

    _walletStream = walletsRef
        .stream(primaryKey: ['id']).eq('user_id', widget.userProfile.id);
  }

  @override
  void initState() {
    super.initState();
    _initStreams();
  }
}
