import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sunrise/models/property.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/services/database_services.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/utilities/global_values.dart';
import 'package:sunrise/widgets/custom_image.dart';

import '../models/account.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.room,
    this.userProfile,
  });

  final types.Room room;
  final UserProfile? userProfile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isAttachmentUploading = false;
  late Listing? _listing;
  late UserProfile? _brokerProfile;

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
    setState(() {});
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getListing();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appBgColor,
        bottom: _buildListing(),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Row(
          children: [
            _buildProfilePicture(widget.room.imageUrl ?? ''),
            const SizedBox(
              width: 5,
            ),
            Text(widget.room.name ?? 'Chat',
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
      body: StreamBuilder<types.Room>(
        initialData: widget.room,
        stream: FirebaseChatCore.instance.room(widget.room.id),
        builder: (context, snapshot) => StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: FirebaseChatCore.instance.messages(snapshot.data!),
            builder: (context, snapshot) => Chat(
                  typingIndicatorOptions: const TypingIndicatorOptions(),
                  isAttachmentUploading: _isAttachmentUploading,
                  messages: snapshot.data ?? [],
                  onAttachmentPressed: _handleAttachmentPressed,
                  onMessageTap: _handleMessageTap,
                  onPreviewDataFetched: _handlePreviewDataFetched,
                  onSendPressed: _handleSendPressed,
                  scrollToUnreadOptions: const ScrollToUnreadOptions(
                    lastReadMessageId: 'lastReadMessageId',
                    scrollOnOpen: true,
                  ),
                  onMessageVisibilityChanged: (p0, visible) {
                    if (visible) {
                      if (p0.author.id != user!.uid) {
                        final updatedMessage = p0.copyWith(status: Status.seen);
                        FirebaseChatCore.instance
                            .updateMessage(updatedMessage, widget.room.id);
                      } else {
                        final updatedMessage =
                            p0.copyWith(status: Status.delivered);
                        FirebaseChatCore.instance
                            .updateMessage(updatedMessage, widget.room.id);
                      }

                      setState(() {});
                    }
                  },
                  theme: const DefaultChatTheme(
                      primaryColor: AppColor.chatBlue,
                      secondaryColor: AppColor.chatGray,
                      inputBorderRadius: BorderRadius.all(Radius.circular(50)),
                      inputMargin:
                          EdgeInsets.only(bottom: 5, left: 5, right: 5),
                      inputPadding: EdgeInsets.all(12),
                      inputBackgroundColor: AppColor.primary),
                  usePreviewData: true,
                  textMessageOptions:
                      const TextMessageOptions(isTextSelectable: false),
                  user: types.User(
                    id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                  ),
                )),
      ),
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
      if (listing.id == widget.room.metadata!["listingId"]) {
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

  _buildNavigateToViewPage(Listing listing) async {
    var nav = Navigator.of(context);

    // These variables below affect performance significantly, try putting them
    // into their respective screen(ViewPage).
    UserProfile brokerProfile =
        await DatabaseServices.getUserProfile(listing.userId);
    List favorite = await DatabaseServices.getFavorite(listing.id);

    return nav.push(MaterialPageRoute(
        builder: (BuildContext context) => ViewPage(
              listing: listing,
              userProfile: brokerProfile,
              favorite: favorite.isEmpty ? null : favorite[0],
            )));
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
                    _listing!.name,
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
  void dispose() {
    _listing = null;
    _brokerProfile = null;

    super.dispose();
  }
}
