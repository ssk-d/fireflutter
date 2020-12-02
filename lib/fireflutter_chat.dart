part of './fireflutter.dart';

class ChatRoomInfo {
  String id;
  String title;
  List<String> users;
  List<String> moderators;
  List<String> blockedUsers;
  dynamic createdAt;
  String text;
  int newMessages;
  ChatRoomInfo({
    this.id,
    this.title,
    this.users,
    this.moderators,
    this.createdAt,
    this.text,
    this.newMessages,
  }) {
    blockedUsers = [];
  }

  /// Returns true if the room is existing.
  bool get exists => id != null;

  factory ChatRoomInfo.fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists == false) return null;
    Map<String, dynamic> info = snapshot.data();
    return ChatRoomInfo.fromData(info, snapshot.id);
  }

  factory ChatRoomInfo.fromData(Map<String, dynamic> info, String id) {
    if (info == null) return ChatRoomInfo();
    return ChatRoomInfo(
      id: id,
      title: info['title'],
      users: List<String>.from(info['users'] ?? []),
      moderators: List<String>.from(info['moderators'] ?? []),
      createdAt: info['createdAt'],
      text: info['text'],
      newMessages: info['newMessages'],
    );
  }

  /// Returns without [id].
  Map<String, dynamic> get data {
    return {
      'title': this.title,
      'users': this.users,
      'moderators': this.moderators,
      'createdAt': this.createdAt,
    };
  }
}

/// todo put chat protocol into { protocol: ... }, not in { text: ... }
class ChatProtocol {
  static String enter = 'ChatProtocol.enter';
  static String leave = 'ChatProtocol.leave';
  static String kickout = 'ChatProtocol.kickout';
  static String block = 'ChatProtocol.block';
  static String roomCreated = 'ChatProtocol.roomCreated';
}

class ChatBase {
  int page = 0;

  /// [noMoreMessage] becomes true when there is no more old messages to view.
  /// The app should display 'no more message' to user.
  bool noMoreMessage = false;

  text(Map<String, dynamic> message) {
    String text = message['text'] ?? '';

    if (text == ChatProtocol.roomCreated) {
      text = 'Chat room created. ';
    }

    /// Display `no more messages` only when user scrolled up to see more messages.
    else if (page > 1 && noMoreMessage) {
      text = 'No more messages. ';
    } else if (text == ChatProtocol.enter) {
      // print(message);
      text = "${message['senderDisplayName']} invited ${message['newUsers']}";
    }
    return text;
  }
}

/// Chat room list helper class
///
/// This is a completely independent helper class to help to list login user's room list.
/// You may rewrite your own helper class.
class ChatMyRoomList extends ChatBase {
  FireFlutter _ff;
  Function __render;

  StreamSubscription _myRoomListSubscription;
  List<StreamSubscription> _roomSubscriptions = [];

  /// My room list including room id.
  /// TODO convert it to List<ChatRoomInfo>
  List<Map<String, dynamic>> rooms = [];
  String _order = "";
  ChatMyRoomList(
      {@required FireFlutter inject,
      @required Function render,
      String order = "createdAt"})
      : _ff = inject,
        __render = render,
        _order = order {
    listenRoomList();
  }

  _notify() {
    if (__render != null) __render();
  }

  reset({String order}) {
    if (order != null) {
      _order = order;
    }

    rooms = [];
    _myRoomListSubscription.cancel();
    listenRoomList();
  }

  ///
  listenRoomList() {
    _myRoomListSubscription = _ff.chatMyRoomListCol
        .orderBy(_order, descending: true)
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final roomInfo = documentChange.doc.data();
        roomInfo['id'] = documentChange.doc.id;
        if (documentChange.type == DocumentChangeType.added) {
          _overwrite(roomInfo);

          /// Listen and merge room settings into room info.
          _roomSubscriptions.add(
            _ff.chatRoomInfoDoc(roomInfo['id']).snapshots().listen(
              (DocumentSnapshot snapshot) {
                roomInfo.addAll(snapshot.data());
                _notify();
              },
            ),
          );
        } else if (documentChange.type == DocumentChangeType.modified) {
          _overwrite(roomInfo);
        } else if (documentChange.type == DocumentChangeType.removed) {
          final int i = rooms.indexWhere((r) => r['id'] == roomInfo['id']);
          if (i > -1) {
            rooms.removeAt(i);
          }
        } else {
          assert(false, 'This is error');
        }
      });
      _notify();
    });
  }

  _overwrite(roomInfo) {
    int found = rooms.indexWhere((r) => r['id'] == roomInfo['id']);
    if (found > -1) {
      rooms[found].addAll(roomInfo);
    } else {
      rooms.add(roomInfo);
    }
  }

  leave() {
    if (_myRoomListSubscription != null) _myRoomListSubscription.cancel();
    if (_roomSubscriptions.isNotEmpty) {
      _roomSubscriptions.forEach((element) {
        element.cancel();
      });
    }
  }
}

