part of './fireflutter.dart';

enum RenderType {
  postCreate,
  postUpdate,
  postDelete,
  commentCreate,
  commentUpdate,
  commentDelete,
  fileUpload,
  fileDelete,
  fetching,
  finishFetching
}

enum ForumStatus {
  noPosts,
  noMorePosts,
}

class NotificationOptions {
  static String notifyCommentsUnderMyPost = 'notifyPost';
  static String notifyCommentsUnderMyComment = 'notifyComment';

  /// "notifyPost_" + category
  static String post(String category) {
    return notifyCommentsUnderMyPost + '_' + category;
  }

  static String comment(String category) {
    return notifyCommentsUnderMyComment + '_' + category;
  }
}

/// For short
final String notifyPost = NotificationOptions.notifyCommentsUnderMyPost;
final String notifyComment = NotificationOptions.notifyCommentsUnderMyComment;

typedef Render = void Function(RenderType x);
const ERROR_SIGNIN_ABORTED = 'ERROR_SIGNIN_ABORTED';

enum UserChangeType { auth, document, register, profile, phoneNumber }
enum NotificationType { onMessage, onLaunch, onResume }

typedef NotificationHandler = void Function(Map<String, dynamic> messge,
    Map<String, dynamic> data, NotificationType type);

typedef SocialLoginErrorHandler = void Function(String error);
typedef SocialLoginSuccessHandler = void Function(User user);

class ForumData {
  /// [render] will be called when the view need to be re-rendered.
  ForumData({
    @required this.category,
    @required this.render,
    // this.noOfPostsPerFetch = 10, // Todo check if still needed
  });

  /// This is for infinite scrolling in forum screen.
  RenderType _inLoading;
  bool get inLoading => _inLoading == RenderType.fetching;

  /// Tell the app to update(re-render) the screen.
  ///
  /// This method should be invoked whenever forum data changes like fetching
  /// more posts, comment updating, voting, etc.
  updateScreen(RenderType x) {
    _inLoading = x;
    render(x);
  }

  ForumStatus status;
  bool get shouldFetch => inLoading == false && status == null;
  bool get shouldNotFetch => !shouldFetch;

  String category;
  // int pageNo = 0;
  // int noOfPostsPerFetch; // TODO: check if still needed
  List<Map<String, dynamic>> posts = [];
  Render render;

  StreamSubscription postQuerySubscription;
  Map<String, StreamSubscription> commentsSubcriptions = {};

  /// This must be called on Forum screen widget `dispose` to cancel the subscriptions.
  leave() {
    postQuerySubscription.cancel();

    // TODO: unsubscribe all comments list stream subscriptions.
    if (commentsSubcriptions.isNotEmpty) {
      commentsSubcriptions.forEach((key, value) {
        value.cancel();
      });
    }
  }
}

class VoteChoice {
  static String like = 'like';
  static String dislike = 'dislike';
}

/// todo separate this class to `chat.dart`
/// todo put chat protocol into { protocol: ... }, not in { text: ... }
class Chat {
  static String enter = 'Chat.enter';
  static String leave = 'Chat.leave';
  static String block = 'Chat.block';
  static String roomCreated = 'Chat.roomCreated';
}

/// Chat room list helper class
///
/// This is a completely independent helper class to help to list login user's room list.
/// You may rewrite your own helper class.
/// TODO reload(re-listen) When user login later or change account.
/// todo separate this class to `chat.dart`
class ChatMyRoomList {
  FireFlutter _ff;
  Function _render;
  StreamSubscription _myRoomListSubscription;
  List<StreamSubscription> _roomSubscriptions = [];
  List<Map<String, dynamic>> rooms = [];
  ChatMyRoomList({@required inject, @required render})
      : _ff = inject,
        _render = render {
    // print(' _ff.chatMyRoomListCol: ${_ff.chatMyRoomListCol.path}');
    _myRoomListSubscription =
        _ff.chatMyRoomListCol.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final roomInfo = documentChange.doc.data();
        roomInfo['id'] = documentChange.doc.id;
        // print(
        //     'type: ${documentChange.type}, length: ${documentChange.doc.data()}, roomInfo: $roomInfo');
        if (documentChange.type == DocumentChangeType.added) {
          // rooms.add(roomInfo);
          _overwrite(roomInfo);

          /// Apply room settings
          /// * My room list has only information about last message. It does not have room settings.
          /// * Listen and update room settings.
          _roomSubscriptions.add(_ff
              .chatRoomInfoDoc(roomInfo['id'])
              .snapshots()
              .listen((DocumentSnapshot snapshot) {
            roomInfo.addAll(snapshot.data());
            // print('Room settings; $roomInfo');
            _render();
          }));
        } else if (documentChange.type == DocumentChangeType.modified) {
          _overwrite(roomInfo);
          // final int i = rooms.indexWhere((r) => r['id'] == roomInfo['id']);
          // if (i > -1) {
          //   rooms[i] = roomInfo;
          // }
        } else if (documentChange.type == DocumentChangeType.removed) {
          final int i = rooms.indexWhere((r) => r['id'] == roomInfo['id']);
          if (i > -1) {
            rooms.removeAt(i);
          }
        } else {
          assert(false, 'This is error');
        }
      });
      _render();
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
    _myRoomListSubscription.cancel();
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
class ChatRoom {
  int _limit = 30;
  int page = 0;

  /// When user scrolls to top to view previous messages, the app fires the scroll event
  /// too much, so it fetches too many batches at one time.
  /// [_throttle] reduces the scroll event to relax the fetch racing.
  /// 1500ms is recommended.
  int _throttle = 1500;

  /// todo overwrite this setting by Firestore setting.
  bool _throttling = false;
  FireFlutter _ff;
  Function _render;
  String _roomId;
  StreamSubscription _subscription;
  List<Map<String, dynamic>> messages = [];

  /// [noMoreMessage] becomes true when there is no more old messages to view.
  /// The app should display 'no more message' to user.
  bool noMoreMessage = false;

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
  Map<String, dynamic> info;

  ChatRoom({@required inject, @required String roomId, @required render})
      : _ff = inject,
        _render = render,
        _roomId = roomId {
    /// Fetch when instance is created to fetch messages for the first time.
    fetchMessages();

    _ff.chatRoomInfoDoc(roomId).snapshots().listen((event) {
      info = event.data();
      info['id'] = event.id;
      // print('info: $info');
      // _render();
    });
  }

  fetchMessages() {
    if (_throttling || noMoreMessage) return;
    loading = true;
    _throttling = true;

    page++;
    // print('fetchMessage(): _page: $_page');

    /// 처음에 가져 올 때에는 startAfter 가 없으므로, 나중에 새로 추가되는 채팅(도큐먼트)도 가져온다.
    /// 즉, 채팅을 새로 할 때 마다, 새로운 채팅은 맨 밑에 표시가 되고, 스크롤을 위로 할 때 마다
    /// 이전 글을 가져온다.
    /// 그리고, 채팅을 삭제하거나, 수정하면 실시간으로 화면에 보여준다.
    Query q = _ff
        .chatMessagesCol(_roomId)
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
        _render();
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
              if (message['text'] == Chat.roomCreated) {
                noMoreMessage = true;
                print('-----> noMoreMessage: $noMoreMessage');
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
      _render();
    });
  }

  leave() {
    _subscription.cancel();
  }
}
