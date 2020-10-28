library fireflutter;

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/subjects.dart';

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
const ERROR_PERMISSION_RESTRICTED = 'ERROR_PERMISSION_RESTRICTED';

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
    this.noOfPostsPerFetch = 10,
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
  int noOfPostsPerFetch;
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

// class UserDocumentData {
//   String gender;
//   DateTime birthday;

//   Map<String, dynamic> props;

//   UserDocumentData(Map<String, dynamic> data)
//       : props = data,
//         gender = data['gender'] ?? '' {
//     if (data['birthday']?.seconds != null) {
//       birthday =
//           DateTime.fromMillisecondsSinceEpoch(data['birthday'].seconds * 1000);
//     }
//   }
// }

/// FireFlutter
///
/// Recommendation: instantiate `FireFlutter` class into a global variable
/// and use it all over the app runtime.
///
/// Warning: instantiate it after `initFirebase`. One of good places is insdie
/// the first widget loaded by `runApp()` or home screen.
class FireFlutter {
  /// User document at `/users/{uid}`
  ///
  /// Attention! [user] may not immediately be available after instantiating
  /// `FireFlutter` since [user] is only available after `authStateChanges`.
  /// And `authStateChanges` produce a `StreamSubscription` which should be
  /// unsubscribed when it does not needed anymore.
  /// For this reason, it is recommended to instantiating only once in global
  /// space of the app's runtime.
  ///
  /// This is firebase `User` object and it can be used as below.
  /// ```
  /// ff.user.updateProfile(displayName: nicknameController.text);
  /// ```
  User user;
  Map<String, dynamic> data = {};

  /// User document realtime update.
  StreamSubscription userSubscription;

  CollectionReference usersCol;

  bool enableNotification;

  /// [authStateChange] is a link to `FirebaseAuth.instance.authStateChanges()`
  ///
  /// You can do the following with [authStateChanges]
  /// ```
  /// StreamBuilder(
  ///   stream: ff.authStateChanges,
  ///   builder: (context, snapshot) { ... });
  /// ```
  Stream<User> authStateChanges;

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final String allTopic = 'allTopic';
  final String firebaseServerToken =
      'AAAAjdyAvbM:APA91bGist2NNTrrKTZElMzrNV0rpBLV7Nn674NRow-uyjG1-Uhh5wGQWyQEmy85Rcs0wlEpYT2uFJrSnlZywLzP1hkdx32FKiPJMI38evdRZO0x1vBJLc-cukMqZBKytzb3mzRfmrgL';

  /// Device token for Firebase messaging.
  ///
  /// This will be available by default on Android. For iOS, this will be only
  /// available when user accepts the permission request.
  String firebaseMessagingToken;

  BehaviorSubject<UserChangeType> userChange = BehaviorSubject.seeded(null);

  CollectionReference colPosts;

  /// [notificationHandler] will be invoked when a push notification arrives.
  NotificationHandler notificationHandler;

  /// [socialLoginHandler] will be invoked when a social login success or fail.
  SocialLoginErrorHandler socialLoginErrorHandler;
  SocialLoginSuccessHandler socialLoginSuccessHandler;

  FireFlutter() {
    print('FireFlutter');
  }