/// Chat room message list helper class.
///
/// By defining this helper class, you may open more than one chat room at the same time.
/// todo separate this class to `chat.dart`
class ChatRoom extends ChatBase {
  int _limit = 30;

  /// When user scrolls to top to view previous messages, the app fires the scroll event
  /// too much, so it fetches too many batches at one time.
  /// [_throttle] reduces the scroll event to relax the fetch racing.
  /// 1500ms is recommended.
  int _throttle = 1500;

  /// todo overwrite this setting by Firestore setting.
  bool _throttling = false;
  FireFlutter _ff;
  Function __render;

  /// The room id.
  String _id;
  StreamSubscription _subscription;
  List<Map<String, dynamic>> messages = [];

  /// [loading] becomes true while the app is fetching more messages.
  /// The app should display loader while it is fetching.
  bool loading = false;

  /// Most of the time, fetching finishes to quickly and users won't see the loader.
  /// This prevents loading disappearing too quickly.
  /// 500ms is recommended.
  int _loadingTimeout = 500;

  /// Chat room info
  /// Use this to dipplay title or other information about the room.
  /// When `/chat/info/room-list/{roomId}` changes, it will be updated and calls render handler.
  ChatRoomInfo info;

  /// Temporary variable to create a chat room
  List<String> _users;

  /// Temporary variable to set room title on room creation
  String _title;

  /// [users] is the uids of users
  /// [title] is to set the title of the newly created room.
  ChatRoom({
    @required inject,
    String id,
    List<String> users,
    String title = '',
    Function render,
  })  : _ff = inject,
        __render = render,
        _id = id,
        _users = users,
        _title = title {
    init();
  }

  init() async {
    if (_id != null) {
      try {
        ChatRoomInfo room = await getRoomInfo(_id);
        if (room.exists) {
          _enterChatRoom();
          return;
        }
      } catch (e) {
        if (e.code == 'permission-denied') {
          /// continue to create room
        } else {
          rethrow;
        }
      }
    }

    /// If chat id was not given on instantiating the ChatRoom class,
    /// then it will create a room.

    if (_users == null) _users = [_ff.user.uid];
    ChatRoomInfo _info = await create(users: _users, title: _title, id: _id);
    _id = _info.id;

    _enterChatRoom();
  }

  _notify() {
    if (__render != null) __render();
  }

  /// Fetch chat messages (of the first page or last messages), then listen to
  /// changes of room information.
  _enterChatRoom() {
    /// Fetch when instance is created to fetch messages for the first time.
    fetchMessages();

    roomInfoDoc(_id).snapshots().listen((event) {
      info = ChatRoomInfo.fromSnapshot(event);
      _notify();
    });
  }

