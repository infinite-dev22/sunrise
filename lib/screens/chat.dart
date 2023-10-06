import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:sunrise/models/property.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/services/database_services.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/custom_image.dart';
import 'package:toast/toast.dart';

import '../constants/constants.dart';
import '../models/account.dart';
import '../utilities/features/chat/supabase_chat_types.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.room,
    this.userProfile,
  });

  final Room room;
  final UserProfile? userProfile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ToastContext toast = ToastContext();
  late Listing? _listing;
  late UserProfile? _brokerProfile;
  late UserProfile _currentUserProfile;
  late ChatUser _currentUser;

  TextEditingController textController = TextEditingController();

  List<ChatMessage> messageList = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    toast.init(context);
    _getListing();

    try {
      UserProfile currentUserProfile = _currentUserProfile;

      _currentUser = ChatUser(
          id: currentUserProfile.userId,
          firstName: currentUserProfile.name,
          profileImage: currentUserProfile.profilePicture);

      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.appBgColor,
          bottom: _buildListing(),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Row(
            children: [
              _buildProfilePicture(widget.room.userId == _currentUserProfile.id
                  ? widget.room.guestUserImage
                  : widget.room.userImage),
              const SizedBox(
                width: 5,
              ),
              Text(
                  widget.room.userId == _currentUserProfile.id
                      ? widget.room.guestUserName
                      : widget.room.userName,
                  style: const TextStyle(color: AppColor.darker)),
            ],
          ),
          leadingWidth: 20,
          actions: [
            IconButton(
                onPressed: () async {
                  try {
                    await FlutterPhoneDirectCaller.callNumber(
                        (widget.userProfile != null)
                            ? widget.userProfile!.phoneNumber
                            : _brokerProfile!.phoneNumber);
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
                icon: const Icon(
                  Icons.phone,
                  color: AppColor.primary,
                ))
          ],
        ),
        backgroundColor: AppColor.appBgColor,
        body: _buildBody(),
      );
    } catch (e) {
      return _buildProgress();
    }
  }

  _buildMessages(List messages) {
    messageList.clear();
    for (var message in messages) {
      messageList.add(mapToMessage(message));
    }
  }

  _buildBody() {
    return DashChat(
      messageOptions: const MessageOptions(
          showTime: true,
          containerColor: AppColor.chatGray,
          currentUserContainerColor: AppColor.chatBlue),
      currentUser: _currentUser,
      onSend: _onSendTap,
      messages: messageList,
    );
  }

  _buildProgress() {
    return Container(
      color: AppColor.appBgColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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

  void _onSendTap(ChatMessage msg) {
    Map<String, dynamic> message = msg.toJson();
    message.addAll({'chat_room_id': widget.room.id});
    messagesRef.insert(message).execute();
  }

  mapToMessage(Map<String, dynamic> doc) {
    return ChatMessage.fromJson(doc);
  }

  _buildProfilePicture(String url) {
    return CustomImage(
      url,
      width: 35,
      height: 35,
    );
  }

  _getListing() async {
    List listings = await DatabaseServices.getListing();

    for (Listing listing in listings) {
      if (listing.id == widget.room.listingId) {
        if (widget.userProfile == null) {
          _brokerProfile =
              await DatabaseServices.getUserProfile(listing.userId);
        }
        setState(() {
          _listing = listing;
        });
      }
    }
  }

  _buildNavigateToViewPage(Listing listing) {
    if (_listing!.show) {
      var nav = Navigator.of(context);

      return nav.push(MaterialPageRoute(
          builder: (BuildContext context) => ViewPage(
                listing: listing,
              )));
    } else {
      Toast.show("Listing no longer Available",
          duration: Toast.lengthLong, gravity: Toast.center);
    }
  }

  _buildListing() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: GestureDetector(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
          child: Row(
            children: [
              CustomImage(
                _listing!.images[0],
                width: 50,
                height: 50,
                radius: 10,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _listing!.show
                        ? _listing!.name
                        : "${_listing!.name} - Not Available",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Text(
                        "${_listing!.price} - ",
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        _listing!.location,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.grey_300,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () => _buildNavigateToViewPage(_listing!),
      ),
    );
  }

  _initData() async {
    _currentUserProfile = await DatabaseServices.getUserProfile(
        FirebaseAuth.instance.currentUser!.uid);

    messagesRef
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', widget.room.id)
        .order('created_at')
        .listen(_buildMessages);
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
