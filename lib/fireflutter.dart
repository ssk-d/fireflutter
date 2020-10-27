library fireflutter;

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';

enum UserChange { auth, document, register, profile }

class UserDocumentData {
  String gender;
  DateTime birthday;

  UserDocumentData(Map<String, dynamic> data) : gender = data['gender'] ?? '' {
    if (data['birthday']?.seconds != null) {
      birthday =
          DateTime.fromMillisecondsSinceEpoch(data['birthday'].seconds * 1000);
    }
  }
}

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
  UserDocumentData data = UserDocumentData({});

  /// User document realtime update.
  StreamSubscription userSubscription;

  CollectionReference usersCol;

  bool enableNotification = false;

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
  String firebaseMessagingToken;

  BehaviorSubject<UserChange> userChange = BehaviorSubject.seeded(null);

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

  Future<void> init({bool enableNotification}) async {
    this.enableNotification = enableNotification;
    await initFirebase();
    usersCol = FirebaseFirestore.instance.collection('users');
    initUser();
    initNotification();
  }

  initUser() {
    authStateChanges = FirebaseAuth.instance.authStateChanges();

    /// Note: listen handler will called twice if Firestore is working as offlien mode.
    authStateChanges.listen(
      (User user) {
        this.user = user;
        userChange.add(UserChange.auth);

        if (this.user == null) {
        } else {
          if (userSubscription != null) {
            userSubscription.cancel();
          }

          /// Note: listen handler will called twice if Firestore is working as offlien mode.
          userSubscription = usersCol.doc(user.uid).snapshots().listen(
            (DocumentSnapshot snapshot) {
              if (snapshot.exists) {
                data = UserDocumentData(snapshot.data());
                userChange.add(UserChange.document);
              }
            },
          );
        }
      },
    );
  }

  initNotification() {
    if (enableNotification == false) return;
    initFirebaseMessaging();
  }

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

  _firebaseMessagingCallbackHandlers() {
    /// Configure callback handlers for
    /// - foreground
    /// - background
    /// - exited
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        _firebaseMessagingDisplayAndNavigate(message, true);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _firebaseMessagingDisplayAndNavigate(message, false);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _firebaseMessagingDisplayAndNavigate(message, false);
      },
    );
  }

  /// Display notification & navigate
  ///
  /// @note the data on `onMessage` is like below;
  ///   {notification: {title: This is title., body: Notification test.}, data: {click_action: FLUTTER_NOTIFICATION_CLICK}}
  /// But the data on `onResume` and `onLaunch` are like below;
  ///   { data: {click_action: FLUTTER_NOTIFICATION_CLICK} }
  void _firebaseMessagingDisplayAndNavigate(
      Map<String, dynamic> message, bool display) {
    var notification = message['notification'];

    /// iOS 에서는 title, body 가 `message['aps']['alert']` 에 들어온다.
    if (message['aps'] != null && message['aps']['alert'] != null) {
      notification = message['aps']['alert'];
    }
    // iOS 에서는 data 속성없이, 객체에 바로 저장된다.
    var data = message['data'] ?? message;

    // return if the senderID is the owner.
    if (data != null && data['senderID'] == user.uid) {
      return;
    }

    if (display) {
      Get.snackbar(
        notification['title'].toString(),
        notification['body'].toString(),
        onTap: (_) {
          // print('onTap data: ');
          // print(data);
          Get.toNamed(data['route']);
        },
        mainButton: FlatButton(
          child: Text('Open'),
          onPressed: () {
            // print('mainButton data: ');
            // print(data);
            Get.toNamed(data['route']);
          },
        ),
      );
    } else {
      // TODO: Make it work.
      /// App will come here when the user open the app by tapping a push notification on the system tray.
      /// Do something based on the `data`.
      if (data != null && data['postId'] != null) {
        // Get.toNamed(Settings.postViewRoute, arguments: {'postId': data['postId']});
      }
    }
  }

  Future<void> sendNotification(
    title,
    body, {
    route,
    token,
    tokens,
    topic,
  }) async {
    print('SendNotification');
    if (token == null && tokens == null && topic == null)
      return print('Token/Topic is not provided.');

    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    // String toParams = "/topics/" + App.Settings.allTopic;
    // print(token);
    // print(topic);

    final req = [];
    if (token != null) req.add({'key': 'to', 'value': token});
    if (topic != null) req.add({'key': 'to', 'value': "/topics/" + topic});
    if (tokens != null) req.add({'key': 'registration_ids', 'value': tokens});

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "key=" + firebaseServerToken
    };

    req.forEach((el) async {
      final data = {
        "notification": {"body": body, "title": title},
        "priority": "high",
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "sound": 'default',
          "senderID": user.uid,
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
}