  Future<void> initFirebase() async {
    print('initFirebase');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
        Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  Future<void> init({
    bool enableNotification = false,
    Function notificationHandler,
    Function socialLoginSuccessHandler,
    Function socialLoginErrorHandler,
  }) async {
    this.enableNotification = enableNotification;
    this.notificationHandler = notificationHandler;
    this.socialLoginSuccessHandler = socialLoginSuccessHandler;
    this.socialLoginErrorHandler = socialLoginErrorHandler;
    await initFirebase();
    usersCol = FirebaseFirestore.instance.collection('users');
    colPosts = FirebaseFirestore.instance.collection('posts');
    initUser();
    initFirebaseMessaging();
  }

  initUser() {
    authStateChanges = FirebaseAuth.instance.authStateChanges();

    /// Note: listen handler will called twice if Firestore is working as offlien mode.
    authStateChanges.listen(
      (User user) {
        this.user = user;
        userChange.add(UserChangeType.auth);

        if (this.user == null) {
        } else {
          if (userSubscription != null) {
            userSubscription.cancel();
          }

          /// Note: listen handler will called twice if Firestore is working as offlien mode.
          userSubscription = usersCol.doc(user.uid).snapshots().listen(
            (DocumentSnapshot snapshot) {
              if (snapshot.exists) {
                data = snapshot.data();
                userChange.add(UserChangeType.document);
              }
            },
          );
        }
      },
    );
  }

  bool get isAdmin => this.data['isAdmin'] == true;

  /// Register into Firebase with email/password
  ///
  /// `authStateChanges` will fire event with login info immediately after the
  /// user register but before updating user displayName and photoURL meaning.
  /// This means, when `authStateChanges` event fired, the user have no
  /// `displayNamd` and `photoURL` in the User data.
  ///
  /// The `user` will have updated `displayName` and `photoURL` after
  /// registration and updating `displayName` and `photoURL`.
  ///
  /// Consideration: It cannot have a fixed data type since developers may want
  /// to add extra data on registration.
  Future<User> register(
    Map<String, dynamic> data, {
    Map<String, Map<String, dynamic>> meta,
  }) async {
    assert(data['photoUrl'] == null, 'Use photoURL');

    if (data['email'] == null) throw 'email_is_empty';
    if (data['password'] == null) throw 'password_is_empty';

    print('req: $data');

    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: data['email'],
      password: data['password'],
    );

    /// For registraion, it is okay that displayName or photoUrl is empty.
    await userCredential.user.updateProfile(
      displayName: data['displayName'],
      photoURL: data['photoURL'],
    );

    await userCredential.user.reload();
    user = FirebaseAuth.instance.currentUser;

    data.remove('email');
    data.remove('password');
    data.remove('displayName');
    data.remove('photoURL');

    /// Login Success
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user.uid);

    /// Set user extra information

    await userDoc.set(data);

