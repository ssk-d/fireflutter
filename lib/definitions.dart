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
}
