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
  stopFetching
}
typedef Render = void Function(RenderType x);
const ERROR_SIGNIN_ABORTED = 'ERROR_SIGNIN_ABORTED';

enum UserChangeType { auth, document, register, profile }
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
  fetchingPosts(RenderType x) {
    _inLoading = x;
    render(RenderType.stopFetching);
  }

  bool noMorePosts = false;
  bool get shouldFetch => inLoading == false && noMorePosts == false;
  bool get shouldNotFetch => !shouldFetch;

  String category;
  int pageNo = 0;
  // int noOfPostsPerFetch; // Todo check if still needed
  List<Map<String, dynamic>> posts = [];
  Render render;

  StreamSubscription postQuerySubscription;
  Map<String, StreamSubscription> commentsSubcriptions = {};

  /// This must be called on Forum screen widget `dispose` to cancel the subscriptions.
  leave() {
    postQuerySubscription.cancel();

    /// TODO: unsubscribe all commentsSubscriptions.
    if (commentsSubcriptions.isNotEmpty) {
      commentsSubcriptions.forEach((key, value) {
        value.cancel();
      });
    }
  }
}
