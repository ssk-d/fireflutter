library fireflutter;

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/subjects.dart';
import './functions.dart';
part './definitions.dart';
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
    Map<String, dynamic> defaultConfigs,
  }) async {
    this.enableNotification = enableNotification;
    this.firebaseServerToken = firebaseServerToken;
    await initFirebase();
    initUser();
    initFirebaseMessaging();
    initRemoteConfig(defaultConfigs);
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

    /// Remove default data.
    /// And if there is no more properties to save into document, then save
    /// empty object.
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
    print('email: $email');
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

  /// Add url to post or comment document `files` field.
  ///
  /// Note: Same URL can be added twice. The user may upload same file twice.
  ///
  /// ```
  /// // after upload
  /// // get url
  /// ff.addFile(url: url, path: 'post or comment path', files: comments['files'] );
  /// ```
  // addFiles({
  //   @required String url,
  //   List<String> files,
  //   @required String path,
  // }) {
  //   if (files == null) files = [];
  //   files.add(url);
  //   final doc =
  //       FirebaseFirestore.instance.doc(path);
  //   doc.set({'files': files}, SetOptions(merge: true));
  // }

  /// Deletes a file from firebase storage.
  ///
  /// If the file is not found on the firebase storage, it will ignore the error.
  Future deleteFile(String url) async {
    Reference ref = FirebaseStorage.instance.refFromURL(url);
    await ref.delete().catchError((e) {
      if (!e.toString().contains('object-not-found')) {
        throw e;
      }
    });
  }

  /// Get more posts from Firestore
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
              commentData['id'] = commentsChange.doc.id;

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

                print('comment index : $ci');
                if (ci > -1) {
                  post['comments'][ci] = commentData;
                }
                forum.render(RenderType.commentUpdate);
              }

              /// comment deleted
              else if (commentsChange.type == DocumentChangeType.removed) {
                post['comments']
                    .removeWhere((c) => c['id'] == commentData['id']);
                forum.render(RenderType.commentDelete);
              }
            });
          });

          forum.fetchingPosts(RenderType.stopFetching);
        }

        /// post update
        else if (documentChange.type == DocumentChangeType.modified) {
          print('post updated');
          print(post.toString());

          final int i = forum.posts.indexWhere((p) => p['id'] == post['id']);
          if (i > -1) {
            forum.posts[i] = post;
          }
          forum.render(RenderType.postUpdate);
        }

        /// post delete
        else if (documentChange.type == DocumentChangeType.removed) {
          /// TODO: when post is deleted, also remove comment list subscription to avoid memory leak.
          forum.commentsSubcriptions[post['id']].cancel();
          forum.posts.removeWhere((p) => p['id'] == post['id']);
          forum.render(RenderType.postDelete);
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
    if (data['title'] == null && data['content'] == null)
      throw "ERROR_TITLE_AND_CONTENT_EMPTY";

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

  /// [data] is the map to save into comment document.
  ///
  /// `post` property of [data] is required.
  Future editComment(Map<String, dynamic> data) async {
    if (data['post'] == null) throw 'ERROR_POST_IS_REQUIRED';
    final Map<String, dynamic> post = data['post'];
    data.remove('post');

    final commentsCol = commentsCollection(post['id']);
    data.remove('postid');

    // print('ref.path: ' + commentsCol.path.toString());

    /// update
    if (data['id'] != null) {
      data['updatedAt'] = FieldValue.serverTimestamp();
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
      data['like'] = 0;
      data['dislike'] = 0;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      // print('comment create data: $data');
      await commentsCol.add(data);
      sendCommentNotification(post, data);
    }
  }

  Future deletePost(String postID) async {
    if (postID == null) throw "ERROR_POST_ID_IS_REQUIRED";
    await postsCol.doc(postID).delete();
  }

  Future deleteComment(String postID, String commentID) async {
    if (postID == null) throw "ERROR_POST_ID_IS_REQUIRED";
    if (commentID == null) throw "ERROR_COMMENT_ID_IS_REQUIRED";
    await postsCol.doc(postID).collection('comments').doc(commentID).delete();
  }

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

  Future<User> signInWithApple() async {
    final oauthCred = await createAppleOAuthCred();
    print(oauthCred);

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCred);
    return userCredential.user;
  }

  /// [folder] is the folder name on Firebase Storage.
  /// [source] is the source of file input. It can be Camera or Gallery.
  /// [maxWidth] is the max width of image to upload.
  /// [quality] is the quality of the jpeg image.
  ///
  /// It will return a string of URL of uploaded file.
  ///
  /// 'upload-cancelled' may return when there is no return(no value) from file selection.
  Future<String> uploadFile({
    @required String folder,
    ImageSource source,
    // @required File file,
    double maxWidth = 1024,
    int quality = 90,
    void progress(double progress),
  }) async {
    /// select file.
    File file = await pickImage(
      source: source,
      maxWidth: maxWidth,
      quality: quality,
    );

    /// if no file is selected then do nothing.
    if (file == null) throw 'upload-cancelled';
    // print('success: file picked: ${file.path}');

    /// delete previous file to prevent having unused files in storage.
    await deleteFile(user.photoURL);

    final ref = FirebaseStorage.instance
        .ref(folder + '/' + getFilenameFromPath(file.path));

    UploadTask task = ref.putFile(file);
    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      double p = (snapshot.totalBytes / snapshot.bytesTransferred) * 100;
      progress(p);
    });

    await task;
    final url = await ref.getDownloadURL();
    // print('DOWNLOAD URL : $url');
    return url;
  }
}
