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

class Chat {
  static String enter = '[chat:enter]';
  static String leave = '[chat:leave]';
  static String block = '[chat:block]';
  static String roomCreated = '[chat:roomCreated]';
}

/// Chat room list helper class
///
/// This is a completely independent helper class to help to list login user's room list.
/// You may rewrite your own helper class.
/// TODO When user login later or change account.
class ChatMyRoomList {
  FireFlutter _ff;
  Function _render;
  StreamSubscription _subscription;
  List<Map<String, dynamic>> rooms = [];
  ChatMyRoomList({@required inject, @required render})
      : _ff = inject,
        _render = render {
    _subscription = _ff.chatMyRoomListCol.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final roomInfo = documentChange.doc.data();
        roomInfo['id'] = documentChange.doc.id;
        // print(
        //     'type: ${documentChange.type}, length: ${documentChange.doc.data()}, roomInfo: $roomInfo');
        if (documentChange.type == DocumentChangeType.added) {
          rooms.add(roomInfo);
        } else if (documentChange.type == DocumentChangeType.modified) {
          final int i = rooms.indexWhere((r) => r['id'] == roomInfo['id']);
          if (i > -1) {
            rooms[i] = roomInfo;
          }
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
  leave() {
    _subscription.cancel();
  }
}

/// Chat room message list helper class.
///
/// By defining this helper class, you may open more than one chat room at the same time.
/// ! 이전 목록을 가져오는 것은 .get() 으로 가져오고, listen 한다. 그리고 컬렉션에서는 맨 마지막 1개만 계속해서, 새로운 정보를 가져오면 된다.
class ChatMessages {
  FireFlutter _ff;
  Function _render;
  String _roomId;
  int _noOfMessagesPerFetch;
  StreamSubscription _subscription;
  List<Map<String, dynamic>> messages = [];
  ChatMessages(
      {@required inject,
      @required String roomId,
      @required render,
      noOfMessagesPerFetch = 30})
      : _ff = inject,
        _render = render,
        _roomId = roomId,
        _noOfMessagesPerFetch = noOfMessagesPerFetch {
    _subscription = _ff
        .chatMessagesCol(_roomId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final message = documentChange.doc.data();
        message['id'] = documentChange.doc.id;
        if (documentChange.type == DocumentChangeType.added) {
          ///
          messages.insert(0, message);
        } else if (documentChange.type == DocumentChangeType.modified) {
          /// Don't update here.
          // final int i = messages.indexWhere((r) => r['id'] == message['id']);
          // if (i > -1) {
          //   messages[i] = message;
          // }
        } else if (documentChange.type == DocumentChangeType.removed) {
          /// Don't remove here.
        } else {
          assert(false, 'This is error');
        }
      });
      _render();
    });
  }
  fetchMessages() async {
    QuerySnapshot snapshot = await _ff
        .chatMessagesCol(_roomId)
        .orderBy('createdAt', descending: true)
        .limit(_noOfMessagesPerFetch)
        .get();

    snapshot.docs.forEach((DocumentSnapshot doc) {
      /// from here
    });
  }

  leave() {
    _subscription.cancel();
  }
}
