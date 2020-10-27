library fireflutter;

import 'dart:async';

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

  CollectionReference usersCol = FirebaseFirestore.instance.collection('users');

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

  BehaviorSubject<UserChange> userChange = BehaviorSubject.seeded(null);

  ///
  ///
  ///
  FireFlutter({this.enableNotification}) {
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

    ///
    ///
    ///
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
}
