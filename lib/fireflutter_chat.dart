part of './fireflutter.dart';

const String ROOM_NOT_EXISTS = 'ROOM_NOT_EXISTS';
const String MODERATOR_NOT_EXISTS_IN_USERS = 'MODERATOR_NOT_EXISTS_IN_USERS';
const String YOU_ARE_NOT_MODERATOR = 'YOU_ARE_NOT_MODERATOR';
const String ONE_OF_USERS_ARE_BLOCKED = 'ONE_OF_USERS_ARE_BLOCKED';
const String USER_NOT_EXIST_IN_ROOM = 'USER_NOT_EXIST_IN_ROOM';
const String CHAT_DISPLAY_NAME_IS_EMPTY = 'CHAT_DISPLAY_NAME_IS_EMPTY';

/// ChatRoomInfo for global rooms and private room.
class ChatRoomInfo {
  String id;
  String title;
  String senderUid;
  String senderDisplayName;
  String senderPhotoURL;
  List<String> users;
  List<String> moderators;
  List<String> blockedUsers;
  List<String> newUsers;

  /// For global room info, [createdAt] is the timestamp of when the room was
  /// created. For, private room, it is when the message was sent.
  dynamic createdAt;
  String text;
  int newMessages;

  /// On my chat room list, it listens my chat room list document real time
  /// and [global] holds global room information.
  Map<String, dynamic> global;
  ChatRoomInfo({
    this.id,
    this.title,
    this.senderUid,
    this.senderDisplayName,
    this.senderPhotoURL,
    this.users,
    this.moderators,
    this.blockedUsers,
    this.newUsers,
    this.createdAt,
    this.text,
    this.newMessages,
    this.global,
  }) {
    // ?
    // blockedUsers = [];
  }

  /// Returns true if the room is existing.
  bool get exists => id != null;

  factory ChatRoomInfo.fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists == false) return null;
    Map<String, dynamic> info = snapshot.data();
    return ChatRoomInfo.fromData(info, snapshot.id);
  }

  factory ChatRoomInfo.fromData(Map<String, dynamic> info, [String id]) {
    if (info == null) return ChatRoomInfo();

    String _text = info['text'];
    return ChatRoomInfo(
      id: id,
      title: info['title'],
      senderUid: info['senderUid'],
      senderDisplayName: info['senderDisplayName'],
      senderPhotoURL: info['senderPhotoURL'],
      users: List<String>.from(info['users'] ?? []),
      moderators: List<String>.from(info['moderators'] ?? []),
      blockedUsers: List<String>.from(info['blockedUsers'] ?? []),
      newUsers: List<String>.from(info['newUsers'] ?? []),
      createdAt: info['createdAt'],
      text: _text,
      newMessages: info['newMessages'],
      global: info['global'],
    );
  }

  Map<String, dynamic> get data {
    return {
      if (id != null) 'id': id,
      'title': this.title,
      'senderUid': senderUid,
      'senderDisplayName': senderDisplayName,
      'senderPhotoURL': senderPhotoURL,
      'users': this.users,
      'moderators': this.moderators,
      'blockedUsers': this.blockedUsers,
      'newUsers': this.newUsers,
      'text': this.text,
      'createdAt': this.createdAt,
      'global': this.global
    };
  }

  @override
  String toString() {
    return data.toString();
  }
}

/// todo put chat protocol into { protocol: ... }, not in { text: ... }
class ChatProtocol {
  static String enter = 'ChatProtocol.enter';
  static String add = 'ChatProtocol.add';
  static String leave = 'ChatProtocol.leave';
  static String kickout = 'ChatProtocol.kickout';
  static String block = 'ChatProtocol.block';
  static String roomCreated = 'ChatProtocol.roomCreated';
}

class ChatBase {
  FireFlutter f;
  int page = 0;

  /// [noMoreMessage] becomes true when there is no more old messages to view.
  /// The app should display 'no more message' to user.
  bool noMoreMessage = false;

