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

part './definitions.dart';
part './functions.dart';
part './base.dart';

/// FireFlutter
///
/// Recommendation: instantiate `FireFlutter` class into a global variable
/// and use it all over the app runtime.
///
/// Warning: instantiate it after `initFirebase`. One of good places is insdie
/// the first widget loaded by `runApp()` or home screen.
class FireFlutter extends Base {
  /// [socialLoginHandler] will be invoked when a social login success or fail.
  FireFlutter() {
    print('FireFlutter');
  }

  Future<void> init({
    bool enableNotification = false,
    String firebaseServerToken,
    Function notificationHandler,
  }) async {
    this.enableNotification = enableNotification;
    this.notificationHandler = notificationHandler;
    this.firebaseServerToken = firebaseServerToken;
    await initFirebase();
    initUser();
    initFirebaseMessaging();
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
    Query postsQuery = postsCol.where('category', isEqualTo: forum.category);
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

              /// comment added
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

              /// comment modified
              else if (commentsChange.type == DocumentChangeType.modified) {
                final int ci = post['comments']
                    .indexWhere((c) => c['id'] == commentData['id']);
                if (ci > -1) {
                  post['comments'][ci] = post;
                }
              }

              /// comment deleted
              else if (commentsChange.type == DocumentChangeType.removed) {
                print('comment delete');
                post['comments']
                    .removeWhere((c) => c['id'] == commentData['id']);
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
      await postsCol.doc(data['id']).set(
            data,
            SetOptions(merge: true),
          );
    } else {
      data.remove('id');
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await postsCol.add(data);

      sendNotification(
        data['title'],
        data['content'],
        route: data['category'],
        topic: "notification_post_" + data['category'],
      );
    }
  }

  ///
  Future editComment(Map<String, dynamic> data) async {
    /// data['post'] is required.
    if (data['post'] == null) throw 'ERROR_POST_IS_REQUIRED';
    final Map<String, dynamic> post = data['post'];
    data.remove('post');

    final commentsCol = commentsCollection(post['id']);
    data.remove('postid');

    print('ref.path: ' + commentsCol.path.toString());

    /// update
    if (data['id'] != null) {
      data['createdAt'] = FieldValue.serverTimestamp();
      await commentsCol.doc(data['id']).set(data, SetOptions(merge: true));
    }

    /// create
    else {
      final int parentIndex = data['parentIndex'];
      data.remove('parentIndex');

      /// get order
      data['order'] = getCommentOrderOf(post, parentIndex);
      data['uid'] = user.uid;

      /// get depth
      dynamic parent = getCommentParent(post['comments'], parentIndex);
      data['depth'] = parent == null ? 0 : parent['depth'] + 1;

      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      print('comment create data: $data');
      await commentsCol.add(data);
      sendCommentNotification(post, data);
    }
  }

  deletePost(a) {}
  deleteComment(c, d) {}

  /// Google sign-in
  ///
  ///
  Future<User> signInWithGoogle() async {
    // Trigger the authentication flow

    await GoogleSignIn().signOut(); // to ensure you can sign in different user.

    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw ERROR_SIGNIN_ABORTED;

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
    return userCredential.user;
  }

  /// Facebook social login
  ///
  ///
  Future<User> signInWithFacebook() async {
    // Trigger the sign-in flow
    LoginResult result;

    await FacebookAuth.instance
        .logOut(); // Need to logout to avoid 'User logged in as different Facebook user'
    result = await FacebookAuth.instance.login();
    if (result == null || result.accessToken == null) {
      throw ERROR_SIGNIN_ABORTED;
    }

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken.token);

    // Once signed in, return the UserCredential
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    onSocialLogin(userCredential.user);

    return userCredential.user;
  }
}
