part of './fireflutter.dart';

class Base {
  final String allTopic = 'allTopic';

  /// To send push notification
  String firebaseServerToken;

  /// User document realtime update.
  StreamSubscription userSubscription;

  CollectionReference postsCol;
  CollectionReference usersCol;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  /// Device token for Firebase messaging.
  ///
  /// This will be available by default on Android. For iOS, this will be only
  /// available when user accepts the permission request.
  String firebaseMessagingToken;

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

  BehaviorSubject<UserChangeType> userChange = BehaviorSubject.seeded(null);

  /// [notification] will be fired whenever there is a push notification.
  // ignore: close_sinks
  PublishSubject notification = PublishSubject();

  Map<String, RemoteConfigValue> config;

  // PublishSubject configDownload = PublishSubject();

  Map<String, dynamic> _settings;
  // ignore: close_sinks
  BehaviorSubject settingsChange = BehaviorSubject.seeded(null);

  Map<String, dynamic> _translations;
  // ignore: close_sinks
  BehaviorSubject translationsChange = BehaviorSubject.seeded(null);

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

  Future<void> initFirebase() async {
    print('initFirebase');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
        Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

    usersCol = FirebaseFirestore.instance.collection('users');
    postsCol = FirebaseFirestore.instance.collection('posts');
  }

  /// Get config as String
  ///
  /// ```
  /// ff.getConfig('buttonName')
  /// ```
  String getConfig(String name) {
    return config[name].asString();
  }

  /// Get config as Map
  ///
  /// ```
  /// ff.getConfigAsMap('app_title')['ko']
  /// ```
  ///
  /// Returns null when the [name] does not exist or the value of the string is empty.
  Map<String, dynamic> getConfigAsMap(String name) {
    if (config[name] == null) return null;
    String str = config[name].asString();
    if (str == null || str == '') return null;
    return jsonDecode(str);
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

  Future subscribeTopic(String topicName) async {
    await FirebaseMessaging().subscribeToTopic(topicName);
  }

  Future unsubscribeTopic(String topicName) async {
    await FirebaseMessaging().unsubscribeFromTopic(topicName);
  }

  /// TODO: don't make it async/await since the app looks freezed on iOS.
  Future<void> initFirebaseMessaging() async {
    if (enableNotification == false) return;
    await _firebaseMessagingRequestPermission();

    firebaseMessagingToken = await firebaseMessaging.getToken();
    // print('token');
    // print(firebaseMessagingToken);
    if (user != null) {
      updateToken(user);
    }

    /// subscribe to all topic
    await subscribeTopic(allTopic);

    _firebaseMessagingCallbackHandlers();
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

    this
        .notification
        .add({'notification': notification, 'data': data, 'type': type});
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

    if (token == null &&
        (tokens == null || tokens.length == 0) &&
        topic == null) return false;
    // if (topic == null) return false;

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
        return true;
      } catch (e) {
        print('Dio error in sendNotification');
        print(e);
      }
    });
    return false;
  }

  Map<String, dynamic> getCommentParent(
      List<dynamic> comments, int parentIndex) {
    if (comments == null) return null;
    if (parentIndex == null) return null;

    return comments[parentIndex];
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

  onSocialLogin(User user) async {
    final userRef =
        await usersCol.doc(user.uid).collection('meta').doc('public').get();

    if (!userRef.exists) {
      usersCol.doc(user.uid).collection('meta').doc('public').set({
        "notifyPost": true,
        "notifyComment": true,
      }, SetOptions(merge: true));
    }

    onLogin(user);
  }

  onLogin(User user) {
    updateToken(user);
  }

  /// Pick an image from Camera or Gallery,
  /// then, compress
  /// then, fix rotation.
  ///
  /// 'permission-restricted' may be thrown if the app has no permission.
  Future<File> pickImage({
    ImageSource source,
    double maxWidth = 1024,
    int quality = 80,
  }) async {
    /// instantiate image picker.
    final picker = ImagePicker();

    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    /// request permission status.
    ///
    /// Android:
    ///   - Camera permission is automatically granted, meaning it will not ask for permission.
    ///     unless we specify the following on the AndroidManifest.xml:
    ///       - <uses-permission android:name="android.permission.CAMERA" />
    PermissionStatus permissionStatus = await permission.status;
    // print('permission status:');
    // print(permissionStatus);

    /// if permission is permanently denied,
    /// the only way to grant permission is changing in AppSettings.
    if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    /// alert the user if the permission is restricted.
    if (permissionStatus.isRestricted) {
      throw 'permission-restricted';
    }

    /// check if the app have the permission to access camera or photos
    if (permissionStatus.isUndetermined || permissionStatus.isDenied) {
      /// request permission if not granted, or user haven't chosen permission yet.
      // print('requesting permisssion again');
      // does not request permission again. (BUG: iOS)
      // await permission.request();
    }

    PickedFile pickedFile = await picker.getImage(
      source: source,
      maxWidth: maxWidth,
      imageQuality: quality,
    );

    // return null if user picked nothing.
    if (pickedFile == null) return null;
    // print('pickedFile.path: ${pickedFile.path} ');

    String localFile =
        await getAbsoluteTemporaryFilePath(getRandomString() + '.jpeg');
    File file = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    return file;
  }

  /// Syncronize the Firebase `settings` collection to `this.settings`.
  ///
  initSettings(Map<String, dynamic> defaultSettings) {
    _settings = defaultSettings;
    settingsChange.add(_settings);
  }

  ///
  ///
  initTranslations(Map<String, Map<String, String>> defaultTranslations) {
    translationsChange.add(defaultTranslations);
    FirebaseFirestore.instance
        .collection('translations')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      print('snapshot: ');
      if (snapshot.size == 0) return;
      Map lns = {};
      snapshot.docs.forEach((DocumentSnapshot document) {
        lns[document.id] = document.data();
      });

      translationsChange.add(lns);
    });
  }

  /// Get setting
  ///
  /// ```dart
  /// getSettings();          // returns the whole settings
  /// getSettings("app");     // returns the app document under /settings collection.
  /// ```
  ///
  getSetting([String name]) {
    if (name == null) return _settings;
    return _settings[name];
  }
}
