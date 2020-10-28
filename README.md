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
