import 'package:chatview/chatview.dart';
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
  late ChatViewState _chatViewState;
  late ChatUser _currentUser;
  late ChatUser _otherUser;
  late ChatController _chatController;

  @override
  Widget build(BuildContext context) {
    toast.init(context);
    _getListing();
    UserProfile currentUserProfile = _currentUserProfile;

    _currentUser = ChatUser(
        id: currentUserProfile.userId,
        name: currentUserProfile.name,
        profilePhoto: currentUserProfile.profilePicture);

    _otherUser = ChatUser(
        id: widget.userProfile!.userId,
        name: widget.userProfile!.name,
        profilePhoto: widget.userProfile!.profilePicture);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appBgColor,
        bottom: _buildListing(),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Row(
          children: [
            _buildProfilePicture(
                widget.room.userId == FirebaseAuth.instance.currentUser!.uid
                    ? widget.room.userImage
                    : widget.room.guestUserImage),
            const SizedBox(
              width: 5,
            ),
            Text(
                widget.room.userId == FirebaseAuth.instance.currentUser!.uid
                    ? widget.room.userName
                    : widget.room.guestUserName,
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: messagesRef
              .stream(primaryKey: ['id'])
              .eq('room_id', widget.room.id)
              .order('created_at'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              _chatViewState = ChatViewState.error;
            }

            if (snapshot.hasData) {
              _chatViewState = ChatViewState.loading;
            }

            if (snapshot.data!.isEmpty) {
              _chatViewState = ChatViewState.noData;
            }

            if (snapshot.data!.isNotEmpty) {
              _chatViewState = ChatViewState.hasMessages;
            }

            List<Message> messageList = snapshot.data!
                .map((e) => mapToMessage(e))
                .toList() as List<Message>;

            _chatController = ChatController(
              initialMessageList: messageList,
              scrollController: ScrollController(),
              chatUsers: [_otherUser],
            );

            return ChatView(
              chatController: _chatController,
              currentUser: _currentUser,
              chatViewState: _chatViewState,
              onSendTap: onSendTap,
            );
          }),
    );
  }

  void onSendTap(
      String message, ReplyMessage replyMessage, MessageType messageType) {
    final message = Message(
      id: '3',
      message: "How are you",
      createdAt: DateTime.now(),
      sendBy: _currentUser.id,
      replyMessage: replyMessage,
      messageType: messageType,
    );
    _chatController.addMessage(message);
  }

  mapToMessage(Map<String, dynamic> doc) {
    return Message(
      message: doc['message'],
      createdAt: doc['created_at'],
      sendBy: doc['sent_by'],
    );
  }

  _buildProfilePicture(String url) {
    return CustomImage(
      url,
      width: 45,
      height: 45,
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

  @override
  Future<void> initState() async {
    _currentUserProfile = await DatabaseServices.getUserProfile(
        FirebaseAuth.instance.currentUser!.uid);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
