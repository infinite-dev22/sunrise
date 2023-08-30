import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sunrise/theme/color.dart';
import 'package:super_bullet_list/bullet_list.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.showingContent}) : super(key: key);

  final String showingContent;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: _buildHeader(),
      body: _buildBody(),
    );
  }

  _buildHeader() {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.showingContent,
              style: const TextStyle(
                fontSize: 18,
                color: AppColor.darker,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          _setDisplay(widget.showingContent),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  _buildPrivacyPolicy() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentHeading("Home Pal Privacy Policy"),
          _buildContentBody(
              "This privacy policy applies to the Home Pal mobile app, which is owned and operated by WaGroLabs."),
          _buildContentSubHeading("What information do we collect?"),
          _buildContentBody(
              "We collect the following information from you when you use the Home Pal app:"),
          _buildContentBodyList([
            "Your name, email address, and phone number",
            "Your device information, such as your device ID and operating system",
            "Your location information, if you have enabled location services",
            "Your feedback and comments"
          ]),
          _buildContentSubHeading("We use your information to:"),
          _buildContentBodyList([
            "Provide you with the Home Pal app and its features",
            "Improve the Home Pal app and its features",
            "Send you marketing and promotional materials",
            "Contact you about your account or to resolve any issues",
            "Comply with our legal obligations"
          ]),
          _buildContentSubHeading("Who do we share your information with?"),
          _buildContentBody(
              "We may share your information with the following third parties:"),
          _buildContentBodyList([
            "Our service providers, who help us operate the Home Pal app, such as our hosting provider and our analytics provider",
            "Other companies that we partner with to offer you certain features, such as our payment processor",
            "Law enforcement or other government agencies, if required by law"
          ]),
          _buildContentSubHeading("How do we protect your information?"),
          _buildContentBody(
              "We take steps to protect your information, such as:"),
          _buildContentBodyList([
            "Using industry-standard security measures to store your information",
            "Requiring our service providers to protect your information",
            "Only sharing your information with third parties who have agreed to protect it"
          ]),
          _buildContentSubHeading("How long do we keep your information?"),
          _buildContentBody(
              "We keep your information for as long as you use the Home Pal app or as needed to provide you with the services you have requested. We may also keep your information for a longer period of time to comply with our legal obligations or to resolve any disputes."),
          _buildContentSubHeading("Your rights"),
          _buildContentBody(
              "You have the following rights regarding your information:"),
          _buildContentBodyList([
            "To access your information",
            "To correct your information",
            "To delete your information",
            "To object to the processing of your information",
            "To restrict the processing of your information",
            "To port your information to another service",
            [
              "You can exercise these rights by contacting us at ",
              "Home Pal Support"
            ]
          ]),
          _buildContentSubHeading("Changes to this privacy policy"),
          _buildContentBody(
              "We may update this privacy policy from time to time. The updated version will be posted on the Home Pal app and will be effective as soon as it is posted."),
          _buildContentSubHeading("Contact us"),
          _buildContentBodyWithLink(
              "If you have any questions about this privacy policy, please contact us at ",
              "Home Pal Support"),
        ],
      ),
    );
  }

  _buildAbout() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentHeading("Home Pal: Your Real Estate Companion"),
          _buildContentBody(
              "Home Pal is the mobile app that makes buying, selling, or renting a home easier than ever. With Home Pal, you can:"),
          _buildContentBodyList([
            "Browse millions of listings from trusted real estate agents",
            "Get personalized recommendations based on your needs and preferences",
            "Schedule showings and communicate with agents directly",
            "Track your progress and stay organized throughout the home buying or selling process",
          ]),
          _buildContentBody(
              "Home Pal is the perfect tool for anyone who is looking to buy, sell, or rent a home. With its intuitive interface and powerful features, Home Pal makes the home buying or selling process simple and stress-free."),
          _buildContentSubHeading(
              "Here are some of the features that make Home Pal the best real estate app on the market:"),
          _buildContentBodyList([
            "Millions of listings: Home Pal has access to millions of listings from trusted real estate agents. This means you're sure to find the perfect home for your needs.",
            "Personalized recommendations: Home Pal uses your search history and preferences to provide you with personalized recommendations. This means you're only seeing homes that are relevant to you.",
            "Direct communication with agents: Home Pal makes it easy to communicate with real estate agents directly. This means you can get the answers you need quickly and easily.",
            "Track your progress: Home Pal keeps track of your progress throughout the home buying or selling process. This means you can always stay organized and on top of things."
          ]),
          _buildContentBody(
              "Home Pal is the perfect way to buy, sell, or rent a home. Download the app today and start your home search!"),
          _buildContentSubHeading(
              "Here are some of the benefits of using Home Pal:"),
          _buildContentBodyList([
            "Save time and money: Home Pal can help you save time and money by streamlining the home buying or selling process.",
            "Get the best deal: Home Pal can help you find the best deal on your home by comparing listings from multiple agents.",
            "Make informed decisions: Home Pal provides you with the information you need to make informed decisions about your home purchase or sale.",
            "Get peace of mind: Home Pal is backed by a team of experts who are there to help you every step of the way.",
          ]),
          _buildContentBody(
              "If you're looking for a trusted real estate partner, Home Pal is the app for you. Download the app today and start your home search!"),
        ],
      ),
    );
  }

  _buildContentHeading(String data) {
    return RichText(
      text: TextSpan(
        text: data,
        style: GoogleFonts.lato(
          textStyle: Theme.of(context).textTheme.displayLarge,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }

  _buildContentSubHeading(String data) {
    return Column(
      children: [
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            text: data,
            style: GoogleFonts.lato(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  _buildContentBody(String data) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: data,
            style: GoogleFonts.lato(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  _buildContentBodyWithLink(String data, String link) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: data,
                style: GoogleFonts.lato(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: link,
                style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.blue,
                    color: AppColor.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri(
                      scheme: "mailto",
                      path: "support@homepal.org",
                      query: encodeQueryParameters(<String, String>{
                        'subject': 'Support mail',
                      }),
                    ));
                  },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  _buildContentBodyList(List data) {
    return Column(
      children: [
        SuperBulletList(isOrdered: false, items: [
          for (var item in data)
            if (item is List)
              _buildContentBodyWithLink(item[0], item[1])
            else
              RichText(
                text: TextSpan(
                  text: item,
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
        ]),
        const SizedBox(height: 10),
      ],
    );
  }

  _setDisplay(String type) {
    switch (type) {
      case "Privacy Policy":
        return _buildPrivacyPolicy();
      case "About":
        return _buildAbout();
    }
  }
}