    await updateUserMeta(meta);
    return user;
  }

  /// Update user meta data.
  ///
  /// It is merging with existing data.
  Future<void> updateUserMeta(Map<String, Map<String, dynamic>> meta) async {
    // Push default meta to user meta
    if (meta != null) {
      CollectionReference metaCol = usersCol.doc(user.uid).collection('meta');
      for (final key in meta.keys) {
        // Save data for each path.
        await metaCol.doc(key).set(meta[key], SetOptions(merge: true));
      }
    }
  }

  /// Logs out from Firebase Auth.
  Future<void> logout() {
    return FirebaseAuth.instance.signOut();
  }

  /// Logs into Firebase Auth.
  ///
  /// TODO Leave last login timestamp.
  /// TODO Increment login count
  /// TODO Leave last login device & IP address.
  Future<User> login({
    @required String email,
    @required String password,
    Map<String, Map<String, dynamic>> meta,
  }) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await updateUserMeta(meta);
    return userCredential.user;
  }

  /// Updates a user's profile data.
  ///
  /// After update, `user` will have updated `displayName` and `photoURL`.
  ///
  /// TODO Make a model(interface type)
  Future<void> updateProfile(
    Map<String, dynamic> data, {
    Map<String, Map<String, dynamic>> meta,
  }) async {
    if (data == null) return;
    if (data['displayName'] != null) {
      await user.updateProfile(displayName: data['displayName']);
    }
    if (data['photoURL'] != null) {
      await user.updateProfile(photoURL: data['photoURL']);
    }

    await user.reload();
    user = FirebaseAuth.instance.currentUser;
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    data.remove('displayName');
    data.remove('photoURL');
    await userDoc.set(data, SetOptions(merge: true));

    await updateUserMeta(meta);
  }

  /// Update user's profile photo
  ///
  ///
  Future<void> updatePhoto(String url) async {
    await user.updateProfile(photoURL: url);
    await user.reload();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> initFirebaseMessaging() async {
    if (enableNotification == false) return;
    await _firebaseMessagingRequestPermission();

    firebaseMessagingToken = await firebaseMessaging.getToken();
    print('token');
    print(firebaseMessagingToken);
    if (user != null) {
      updateToken(user);
    }

    /// subscribe to all topic
    await subscribeTopic(allTopic);

    _firebaseMessagingCallbackHandlers();
  }

  Future subscribeTopic(String topicName) async {
    print('subscribeTopic $topicName');
    try {
      await firebaseMessaging.subscribeToTopic(topicName);
    } catch (e) {
      print('subscribeTopic $topicName failed');
      print(e);
    }
  }

  Future unsubscribeTopic(String topicName) async {
    await firebaseMessaging.unsubscribeFromTopic(topicName);
  }

  /// Update push notification token to Firestore
  ///
  /// [user] is needed because when this method may be called immediately
  ///   after login but before `Firebase.AuthStateChange()` and when it happens,
  ///   the user appears not to be logged in even if the user already logged in.
  updateToken(User user) {
    if (firebaseMessagingToken == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('meta')
        .doc('tokens')
        .set({firebaseMessagingToken: true}, SetOptions(merge: true));
  }

  Future<void> _firebaseMessagingRequestPermission() async {
    /// Ask permission to iOS user for Push Notification.
    if (Platform.isIOS) {
      firebaseMessaging.onIosSettingsRegistered.listen((event) {
        // Do something after user accepts the request.
      });
      await firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    } else {
      /// For Android, no permission request is required. just get Push token.
      await firebaseMessaging.requestNotificationPermissions();
    }
  }

  /// Do some sanitizing and call `notificationHandler` to deliver
  /// notification to app.
  _notifyApp(Map<String, dynamic> message, NotificationType type) {
    Map<String, dynamic> notification =
        jsonDecode(jsonEncode(message['notification']));

    /// on `iOS`, `title`, `body` are insdie `message['aps']['alert']`.
    if (message['aps'] != null && message['aps']['alert'] != null) {
      notification = message['aps']['alert'];
    }

    /// on `iOS`, `message` has all the `data properties`.
    Map<String, dynamic> data = message['data'] ?? message;

    /// return if the senderUid is the owner.
    if (data != null && data['senderUid'] == user.uid) {
      return;
    }

    notificationHandler(notification, data, type);
  }

  /// TODO This is a package that handles only backend works.
  /// TODO This must not have any UI works like showing snackbar, modal dialogs. Do event handler.
  ///
  _firebaseMessagingCallbackHandlers() {
    /// Configure callback handlers for
    /// - foreground
    /// - background
    /// - exited
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage');
        _notifyApp(message, NotificationType.onMessage);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch');
        _notifyApp(message, NotificationType.onLaunch);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume');
        _notifyApp(message, NotificationType.onResume);
      },
    );
  }

  /// Display notification & navigate
  ///
  /// @note the data on `onMessage` is like below;
  ///   {notification: {title: This is title., body: Notification test.}, data: {click_action: FLUTTER_NOTIFICATION_CLICK}}
  /// But the data on `onResume` and `onLaunch` are like below;
  ///   { data: {click_action: FLUTTER_NOTIFICATION_CLICK} }
  // void _firebaseMessagingDisplayAndNavigate(
  //     Map<String, dynamic> message, bool display) {
  //   var notification = message['notification'];

  //   /// iOS 에서는 title, body 가 `message['aps']['alert']` 에 들어온다.
  //   if (message['aps'] != null && message['aps']['alert'] != null) {
  //     notification = message['aps']['alert'];
  //   }
  //   // iOS 에서는 data 속성없이, 객체에 바로 저장된다.
  //   var data = message['data'] ?? message;

  //   // return if the senderID is the owner.
  //   if (data != null && data['senderID'] == user.uid) {
  //     return;
  //   }

  //   if (display) {
  //     Get.snackbar(
  //       notification['title'].toString(),
  //       notification['body'].toString(),
  //       onTap: (_) {
  //         // print('onTap data: ');
  //         // print(data);
  //         Get.toNamed(data['route']);
  //       },
  //       mainButton: FlatButton(
  //         child: Text('Open'),
  //         onPressed: () {
  //           // print('mainButton data: ');
  //           // print(data);
  //           Get.toNamed(data['route']);
  //         },
  //       ),
  //     );
  //   } else {
  //     // TODO: Make it work.
  //     /// App will come here when the user open the app by tapping a push notification on the system tray.
  //     /// Do something based on the `data`.
  //     if (data != null && data['postId'] != null) {
  //       // Get.toNamed(Settings.postViewRoute, arguments: {'postId': data['postId']});
  //     }
  //   }
  // }

  Future<bool> sendNotification(
    title,
    body, {
    route,
    token,
    List<String> tokens,
    topic,
  }) async {
    if (enableNotification == false) return false;

    print('SendNotification');

    if (token == null && (tokens == null || tokens.length == 0)) return false;
    if (topic == null) return false;

    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    final req = [];
    if (token != null) req.add({'key': 'to', 'value': token});
    if (topic != null) req.add({'key': 'to', 'value': "/topics/" + topic});
    if (tokens != null) req.add({'key': 'registration_ids', 'value': tokens});

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "key=" + firebaseServerToken
    };

    /// TODO: Limit title in 128 chars and content 512 chars.
    req.forEach((el) async {
      final data = {
        "notification": {"body": body, "title": title},
        "priority": "high",
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "sound": 'default',
          "senderUid": user.uid,
          'route': route,
        }
      };
      data[el['key']] = el['value'];
      final encodeData = jsonEncode(data);
      var dio = Dio();

      print('try sending notification');
      try {
        var response = await dio.post(
          postUrl,
          data: encodeData,
          options: Options(
            headers: headers,
          ),
        );
        if (response.statusCode == 200) {
          // on success do
          print("notification success");
        } else {
          // on failure do
          print("notification failure");
        }
        print(response.data);
      } catch (e) {
        print('Dio error in sendNotification');
        print(e);
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  ///
  /// Forum Functions
  ///
  /////////////////////////////////////////////////////////////////////////////

  /// Get more posts from Firestore
  ///
  ///
  fetchPosts(ForumData forum) {
    if (forum.shouldNotFetch) return;
    print('category: ${forum.category}');
    print('should fetch?: ${forum.shouldFetch}');
    forum.fetchingPosts(RenderType.fetching);
    forum.pageNo++;
    print('pageNo: ${forum.pageNo}');

    /// Prepare query
    Query postsQuery = colPosts.where('category', isEqualTo: forum.category);
    postsQuery = postsQuery.orderBy('createdAt', descending: true);
    postsQuery = postsQuery.limit(forum.noOfPostsPerFetch);

    /// Fetch from the last post that had been fetched.
    if (forum.posts.isNotEmpty) {
      postsQuery = postsQuery.startAfter([forum.posts.last['createdAt']]);
    }

    /// Listen to coming posts.
    forum.postQuerySubscription =
        postsQuery.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.size == 0) return;
      snapshot.docChanges.forEach((DocumentChange documentChange) {
        final post = documentChange.doc.data();
        post['id'] = documentChange.doc.id;

        if (documentChange.type == DocumentChangeType.added) {
          /// [createdAt] is null on author mobile (since it is cached locally).
          if (post['createdAt'] == null) {
            forum.posts.insert(0, post);
          }

          /// [createdAt] is not null on other user's mobile and have the
          /// biggest value among other posts.
          else if (forum.posts.isNotEmpty &&
              post['createdAt'].microsecondsSinceEpoch >
                  forum.posts[0]['createdAt'].microsecondsSinceEpoch) {
            forum.posts.insert(0, post);
          }

          /// Or, it is a post that should be added at the bottom for infinite
          /// page scrolling.
          else {
            forum.posts.add(post);
          }

          /// TODO: have a placeholder for all the posts' comments change subscription.
          forum.commentsSubcriptions[post['id']] = FirebaseFirestore.instance
              .collection('posts/${post['id']}/comments')
              .orderBy('order', descending: true)
              .snapshots()
              .listen((QuerySnapshot snapshot) {
            snapshot.docChanges.forEach((DocumentChange commentsChange) {
              final commentData = commentsChange.doc.data();
              if (commentsChange.type == DocumentChangeType.added) {
                /// TODO For comments loading on post view, it does not need to loop.
                /// TODO Only for newly created comment needs to have loop and find a position to insert.
                if (post['comments'] == null) post['comments'] = [];
                int found = (post['comments'] as List).indexWhere(
                    (c) => c['order'].compareTo(commentData['order']) < 0);
                if (found == -1) {
                  post['comments'].add(commentData);
                } else {
                  post['comments'].insert(found, commentData);
                }
                forum.render(RenderType.commentCreate);
              }
            });
          });

          forum.fetchingPosts(RenderType.stopFetching);
        } else if (documentChange.type == DocumentChangeType.modified) {
          final int i = forum.posts.indexWhere((p) => p['id'] == post['id']);
          if (i > 0) {
            forum.posts[i] = post;
          }
        } else if (documentChange.type == DocumentChangeType.removed) {
          /// TODO: when post is deleted, also remove comment list subscription to avoid memory leak.
          forum.commentsSubcriptions[post['id']].cancel();
          forum.posts.removeWhere((p) => p['id'] == post['id']);
        } else {
          assert(false, 'This is error');
        }
      });
    });
  }

  /// [data] is the map to save into post document.
  ///
  /// `data['title']` and `data['content']` are needed to send push notification.
  Future editPost(Map<String, dynamic> data) async {
    /// TODO throw error if both of title and content are empty.

    if (data['id'] != null) {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await colPosts.doc(data['id']).set(
            data,
            SetOptions(merge: true),
          );
    } else {
      data.remove('id');
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await colPosts.add(data);

      sendNotification(
        data['title'],
        data['content'],
        route: data['category'],
        topic: "notification_post_" + data['category'],
      );
    }
  }

  Map<String, dynamic> getCommentParent(
      List<dynamic> comments, int parentIndex) {
    if (comments == null) return null;
    if (parentIndex == null) return null;

    return comments[parentIndex];
  }

  ///
  Future editComment(Map<String, dynamic> data) async {
    // final postDoc = postDocument(widget.post.id);
    final Map<String, dynamic> post = data['post'];
    final int parentIndex = data['parentIndex'];
    data.remove('post');
    data.remove('parentIndex');

    final commentCol = commentsCollection(post['id']);
    data.remove('postid');

    print('ref.path: ' + commentCol.path.toString());

    data['order'] = getCommentOrderOf(post, parentIndex);
    data['uid'] = user.uid;
    dynamic parent = getCommentParent(post['comments'], parentIndex);
    data['depth'] = parent == null ? 0 : data['depth'] = parent['depth'] + 1;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    print('comment create data: $data');
    await commentCol.add(data);

    // todo: check if new comment or edit comment
    sendCommentNotification(post, data);
  }

  Future sendCommentNotification(
      Map<String, dynamic> post, Map<String, dynamic> data) async {
    List<String> uids = [];
    List<String> uidsForNotification = [];

    // Add post owner's uid
    uids.add(post['uid']);

    /// Get ancestors
    List<dynamic> ancestors = getAncestors(
      post['comments'],
      data['order'],
    );

    /// Get ancestors uid and eliminate duplicate
    for (dynamic c in ancestors) {
      if (uids.indexOf(c['uid']) == -1) uids.add(c['uid']);
    }

    String topicKey = 'notification_comment_' + post['category'];

    // Only get uid that will recieve notification
    for (String uid in uids) {
      final docSnapshot =
          await usersCol.doc(uid).collection('meta').doc('public').get();

      if (!docSnapshot.exists) continue;

      Map<String, dynamic> publicData = docSnapshot.data();

      /// If the user has subscribed the forum, then it does not need to send notification again.
      if (publicData[topicKey] == true) {
        // uids.remove(uid);
        continue;
      }

      /// If the post owner has not subscribed to new comments under his post, then don't send notification.
      if (uid == post['uid'] && publicData['notifyPost'] != true) {
        // uids.remove(uid);
        continue;
      }

      /// If the user didn't subscribe for comments under his comments, then don't send notification.
      if (publicData['notifyComment'] != true) {
        // uids.remove(uid);
        continue;
      }
      uidsForNotification.add(uid);
    }

    // Get tokens
    List<String> tokens = [];
    for (var uid in uidsForNotification) {
      final docSnapshot =
          await usersCol.doc(uid).collection('meta').doc('tokens').get();
      if (!docSnapshot.exists) continue;
      Map<String, dynamic> tokensDoc = docSnapshot.data();

      /// TODO: Double check if it's working.
      tokens = [...tokens, ...tokensDoc.keys];

      // for (var token in tokensDoc.keys) {
      //   print(token);
      //   tokens.add(token);
      // }
    }

    print('tokens');
    print(tokens);

    print(uidsForNotification);

    /// send notification with tokens and topic.
    /// TODO: open the post.
    sendNotification(
      post['title'],
      data['content'],
      route: post['category'],
      topic: topicKey,
      tokens: tokens,
    );
  }

  /// Returns order of the new comment(to be created).
  ///
  /// [order] is;
  ///   - is the last comment's order when the created comment is the first depth comment of the post.
  ///   - the order of last comment of the sibiling.
  /// [depth] is the depth of newly created comment.
  getCommentOrder({
    String order,
    int depth: 0,
  }) {
    if (order == null) {
      return '999999.999.999.999.999.999.999.999.999.999.999.999';
    }
    List<String> parts = order.split('.');
    int n = int.parse(parts[depth]);
    parts[depth] = (n - 1).toString();
    for (int i = (depth + 1); i < parts.length; i++) {
      parts[i] = '999';
    }
    return parts.join('.');
  }

  /// Returns the ancestor comments of a comment.
  ///
  /// To get the ancestor comments based on the [order], it splits the parts of
  /// order and compare it to the comments in the middle of the comment thread.
  ///
  /// Use this method to get the parent comments of a comemnt.
  ///
  /// [order] is the comment to know its parent comemnts.
  ///
  /// If the comment is the first depth comment(comment right under post), then
  /// it will return empty array.
  ///
  /// The comment itself is not included in return array since it is itself. Not
  /// one of ancestor.
  ///
  List<dynamic> getAncestors(List<dynamic> comments, String order) {
    List<dynamic> ancestors = [];
    if (comments == null || comments.length == 0) return ancestors;
    List<String> parts = order.split('.');
    int len = parts.length;
    int depth = parts.indexWhere((element) => element == '999');
    if (depth == -1) depth = 11;

    List<String> orderOfAncestors = [];
    //// if [depth] is 0, then there is no ancestors.
    for (int i = 1; i < depth; i++) {
      List<String> newParts = List.from(parts);
      for (int j = i; j < len; j++) newParts[j] = '999';
      orderOfAncestors.add(newParts.join('.'));
    }

    for (String findOrder in orderOfAncestors) {
      for (var comment in comments) {
        if (comment['order'] == findOrder) {
          ancestors.add(comment);
        }
      }
    }
    return ancestors;

    // print('orderOfAncestors: $orderOfAncestors');

    // for (CommentModel comment in comments) {
    //   // List<String> commentParts = comment.order.split('.');
    //   for (int i = 0; i < parts.length; i++) {
    //     String compareOrder = parts[i];
    //   }
    // }
    // print(parts);
  }

  CollectionReference postsCollection() {
    return FirebaseFirestore.instance.collection('posts');
  }

  DocumentReference postDocument(String id) {
    return postsCollection().doc(id);
  }

  CollectionReference commentsCollection(String postId) {
    return postDocument(postId).collection('comments');
  }

  DocumentReference commentDocument(String postId, String commentId) {
    return commentsCollection(postId).doc(commentId);
  }

  /// Returns the order string of the new comment
  ///
  /// @TODO: Move this method to `functions.dart`.
  ///
  getCommentOrderOf(Map<String, dynamic> post, int parentIndex) {
    if (parentIndex == null) {
      /// If the comment to be created is the first depth comment,
      /// - and if there are no comments under post, then return default order
      /// - or return the last order.
      return getCommentOrder(
          order: (post['comments'] != null && post['comments'].length > 0)
              ? post['comments'].last['order']
              : null);
    }

    /// If it is the first depth of child.
    // if (parent == null) {
    //   return getCommentOrder(
    //       order: (widget.post['comments'] != null &&
    //               widget.post['comments'].length > 0)
    //           ? widget.post['comments'].last['order']
    //           : null);
    // }

    Map<String, dynamic> parent =
        getCommentParent(post['comments'], parentIndex);
    // post['comments'][parentIndex];

    int depth = parent['depth'];
    String depthOrder = parent['order'].split('.')[depth];
    print('depthOrder: $depthOrder');

    int i;
    for (i = parentIndex + 1; i < post['comments'].length; i++) {
      dynamic c = post['comments'][i];
      String findOrder = c['order'].split('.')[depth];
      if (depthOrder != findOrder) break;
    }

    final previousSiblingComment = post['comments'][i - 1];
    print(
        'previousSiblingComment: ${previousSiblingComment['content']}, ${previousSiblingComment['order']}');
    return getCommentOrder(
      order: previousSiblingComment['order'],
      depth: parent['depth'] + 1,
    );
  }

  /// Google sign-in
  ///
  ///
  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow

    await GoogleSignIn().signOut(); // to ensure you can sign in different user.

    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if (googleUser == null)
      return socialLoginErrorHandler(ERROR_SIGNIN_ABORTED);

    try {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      onSocialLogin(userCredential.user);
    } catch (e) {
      socialLoginErrorHandler(e);
    }
  }

  /// Facebook social login
  ///
  ///
  Future<void> signInWithFacebook() async {
    // Trigger the sign-in flow
    LoginResult result;
    try {
      await FacebookAuth.instance
          .logOut(); // Need to logout to avoid 'User logged in as different Facebook user'
      result = await FacebookAuth.instance.login();
      if (result == null || result.accessToken == null) {
        return socialLoginErrorHandler(ERROR_SIGNIN_ABORTED);
      }
    } catch (e) {
      socialLoginErrorHandler(e);
    }

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken.token);

    try {
      // Once signed in, return the UserCredential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      onSocialLogin(userCredential.user);
    } catch (e) {
      socialLoginErrorHandler(e);
    }
  }

  onSocialLogin(User user) async {
    final userRef =
        await usersCol.doc(user.uid).collection('meta').doc('public').get();

    if (!userRef.exists) {
      usersCol.doc(user.uid).collection('meta').doc('public').set({
        "notifyPost": true,
        "notifyComment": true,
      }, SetOptions(merge: true));
    }

    socialLoginSuccessHandler(user);
    onLogin(user);
  }

  onLogin(User user) {
    updateToken(user);
  }
}
