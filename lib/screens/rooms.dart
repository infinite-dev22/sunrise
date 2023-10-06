import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sunrise/constants/constants.dart';
import 'package:sunrise/screens/welcome.dart';

import '../models/account.dart';
import '../services/database_services.dart';
import '../theme/color.dart';
import '../utilities/features/chat/supabase_chat_types.dart';
import 'chat.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key, required this.userProfile});

  final UserProfile? userProfile;

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  bool _error = false;
  bool _initialized = false;
  User? _user;
  late UserProfile _userProfile;

  late Stream<List<Map<String, dynamic>>> _userRoomsStream;

  @override
  void initState() {
    super.initState();

    initializeFlutterFire();
  }

  void initializeFlutterFire() async {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        setState(() {
          _user = user;
        });
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  Widget _buildAvatar(Room room) {
    var color = Colors.transparent;

    final hasImage = (room.userId == widget.userProfile!.id
            ? room.guestUserImage
            : room.userImage)
        .isNotEmpty;
    final name = (room.userId == widget.userProfile!.id
        ? room.guestUserName
        : room.userName);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage
            ? NetworkImage(room.userId == widget.userProfile!.id
                ? room.guestUserImage
                : room.userImage)
            : null,
        radius: 30,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
    }

    if (widget.userProfile != null) {
      return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: AppColor.appBgColor,
          title: Text(
            "Chats",
            style: GoogleFonts.lato(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        backgroundColor: AppColor.appBgColor,
        body: _user == null
            ? Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  bottom: 200,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not authenticated'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => WelcomePage(),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              )
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream:
                    chatRoomsRef.stream(primaryKey: ['id']).order('updated_at'),
                initialData: const [],
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const Text('Something went wrong'),
                          IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            super.widget));
                              },
                              icon: const Icon(Icons.refresh_rounded))
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Your chats appear here'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      if (snapshot.data![index]['user_id'] ==
                              widget.userProfile!.id ||
                          snapshot.data![index]['user_id'] ==
                              widget.userProfile!.id) {
                        final room = Room.fromDoc(snapshot.data![index]);

                        _getUserProfile(room.guestUserId);

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => ChatPage(
                                  room: room,
                                  userProfile: _userProfile,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColor.appBgColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.shadowColor.withOpacity(0.1),
                                  spreadRadius: .5,
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildAvatar(room),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            room.userId ==
                                                    widget.userProfile!.id
                                                ? room.guestUserName
                                                : room.userName,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Spacer(),
                                          const Text(
                                            '',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        room.listingName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: AppColor.grey_300),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      const Text(
                                        '',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppColor.darker),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
      );
    } else {
      return _buildProgress();
    }
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

  _getUserProfile(int userId) async {
    UserProfile brokerProfile =
        await DatabaseServices.getUserProfileById(userId);
    setState(() {
      _userProfile = brokerProfile;
    });
  }
}