  /// Returns the room collection reference of `/chat/info/room-list`
  ///
  /// Do not confused with [myRoomListCol] which has the list of user's
  /// rooms while [globalRoomListCol] holds the whole existing chat rooms.
  CollectionReference get globalRoomListCol {
    return f.db.collection('chat').doc('global').collection('room-list');
  }

  /// Returns login user's room list collection `/chat/my-room-list/my-uid` reference.
  ///
  ///
  CollectionReference get myRoomListCol {
    return userRoomListCol(f.user.uid);
  }

  /// Return the collection of messages of the room id.
  CollectionReference messagesCol(String roomId) {
    return f.db.collection('chat').doc('messages').collection(roomId);
  }

  /// Returns my room list collection `/chat/my-room-list/{uid}` reference.
  ///
  CollectionReference userRoomListCol(String uid) {
    return f.db.collection('chat').doc('my-room-list').collection(uid);
  }

  /// Returns my room (that has last message of the room) document
  /// reference.
  DocumentReference userRoomDoc(String uid, String roomId) {
    return userRoomListCol(uid).doc(roomId);
  }

  /// Returns `/chat/info/room-list/{roomId}` document reference
  ///
  DocumentReference globalRoomDoc(String roomId) {
    return globalRoomListCol.doc(roomId);
  }

  /// Returns document reference of my room (that has last message of the room)
  ///
  /// `/chat/my-room-list/my-uid/{roomId}`
  DocumentReference myRoom(String roomId) {
    return myRoomListCol.doc(roomId);
  }

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
  Function __render;

  StreamSubscription _myRoomListSubscription;
  List<StreamSubscription> _roomSubscriptions = [];

