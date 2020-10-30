# Fire Flutter

⚡️ `FireFlutter` is a rapid development package for creating Social apps based on `Firebase`.

## Features

- User functionalities

  - User registration, login, profile update with email/password
  - Social logins
    - Google,
    - Apple (only on iOS),
    - Facebook,
    - Kakao. Read `Kakao Login`.
  - User profile photo update
  - Phone number authentication(x)

- Forum functionalities

  - Post create, update, delete.
  - Comment create, update, delete.
  - File uploads on posts and comments. (x)
  - Vote(like, dislkie) on posts and comments.
  - Infinite scroll

- Push notifications

  - Admin can send push notifications to all users.
  - Admin can send push notifications to users of a forum.(x)
  - User can enable/disable to get notification when a user creates a comments under his post/comment.
  - User can subscribe/unsubscribe for new posts or comments under a forum.

- Realtime App Settings

  - Update App Settings via Admin page.

- Internalization (Localization)
  - Texts in menu, screens can be translated via Admin page.

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

#### Google Login

- You can use the social Login by calling signInWithGoogle.

```dart
RaisedButton(
  child: Text('Google Sign-in'),
  onPressed: ff.signInWithGoogle,
)
```

### Facebook Login

- Follow the instructions on how to setup Facebook project.

```dart
RaisedButton(
  child: Text('Facebook Sign-in'),
  onPressed: ff.signInWithFacebook,
);
```

### Apple Login

- Follow the instructions on how to setup Apple project.
- Enable `Apple` in Sign-in Method.

```dart
SignInWithAppleButton(
  onPressed: () async {
    try {
      await ff.signInWithApple();
      Get.toNamed(RouteNames.home);
    } catch (e) {
      Service.error(e);
    }
  },
),
```

## External Logins

### Kakao Login

- Kakao login is completely separated from `fireflutter` since it is not part of `Firebase`.
  - The sample app has an example code on how to do `Kakao login` and link to `Firebase Auth` account.

## I18N

- The app's i18n is managed by `GetX` i18n feature.

- If you want to add another language,

  - Add the language code in `Info.plist`
  - Add the language on `translations`
  - Add the lanugage on `FireFlutter.init()`
  - Add the language on `FireFlutter.settingsChange`
  - Add the language on Firebase `settings` collection.

- Default i18n translations(texts) can be set through `FireFlutter` initializatin and is overwritten by the `translations` collection of Firebase.
  The Firestore is working offline mode, so overwriting with Firestore translation would happen so quickly.

## Settings

- Default settings can be set through `FireFlutter` initialization and is overwritten by `settings` collection of Firebase.
  The Firestore is working offline mode, so overwriting with Firestore translation would happen so quickly.

- To get `GcpApiKey`,
  - Go to `GCP ==> Choose Project ==> APIs & Service ==> Credentials ==> API Kyes`
  - `+ CREATE CREDENTIALS => RESTRICT KEY`
  - Name it to `FireFlutterApiKey`
  - Choose `None` under `Application restrictions`
  - Choose `Don't restrict key` under `API restrctions`
  - `Save`
  - Copy the Api Key on `FireFlutterApiKey`.
  - Paste it into `Firestore` => `/settings` collection => `app` document => `GcpApiKey`.
