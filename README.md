# Fire Flutter

`FireFlutter` is a rapid development package for creating Social apps based on `Firebase`.

## Features

- User functionalities

  - User registration, login, profile update with email/password
  - Social logins with Firebase Sign-in methods.
  - User profile photo update
  - Phone number authentication

- Forum functionalities

  - Post create, update, delete.
  - Comment create, update, delete.
  - File uploads on posts and comments.
  - Vote(like, dislkie) on posts and comments.
  - Infinite scroll
  - And other functions to complete forum funcitons.

- Push notifications
  - Admin can send push notifications to all users.
  - User can enable/disable to get notification when a user creates a comments under his post/comment.
  - User can subscribe/unsubscribe for new posts or comments under a forum.

## Firestore Structure

- `users/{uid}` is user's private data document.
  - `users/{uid}/meta/public` is user's public data document.
  - `users/{uid}/meta/tokens` is where the user's tokens are saved.

## Packages

- `rxdart` to update user state and user document changes.
  - User login/logout can be observed by `FirebaseAuth.authStateChanges` but the app needs to observe user auth state together with user docuemnt update.

## Coding Guidelines

- `null` event will be fired for the first time on `FireFlutter.userChange.listen`.
- `auth` event will be fired for the first time on `FirebaseAuth.authChagnes`.

### User

### Forum

- To fetch posts and listing, you need to declare `ForumData` object.
  - How to declare forum data.

```dart
class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  ForumData forum;

  @override
  void initState() {
    super.initState();
    forum = ForumData(
      category: Get.arguments['category'], // Category of forum
      /// [render] callback will be invoked on post/comment/file CRUD and fetching posts.
      render: (RenderType x) {
        if (mounted) setState(() => null);
      },
    );
  }
}

```

### Push Notification

- Must be enableNotification `true` on main on FireFlutter init
  - to handble notification you can pass method via notificationHandler.

```dart
ff.init(
    enableNotification: true,
    notificationHandler: (Map<String, dynamic> notification,
        Map<String, dynamic> data, NotificationType type) {
          // do something here.
          // display, alert, move to specific page
    },
  );
```

### Social Login

- You need to handle the success and error on FireFlutter init

```dart
ff.init(
  socialLoginSuccessHandler: (user) {
    // on success do something here
  }),
  socialLoginErrorHandler: (e) {
    // on error do something here
  },
);
```

- You can use the social Login by calling signInWithGoogle or signInWithFacebook

```dart
children: [
    RaisedButton(
      child: Text('Google Sign-in'),
      onPressed: ff.signInWithGoogle,
    ),
    RaisedButton(
      child: Text('Facebook Sign-in'),
      onPressed: ff.signInWithFacebook,
    ),
]
```
