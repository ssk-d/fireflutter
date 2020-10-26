library fireflutter;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireFlutter {
  Stream<User> authStateChanges;
  FireFlutter() {
    authStateChanges = FirebaseAuth.instance.authStateChanges();
  }

  /// Register into Firebase with email/password
  ///
  /// `authStateChanges` will fire event with login info immediately after the
  /// user register but before updating user displayName and photoURL meaning.
  /// This means, when `authStateChanges` event fired, the user have no
  /// `displayNamd` and `photoURL` in the User data.
  ///
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
    User user = FirebaseAuth.instance.currentUser;

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

  Future<void> logout() {
    return FirebaseAuth.instance.signOut();
  }
}
