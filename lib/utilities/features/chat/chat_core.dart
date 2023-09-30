import 'package:firebase_auth/firebase_auth.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/utilities/features/chat/supabase_chat_types.dart';

import '../../../constants/constants.dart';

/// Provides access to Firebase chat data. Singleton, use
/// CustomFirebaseChatCore.instance to access methods.
class SupabaseChatCore {
  SupabaseChatCore._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      firebaseUser = user;
    });
  }

  /// Current logged in user in Firebase. Does not update automatically.
  /// Use [FirebaseAuth.authStateChanges] to listen to the state changes.
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  /// Singleton instance.
  static final SupabaseChatCore instance =
      SupabaseChatCore._privateConstructor();

  /// Creates a direct chat for 2 people. Add [metadata] for any additional
  /// custom data.
  Future<Room> createRoom(
      UserProfile guestUser, int listingId, String listingName) async {
    final fu = firebaseUser;

    if (fu == null) return Future.error('User does not exist');

    // Sort two user ids array to always have the same array for both users,
    // this will make it easy to find the room if exist and make one read only.

    final roomQuery = await chatRoomsRef
        .select()
        .eq('user_id', fu.uid)
        .eq('guest_user_id', guestUser)
        .eq('listing_id', listingId)
        .limit(1);

    // Check if room already exist.
    if (roomQuery.data.isNotEmpty) {
      final room = roomQuery.data;
      return room;
    }

    // Create new room with sorted user ids array.
    final room = await chatRoomsRef.insert({
      'user_id': fu.uid,
      'guest_user_id': guestUser.userId,
      'user_name': fu.displayName,
      'guest_user_name': guestUser.name,
      'listing_id': listingId,
      'listing_name': listingName,
      'has_new_messages': false,
    });

    return room;
  }

  /// Returns a stream of rooms from Firebase. Only rooms where current
  /// logged in user exist are returned. [orderByUpdatedAt] is used in case
  /// you want to have last modified rooms on top, there are a couple
  /// of things you will need to do though:
  /// 1) Make sure `updatedAt` exists on all rooms
  /// 2) Write a Cloud Function which will update `updatedAt` of the room
  /// when the room changes or new messages come in
  /// 3) Create an Index (Firestore Database -> Indexes tab) where collection ID
  /// is `rooms`, field indexed are `userIds` (type Arrays) and `updatedAt`
  /// (type Descending), query scope is `Collection`
  Stream<List<Room>> rooms() {
    final fu = firebaseUser;

    if (fu == null) return const Stream.empty();

    Stream<List<Room>> roomsStream = chatRoomsRef
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((chatRooms) =>
            chatRooms.map((chatRoom) => Room.fromDoc(chatRoom)).toList());

    return roomsStream;
  }

  /// Updates a message in the Firestore. Accepts any message and a
  /// room ID. Message will probably be taken from the [messages] stream.
  // void updateMessage(Message message, String roomId) async {
  //   if (firebaseUser == null) return;
  //   if (message.receiverId == firebaseUser!.uid) return;
  //
  //   await messagesRef.update(message.toJson(message)).match({'id': message.id});
  // }

  /// Sends a message to the Firestore. Accepts any partial message and a
  /// room ID. If arbitraty data is provided in the [partialMessage]
  /// does nothing.
  // void sendMessage(Message message, String roomId) async {
  //   if (firebaseUser == null) return;
  //
  //   await messagesRef.insert(message.toJson(message));
  //
  //   await chatRoomsRef
  //       .update({'updated_at': DateTime.timestamp()}).match({'id': message.id});
  // }

  /// Returns a stream of messages from Firebase for a given room.
  // Stream<List<Message>> messages(Room room) {
  //   Stream<List<Message>> chatsStream = messagesRef
  //       .stream(primaryKey: ['id'])
  //       .eq('room_id', room.id)
  //       .order('created_at')
  //       .map((chats) => chats.map((chat) => Message.fromDoc(chat)).toList());
  //
  //   return chatsStream;
  // }
}