  fetchMessages() {
    if (_throttling || noMoreMessage) return;
    loading = true;
    _throttling = true;

    page++;
    if (page == 1) {
      _ff
          .chatMyRoom(_id)
          .set({'newMessages': 0}, SetOptions(merge: true)); // don't wait.
    }
    // print('fetchMessage(): _page: $_page');

    /// 처음에 가져 올 때에는 startAfter 가 없으므로, 나중에 새로 추가되는 채팅(도큐먼트)도 가져온다.
    /// 즉, 채팅을 새로 할 때 마다, 새로운 채팅은 맨 밑에 표시가 되고, 스크롤을 위로 할 때 마다
    /// 이 함수를 호출 해, 이전 글을 가져온다.
    /// 그리고, 채팅을 삭제하거나, 수정하면 실시간으로 화면에 보여준다.
    Query q = messagesCol(_id)
        .orderBy('createdAt', descending: true)

        /// todo make it optional from firestore settings.
        .limit(_limit); // 몇 개만 가져온다.

    if (messages.isNotEmpty) {
      q = q.startAfter([messages.first['createdAt']]);
    }

    _subscription = q.snapshots().listen((snapshot) {
      // print('fetchMessage() -> done: _page: $_page');
      Timer(Duration(milliseconds: _throttle), () => _throttling = false);
      Timer(Duration(milliseconds: _loadingTimeout), () {
        loading = false;
        _notify();
      });

      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final message = documentChange.doc.data();

        message['id'] = documentChange.doc.id;

        // print('type: ${documentChange.type}. ${message['text']}');

        /// 새로 채팅을 하거나, 이전 글을 가져 올 때, 생성이 아니라, 가져올 때에도 added 이벤트 발생.
        if (documentChange.type == DocumentChangeType.added) {
          /// FieldValue.serverTimestamp() 를 채팅을 작성할 때, listen 이벤트를 두번 발생시킨다.
          /// 처음 이벤트는 `added` 이며, 값은 null 이다.
          /// 두번째 이벤트는 `modified` 이며, 실제 시간 값을 가지고 있다.
          if (message['createdAt'] == null) {
            messages.add(message);
          }

          /// if it's new message, add at bottom.
          else if (messages.length > 0 &&
              messages[0]['createdAt'] != null &&
              message['createdAt'].microsecondsSinceEpoch >
                  messages[0]['createdAt'].microsecondsSinceEpoch) {
            messages.add(message);
          } else {
            /// if it's old message, add on top.
            messages.insert(0, message);
          }

          /// if it is loading old messages
          /// and if it has less messages than the limit
          /// check if it is the very first message.
          if (message['createdAt'] != null) {
            if (snapshot.docs.length < _limit) {
              if (message['text'] == ChatProtocol.roomCreated) {
                noMoreMessage = true;
                // print('-----> noMoreMessage: $noMoreMessage');
              }
            }
          }
        } else if (documentChange.type == DocumentChangeType.modified) {
          final int i = messages.indexWhere((r) => r['id'] == message['id']);
          if (i > -1) {
            messages[i] = message;
          }
        } else if (documentChange.type == DocumentChangeType.removed) {
          /// 총 10 개의 글을 listen 하고 있는 경우, 새 글 1 개가 추가되면, 큐의 맨 처음의 글은 사라진다.
          /// 즉, 새로 글 1 개가 추가되면 기존의 10개에서 1개를 잘라내고, 9개가 남는다.
          /// 그리고 새로 추가된 1개를 포함해서, 10개를 유지한다.
          /// 이 때, 실제 DB 에서 삭제된 것은 아니다. 이 부분을 매우 조심해야 한다.
          /// 따라서, 실전 코딩에서는 채팅(글)이 삭제되었다고 해서, 실제로 삭제하지 않고, '내용만 삭제되었습니다'로 변경한다.
          // final int i = messages.indexWhere((r) => r['id'] == message['id']);
          // if (i > -1) {
          //   messages.removeAt(i);
          // }
        } else {
          assert(false, 'This is error');
        }
      });
      _notify();
    });
  }

  leave() {
    _subscription.cancel();
  }

  /// [users] is a list of users' uid to create chat room with.
  /// [title] is the title of the room.
  /// [id] is the room id to create.
  /// The login user who creates the room becomes the moderator.
  Future<ChatRoomInfo> create(
      {List<String> users, String title, String id}) async {
    if (users == null) users = [];

    /// Add login user's uid.
    users.add(_ff.user.uid);
    users = [
      ...{...users}
    ];

    // String roomId = chatRoomId();
    // print('roomId: $roomId');

    ChatRoomInfo info = ChatRoomInfo(
      users: users,
      title: title,
      moderators: [_ff.user.uid],
      createdAt: FieldValue.serverTimestamp(),
    );
    if (id == null) {
      DocumentReference doc = await roomListCol.add(info.data);
      info.id = doc.id;
    } else {
      await roomListCol.doc(id).set(info.data);
      info.id = id;
    }

    sendMessage(info: info, text: ChatProtocol.roomCreated);
    return info;
  }

  /// Returns the room collection reference
  ///
  /// Do not confused with [chatMyRoomListCol] which has the list of user's
  /// rooms while [chatRoomListCol] holds the whole existing chat rooms.
  CollectionReference get roomListCol {
    return _ff.db.collection('chat').doc('info').collection('room-list');
  }

  /// Return the collection of messages of the room id.
  CollectionReference messagesCol(String roomId) {
    return _ff.db.collection('chat').doc('messages').collection(roomId);
  }

  /// Returns my room list collection `/chat/my-room-list/{uid}` reference.
  ///
  CollectionReference userRoomListCol(String uid) {
    return _ff.db.collection('chat').doc('my-room-list').collection(uid);
  }

  /// Returns my room (that has last message of the room) document
  /// reference.
  DocumentReference chatUserRoomDoc(String uid, String roomId) {
    return userRoomListCol(uid).doc(roomId);
  }

  Future<Map<String, dynamic>> sendMessage({
    @required ChatRoomInfo info,
    @required String text,
    Map<String, dynamic> extra,
  }) async {
    Map<String, dynamic> message = {
      'senderUid': _ff.user.uid,
      'senderDisplayName': _ff.user.displayName,
      'senderPhotoURL': _ff.user.photoURL,
      'text': text,

      /// Time that this message(or last message) was created.
      'createdAt': FieldValue.serverTimestamp(),

      /// Make [newUsers] empty string for re-setting previous information.
      'newUsers': [],

      if (extra != null) ...extra,
    };

    // print('my uid: ${user.uid}');
    // print('users: ${info['users']}');
    // print(chatMessagesCol(info['id']).path);
    await messagesCol(info.id).add(message);
    message['newMessages'] =
        FieldValue.increment(1); // To increase, it must be an udpate.
    List<Future<void>> messages = [];

    /// Just incase there are duplicated UIDs.
    List<String> users = [...info.users.toSet()];

    for (String uid in users) {
      // print(chatUserRoomDoc(uid, info['id']).path);
      messages.add(
          chatUserRoomDoc(uid, info.id).set(message, SetOptions(merge: true)));
    }
    // print('send messages to: ${messages.length}');
    await Future.wait(messages);
    return message;
  }

  /// Returns the room list info `/chat/room/list/{roomId}` document.
  ///
  /// If the room does exists, it returns null.
  /// The return value has `id` as its room id.
  ///
  /// Todo move this method to `ChatRoom`
  Future<ChatRoomInfo> getRoomInfo(String roomId) async {
    DocumentSnapshot snapshot = await roomInfoDoc(roomId).get();
    return ChatRoomInfo.fromSnapshot(snapshot);
  }

  /// Returns `/chat/room/list/{roomId}` document reference
  ///
  /// Do not confused with [chatMyRoomInfo] which has the last chat message of
  /// the chat room of the user's (indivisual) room list, while [chatRoomInfo]
  /// has the room information which has `moderators`, `users` and all about the
  /// chat room information.
  DocumentReference roomInfoDoc(String roomId) {
    return roomListCol.doc(roomId);
  }

  /// Add users to chat room
  ///
  /// Once a user has entered, `who added who` messages will be updated to all of
  /// room users.
  ///
  /// [users] is a Map of user uid and user name.
  ///
  /// See readme
  ///
  /// todo before adding user, check if the user is in `blockedUsers` property and if yes, throw a special error code.
  /// Todo move this method to `ChatRoom`
  /// todo use arrayUnion on Firestore
  Future<void> addUser(String roomId, Map<String, String> users) async {
    /// Get new info from server.
    /// There might be mistake that somehow `info['users']` is not upto date.
    /// So, it is safe to get room info from server.
    ChatRoomInfo info = await getRoomInfo(roomId);

    List<String> newUsers = [
      ...List<String>.from(info.users),
      ...users.keys.toList()
    ];
    newUsers = [
      ...{...newUsers}
    ];

    /// Update users first and then send chat messages to all users.
    /// In this way, newly entered/added user(s) will have the room in the my-room-list

    /// Update users array with added user.
    // print('users:');
    // print(newUsers);
    await roomInfoDoc(info.id).update({'users': newUsers});
    info.users = newUsers;

    /// Update last message of room users.
    // print('newUserNames:');
    // print(users.values.toList());
    await sendMessage(info: info, text: ChatProtocol.enter, extra: {
      'newUsers': users.values.toList(),
    });
  }

  /// Returns my room (that has last message of the room) document
  /// reference.
  DocumentReference userRoomDoc(String uid, String roomId) {
    return userRoomListCol(uid).doc(roomId);
  }

  /// Moderator removes a user
  ///
  /// TODO [roomId] should be omitted.
  Future<void> blockUser(String roomId, String uid, String userName) async {
    ChatRoomInfo info = await getRoomInfo(roomId);
    info.users.remove(uid);

    // List<String> blocked = info.blocked ?? [];
    info.blockedUsers.add(uid);

    /// Update users and blockedUsers first to inform by sending a message.
    await roomInfoDoc(info.id)
        .update({'users': info.users, 'blockedUsers': info.blockedUsers});

    await sendMessage(
        info: info, text: ChatProtocol.block, extra: {'userName': userName});
  }

  /// Add a moderator
  ///
  /// Only moderator can add a user to moderator.
  /// The user must be included in `users` array.
  ///
  /// Todo move this method to `ChatRoom`
  Future<void> addModerator(String uid) async {
    ChatRoomInfo info = await getRoomInfo(_id);
    List<String> moderators = info.moderators;
    moderators.add(uid);
    await roomInfoDoc(_id).update({'moderators': moderators});
  }

  /// Remove a moderator.
  ///
  /// Only moderator can remove a moderator.
  ///
  /// Todo move this method to `ChatRoom`
  Future<void> removeModerator(String uid) async {
    ChatRoomInfo info = await getRoomInfo(_id);
    List<String> moderators = info.moderators;
    moderators.remove(uid);
    await roomInfoDoc(_id).update({'moderators': moderators});
  }

  /// User leaves a room.
  ///
  /// Once a user has left, the user will not be able to update last message of
  /// room users. So, before leave, it should update 'leave' last message of room users.
  ///
  /// For moderator to block user, see [chatBlockUser]
  ///
  /// [roomId] is the chat room id.
  /// [uid] is the user to be kicked out by moderator.
  /// [userName] is the userName to leave or to be kicked out. and it is required.
  /// [text] is the text to send to all users.
  ///
  /// This method throws permission error when a user try to remove another user.
  /// But admin can remove other users.
  ///
  ///
  /// TODO if moderator is leaving, it needs to remove the uid from moderator.
  /// TODO if the last moderator tries to leave, ask the moderator to add another user to moderator.
  /// TODO When a user(or a moderator) leaves the room and there is no user left in the room,
  /// then move the room information from /chat/info/room-list to /chat/info/deleted-room-list.
  Future<void> chatRoomLeave(String roomId) async {
    ChatRoomInfo info = await getRoomInfo(roomId);
    info.users.remove(_ff.user.uid);

    /// Update last message of room users that the user is leaving.
    await sendMessage(
        info: info,
        text: ChatProtocol.leave,
        extra: {'userName': _ff.user.displayName});

    /// Update users and blockedUsers first and if there is error return before sending messages to all users.
    await roomInfoDoc(info.id).update({'users': info.users});

    /// If I am the one who is willingly leave the room, then remove the room in my-room-list.
    // print(chatMyRoom(roomId).path);
    await myRoom(roomId).delete();
  }

  /// Returns document reference of my room (that has last message of the room)
  ///
  /// `/chat/my-room-list/my-uid/{roomId}`
  DocumentReference myRoom(String roomId) {
    return myRoomListCol.doc(roomId);
  }

  /// Returns login user's room list collection `/chat/my-room-list/my-uid` reference.
  ///
  ///
  CollectionReference get myRoomListCol {
    return userRoomListCol(_ff.user.uid);
  }

  /// User leaves a room.
  ///
  /// Once a user has left, the user will not be able to update last message of
  /// room users. So, before leave, it should update 'leave' last message of room users.
  ///
  /// For moderator to block user, see [chatBlockUser]
  ///
  /// [roomId] is the chat room id.
  /// [uid] is the user to be kicked out by moderator.
  /// [userName] is the userName to leave or to be kicked out. and it is required.
  /// [text] is the text to send to all users.
  ///
  /// This method throws permission error when a user try to remove another user.
  /// But admin can remove other users.
  ///
  ///
  /// TODO rename to `leave()`
  /// TODO remove [roomId]
  /// TODO if moderator is leaving, it needs to remove the uid from moderator.
  /// TODO if the last moderator tries to leave, ask the moderator to add another user to moderator.
  /// TODO When a user(or a moderator) leaves the room and there is no user left in the room,
  /// then move the room information from /chat/info/room-list to /chat/info/deleted-room-list.
  Future<void> roomLeave(String roomId) async {
    ChatRoomInfo info = await getRoomInfo(roomId);
    info.users.remove(_ff.user.uid);

    /// Update last message of room users that the user is leaving.
    await sendMessage(
        info: info,
        text: ChatProtocol.leave,
        extra: {'userName': _ff.user.displayName});

    /// Update users and blockedUsers first and if there is error return before sending messages to all users.
    await roomInfoDoc(info.id).update({'users': info.users});

    /// If I am the one who is willingly leave the room, then remove the room in my-room-list.
    // print(chatMyRoom(roomId).path);
    await myRoom(roomId).delete();
  }
}
