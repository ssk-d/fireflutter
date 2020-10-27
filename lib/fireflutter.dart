library fireflutter;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireFlutter {
  /// User document
  ///
  /// Attention! [user] may not immediately be available after instantiating
  /// `FireFlutter` since [user] is only available after `authStateChanges`.
  /// And `authStateChanges` produce a `StreamSubscription` which should be
  /// unsubscribed when it does not needed anymore.
  /// For this reason, it is recommended to instantiating only once in global
  /// space of the app's runtime.
  User user;
  Stream<User> authStateChanges;
  FireFlutter() {
    authStateChanges = FirebaseAuth.instance.authStateChanges();
    authStateChanges.listen((User user) {
      this.user = user;
    });
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
  Future<User> register({
    @required String email,
    @required String password,
    String displayName = '',
    String photoURL = '',
    Map<String, dynamic> data,
    Map<String, Map<String, dynamic>> meta,
  }) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    /// For registraion, it is okay that displayName or photoUrl is empty.
    await userCredential.user.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    await userCredential.user.reload();
    user = FirebaseAuth.instance.currentUser;

    /// Login Success
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user.uid);

    /// Set user extra information
    await userDoc.set(data);

    // Push default meta to user meta
    if (meta != null) {
      CollectionReference metaCol = userDoc.collection('meta');
      for (final key in meta.keys) {
        // Save data for each path.
        await metaCol.doc(key).set(meta[key]);
      }
    }

    return user;
  }

  /// Logs out from Firebase Auth.
  Future<void> logout() {
    return FirebaseAuth.instance.signOut();
  }

  /// Logs into Firebase Auth.
  ///
  /// TODO Leave last login timestamp.
  Future<User> login({
    @required String email,
    @required String password,
  }) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// Updates a user's profile data.
  ///
  /// After update, `user` will have updated `displayName` and `photoURL`.
  ///
  /// TODO Make a model(interface type)
  Future<void> updateProfile(Map<String, dynamic> data,
      [Map<String, dynamic> meta]) async {
    if (data == null) return;
    if (data['displayName'] != null) {
      await user.updateProfile(displayName: data['displayName']);
    }
    if (data['photoURL'] != null) {
      await user.updateProfile(photoURL: data['photoURL']);
    }

    await user.reload();
    user = FirebaseAuth.instance.currentUser;
    data.remove('displayName');
    data.remove('photoURL');

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.set(data, SetOptions(merge: true));
  }
}
