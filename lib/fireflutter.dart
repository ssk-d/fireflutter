library fireflutter;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireFlutter {
  /// Register into Firebase with email/password
  ///
  Future<User> register({
    @required String email,
    @required String password,
    String displayName = '',
    String photoURL = '',
    Map<String, dynamic> data,
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

    print('FireFlutter::register() success: user: ');
    print(user);

    /// Login Success
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    /// Set user extra information
    await users.doc(userCredential.user.uid).set(data);

    return user;
  }
}