  /// My room list including room id.
  List<ChatRoomInfo> rooms = [];
  String _order = "";
  ChatMyRoomList(
      {@required FireFlutter inject,
      @required Function render,
      String order = "createdAt"})
      : __render = render,
        _order = order {
    f = inject;
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

  /// Listen to global room updates.
  ///
  /// Listen for;
  /// - title changes,
  /// - users array changes,
  /// - and other properties change.
  listenRoomList() {
    _myRoomListSubscription = myRoomListCol
        .orderBy(_order, descending: true)
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final roomInfo = ChatRoomInfo.fromSnapshot(documentChange.doc);

        if (documentChange.type == DocumentChangeType.added) {
          rooms.add(roomInfo);

          /// Listen and merge room settings into room info.
          _roomSubscriptions.add(
            globalRoomDoc(roomInfo.id).snapshots().listen(
              (DocumentSnapshot snapshot) {
                int found = rooms.indexWhere((r) => r.id == roomInfo.id);
                rooms[found].global = snapshot.data();
                _notify();
              },
            ),
          );
        } else if (documentChange.type == DocumentChangeType.modified) {
          int found = rooms.indexWhere((r) => r.id == roomInfo.id);
          // If global room information exists, copy it to updated object to
          // maintain global room information.
          final global = rooms[found].global;
          rooms[found] = roomInfo;
          rooms[found].global = global;
        } else if (documentChange.type == DocumentChangeType.removed) {
          final int i = rooms.indexWhere((r) => r.id == roomInfo.id);
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

  /// This was for performance and is useless since the UI redraws the whole
  /// list anyway. This does not help any performance matter.
  /// TODO Remove this.
  // _overwrite(roomInfo) {
  //   int found = rooms.indexWhere((r) => r['id'] == roomInfo['id']);
  //   if (found > -1) {
  //     rooms[found].addAll(roomInfo);
  //   } else {
  //     rooms.add(roomInfo);
  //   }
  // }

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
  /// [render] will be called to notify chat room listener to re-render the screen.
  ///
  /// For one chat message sending,
  /// - [render] will be invoked 2 times on message sender's device due to offline support.
  /// - [render] will be invoked 1 times on receiver's device.
  ///
  /// [globalRoomChange] will be invoked when global chat room changes.
  ChatRoom({
    @required inject,
    Function render,
    Function globalRoomChange,
  })  : _render = render,
        _globalRoomChange = globalRoomChange {
    f = inject;
  }

  int _limit = 30;

  /// When user scrolls to top to view previous messages, the app fires the scroll event
  /// too much, so it fetches too many batches(pages) at one time.
  /// [_throttle] reduces the scroll event to relax the fetch racing.
  /// [_throttle] is working together with [_throttling]
  /// 1500ms is recommended.
  int _throttle = 1500;

  /// TODO overwrite this setting by Firestore setting.
  bool _throttling = false;

  ///
  Function _render;
  Function _globalRoomChange;

  StreamSubscription _chatRoomSubscription;
  StreamSubscription _currentRoomSubscription;
  StreamSubscription _globalRoomSubscription;

  /// Loaded the chat messages of current chat room.
  List<Map<String, dynamic>> messages = [];

  /// [loading] becomes true while the app is fetching more messages.
  /// The app should display loader while it is fetching.
  bool loading = false;

  /// Deprecated: since this produces flashing by rendering again.
  /// Most of the time, fetching finishes to quickly and users won't see the loader.
  /// This prevents loading disappearing too quickly.
  /// 500ms is recommended.
  // int _loadingTimeout = 500;

  /// Global room info (of current room)
  /// Use this to dipplay title or other information about the room.
  /// When `/chat/global/room-list/{roomId}` changes, it will be updated and calls render handler.
  ///
  ChatRoomInfo _info;

  /// Chat room properties
  String get id => _info?.id;
  String get title => _info?.title;
  List<String> get users => _info?.users;
  List<String> get moderators => _info?.moderators;
  List<String> get blockedUsers => _info?.blockedUsers;
  Timestamp get createdAt => _info.createdAt;

  /// push notification topic name
  String get topic => 'notifyChat-${this.id}';

  /// Enter chat room
  ///
  /// If [hatch] is set to true, then it will always create new room.
  /// null or empty string in [users] will be wiped out.
  Future<void> enter({String id, List<String> users, bool hatch = true}) async {
    String _id = id;

    if (users == null) users = [];
    // [users] has empty elem,ent, remove.
    users.removeWhere((element) => element == null || element == '');
    if (_id != null && users.length > 0)
      throw 'ONE_OF_ID_OR_USERS_MUST_BE_NULL';
    if (_id != null) {
      // Enter existing room
      // If permission-denied error happens here,
      // 1. Probably the room does not exists.
      // 2. Or, the login user is not a user of the room.
      // print(f.user.uid);
      // print(_id);
      _info = await getGlobalRoom(_id);
    } else {
      // Add login user(uid) into room users.
      users.add(f.user.uid);
      users = users.toSet().toList();
      if (hatch) {
        // Always create new room
        await ___create(users: users);
      } else {
        // Create room named based on the user
        // Users array can contain no user or only one user, or even many users.
        users.sort();
        String uids = users.join('');
        _id = md5.convert(utf8.encode(uids)).toString();
        try {
          _info = await getGlobalRoom(_id);
        } catch (e) {
          // If room does not exist(or it cannot read), then create.
          if (e.code == 'permission-denied') {
            // continue to create room
            await ___create(id: _id, users: users);
          } else {
            rethrow;
          }
        }
      }
    }

    // fetch latest messages
    fetchMessages();

    // Listening current global room for changes
    if (_globalRoomSubscription != null) _globalRoomSubscription.cancel();
    _globalRoomSubscription = globalRoomDoc(id).snapshots().listen((event) {
      _info = ChatRoomInfo.fromSnapshot(event);
      if (_globalRoomChange != null) {
        _globalRoomChange();
      }
    });

    // Listening current room in my room list.
    //
    // This will be notify chat room listener when chat room title changes, or new users enter, etc.
    if (_currentRoomSubscription != null) _currentRoomSubscription.cancel();
    _currentRoomSubscription =
        currentRoom.snapshots().listen((DocumentSnapshot doc) {
      // If the user got a message from a chat room where the user is currently in,
      // then, set `newMessages` to 0.
      final data = ChatRoomInfo.fromSnapshot(doc);
      if (data.newMessages > 0 && data.createdAt != null) {
        currentRoom.update({'newMessages': 0});
      }
    });
  }

  /// Returns the current room in my room list.
  DocumentReference get currentRoom => myRoom(id);

  Future<void> ___create({List<String> users, String id}) async {
    // String roomId = chatRoomId();
    // print('roomId: $roomId');

    final info = ChatRoomInfo(
      users: users,
      moderators: [f.user.uid],
      createdAt: FieldValue.serverTimestamp(),
    );

    DocumentReference doc;
    if (id == null) {
      doc = await globalRoomListCol.add(info.data);
    } else {
      doc = globalRoomListCol.doc(id);
      // Cannot create if the document is already exists.
      // Cannot update if the user is not one of the room user.
      await doc.set(info.data);
    }

    _info = ChatRoomInfo.fromSnapshot(await doc.get());

    await sendMessage(text: ChatProtocol.roomCreated);
  }

  /// Notify chat room listener to re-render the screen.
  _notify() {
    if (_render != null) _render();
  }

  /// Fetch previous messages
  fetchMessages() {
    if (_throttling || noMoreMessage) return;
    loading = true;
    _throttling = true;

    page++;
    if (page == 1) {
      // don't wait
      myRoom(_info.id).set({'newMessages': 0}, SetOptions(merge: true));
    }
    // print('fetchMessage(): _page: $_page');

    /// 처음에 가져 올 때에는 startAfter 가 없으므로, 나중에 새로 추가되는 채팅(도큐먼트)도 가져온다.
    /// 즉, 채팅을 새로 할 때 마다, 새로운 채팅은 맨 밑에 표시가 되고, 스크롤을 위로 할 때 마다
    /// 이 함수를 호출 해, 이전 글을 가져온다.
    /// 그리고, 채팅을 삭제하거나, 수정하면 실시간으로 화면에 보여준다.
    Query q = messagesCol(_info.id)
        .orderBy('createdAt', descending: true)

        /// todo make it optional from firestore settings.
        .limit(_limit); // 몇 개만 가져온다.

    if (messages.isNotEmpty) {
      q = q.startAfter([messages.first['createdAt']]);
    }

    _chatRoomSubscription = q.snapshots().listen((snapshot) {
      // print('fetchMessage() -> done: _page: $_page');
      // Block loading previous messages for some time.

      loading = false;
      Timer(Duration(milliseconds: _throttle), () => _throttling = false);
      // Timer(Duration(milliseconds: _loadingTimeout), () {
      //   loading = false;
      //   _notify();
      // });

      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final message = documentChange.doc.data();

        message['id'] = documentChange.doc.id;

        // print('type: ${documentChange.type}. ${message['text']}');

        /// 새로 채팅을 하거나, 이전 글을 가져 올 때, 새 채팅(생성)뿐만 아니라, 이전 채팅 글을 가져올 때에도 added 이벤트 발생.
        if (documentChange.type == DocumentChangeType.added) {
          // Two events will be fired on the sender's device.
          // First event has null of FieldValue.serverTimestamp()
          // Only one event will be fired on other user's devices.
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
            // if it's old message, add on top.
            messages.insert(0, message);
          }

          // if it is loading old messages
          // and if it has less messages than the limit
          // check if it is the very first message.
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

  unsubscribe() {
    _chatRoomSubscription.cancel();
    _currentRoomSubscription.cancel();
    _globalRoomSubscription.cancel();
  }

  /// Send chat message to the users in the room
  ///
  Future<Map<String, dynamic>> sendMessage({
    @required String text,
    Map<String, dynamic> extra,
  }) async {
    String name = f.user.displayName;
    if (name == null || name.trim() == '') {
      throw CHAT_DISPLAY_NAME_IS_EMPTY;
    }
    Map<String, dynamic> message = {
      'senderUid': f.user.uid,
      'senderDisplayName': name,
      'senderPhotoURL': f.user.photoURL,
      'text': text,

      // Time that this message(or last message) was created.
      'createdAt': FieldValue.serverTimestamp(),

      // Make [newUsers] empty string for re-setting(removing) from previous
      // message.
      'newUsers': [],

      if (extra != null) ...extra,
    };

    // message = mergeMap([message, extra]);

    // print('my uid: ${f.user.uid}');
    // print('users: ${this.users}');
    // print('extra: $extra');
    // print(message);
    // print(messagesCol(id).path);
    await messagesCol(_info.id).add(message);
    // print(message);
    message['newMessages'] =
        FieldValue.increment(1); // To increase, it must be an udpate.
    List<Future<void>> messages = [];

    /// Just incase there are duplicated UIDs.
    List<String> newUsers = [..._info.users.toSet()];

    /// Send a message to all users in the room.
    for (String uid in newUsers) {
      // print(chatUserRoomDoc(uid, info['id']).path);
      messages.add(
          userRoomDoc(uid, _info.id).set(message, SetOptions(merge: true)));
    }
    // print('send messages to: ${messages.length}');
    await Future.wait(messages);

    await f.sendNotification(
      '$name send you message.',
      text,
      id: id,
      screen: 'chatRoom',
      topic: topic,
    );

    return message;
  }

  /// Returns the room list info `/chat/room/list/{roomId}` document.
  ///
  /// If the room does exists, it returns null.
  /// The return value has `id` as its room id.
  ///
  /// Todo move this method to `ChatRoom`
  Future<ChatRoomInfo> getGlobalRoom(String roomId) async {
    DocumentSnapshot snapshot = await globalRoomDoc(roomId).get();
    return ChatRoomInfo.fromSnapshot(snapshot);
  }

  /// Add users to chat room
  ///
  /// Once user(s) has added, `who added who` messages will be delivered to all
  /// of room users. `newUsers` array will have the names of newly added users.
  ///
  /// [users] is a Map of user uid and user name. like `{uidA: 'nameA', ...}`
  ///
  /// See readme
  ///
  /// todo before adding user, check if the user is in `blockedUsers` property and if yes, throw a special error code.
  /// Todo move this method to `ChatRoom`
  /// todo use arrayUnion on Firestore
  Future<void> addUser(Map<String, String> users) async {
    /// Get latest info from server.
    /// There might be a chance that somehow `info['users']` is not upto date.
    /// So, it is safe to get room info from server.
    ChatRoomInfo _info = await getGlobalRoom(id);

    if (_info.blockedUsers != null && _info.blockedUsers.length > 0) {
      for (String blockedUid in _info.blockedUsers) {
        if (users.keys.contains(blockedUid)) {
          throw ONE_OF_USERS_ARE_BLOCKED;
        }
      }
    }

    List<String> newUsers = [
      ...List<String>.from(_info.users),
      ...users.keys.toList()
    ];
    newUsers = newUsers.toSet().toList();

    /// Update users first and then send chat messages to all users.
    /// In this way, newly entered/added user(s) will have the room in the my-room-list

    /// Update users array with added user.
    // print('users:');
    // print(newUsers);
    final doc = globalRoomDoc(_info.id);
    // print(doc.path);
    // print('my uid: ${f.user.uid}');
    // print(newUsers);
    // print((await doc.get()).data());
    await doc.update({'users': newUsers});

    /// Update last message of room users.
    // print('newUserNames:');
    // print(users.values.toList());
    await sendMessage(text: ChatProtocol.add, extra: {
      'newUsers': users.values.toList(),
    });
  }

  /// Returns a user's room (that has last message of the room) document
  /// reference.
  DocumentReference userRoomDoc(String uid, String roomId) {
    return userRoomListCol(uid).doc(roomId);
  }

  /// Moderator removes a user
  ///
  /// TODO [roomId] should be omitted.
  Future<void> blockUser(String uid, String userName) async {
    ChatRoomInfo info = await getGlobalRoom(id);
    info.users.remove(uid);

    // List<String> blocked = info.blocked ?? [];
    info.blockedUsers.add(uid);

    /// Update users and blockedUsers first to inform by sending a message.
    await globalRoomDoc(id)
        .update({'users': info.users, 'blockedUsers': info.blockedUsers});

    /// Inform all users.
    await sendMessage(text: ChatProtocol.block, extra: {'userName': userName});
  }

  /// Add a moderator
  ///
  /// Only moderator can add a user to moderator.
  /// The user must be included in `users` array.
  ///
  /// Todo move this method to `ChatRoom`
  Future<void> addModerator(String uid) async {
    ChatRoomInfo info = await getGlobalRoom(id);
    List<String> moderators = info.moderators;
    if (moderators.contains(f.user.uid) == false) throw YOU_ARE_NOT_MODERATOR;
    if (info.users.contains(uid) == false) throw MODERATOR_NOT_EXISTS_IN_USERS;
    moderators.add(uid);
    await globalRoomDoc(id).update({'moderators': moderators});
  }

  /// Remove a moderator.
  ///
  /// Only moderator can remove a moderator.
  ///
  /// Todo move this method to `ChatRoom`
  Future<void> removeModerator(String uid) async {
    ChatRoomInfo info = await getGlobalRoom(id);
    List<String> moderators = info.moderators;
    moderators.remove(uid);
    await globalRoomDoc(id).update({'moderators': moderators});

    // TODO inform it to all users by sending message
  }

  /// User go out of a room. The user is no longer part of the room
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
  Future<void> leave() async {
    ChatRoomInfo info = await getGlobalRoom(id);
    info.users.remove(f.user.uid);

    // Update last message of room users that the user is leaving.
    await sendMessage(
        text: ChatProtocol.leave, extra: {'userName': f.user.displayName});

    // Update users after removing himself.
    await globalRoomDoc(info.id).update({'users': info.users});

    // If I am the one who is willingly leave the room, then remove the
    // room in my-room-list.
    // print(chatMyRoom(roomId).path);
    await myRoom(id).delete();
  }

  /// Kicks a user out of the room.
  ///
  /// The user who was kicked can enter room again by himself. Somebody must add
  /// him.
  /// Only moderator can kick a user out.
  Future<void> kickout(String uid, String userName) async {
    ChatRoomInfo info = await getGlobalRoom(id);

    if (info.moderators.contains(f.user.uid) == false)
      throw YOU_ARE_NOT_MODERATOR;
    if (info.users.contains(uid) == false) throw USER_NOT_EXIST_IN_ROOM;
    info.users.remove(uid);

    // Update users after removing himself.
    await globalRoomDoc(info.id).update({'users': info.users});

    await sendMessage(
        text: ChatProtocol.leave, extra: {'userName': f.user.displayName});
  }

  /// Returns a room of a user.
  Future<ChatRoomInfo> getMyRoomInfo(String uid, String id) async {
    DocumentSnapshot snapshot = await userRoomDoc(uid, id).get();
    if (snapshot.exists) {
      return ChatRoomInfo.fromSnapshot(snapshot);
    } else {
      throw ROOM_NOT_EXISTS;
    }
  }

  /// Returns the last message of current room.
  ///
  /// User's private room has all the information of last chat.
  ///
  /// Note that `getMyRoomInfo()` returns `ChatRoomInfo` while `myRoom()`
  /// returns document reference.
  Future<ChatRoomInfo> get lastMessage => getMyRoomInfo(f.user.uid, id);
}
