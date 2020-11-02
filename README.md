# Fire Flutter

A free, open source, rapid development flutter package to build social apps, community apps, and more.

- This package has complete features (see Features below) that most of apps are needed.
- `Simple, easy and the right way`.
  We want it to be really simple but right way for ourselves and for builders in the world.
  We know when it gets complicated, developers' lives would get even more complicated.

## Features

- User

  - User registration, login, profile update with email/password
  - Social logins
    - Google,
    - Apple (only on iOS),
    - Facebook,
    - Developers can their own social login. see `Kakao Login` example.
  - User profile photo update
  - Phone number authentication

- Forum

  - Complete forum functioanlities.
    - Forum category add/update/delete in admin page.
    - Post and comment create/update/read/delete, likes/dislikes, file upload/delete. And any other extra functioanalties to compete forum feature.
  - Forum search with Algolia.
  - Infinite scroll.
  - Real time.
    - If a user create a comment, it will appear on other user's phone. And this goes same to all edit/delete, likes/dislikes.
  - A category of forum could be re-designed for online shopping mall purpose.

- Push notifications

  - Admin can send push notifications to all users.
  - Admin can send push notifications to users of a forum.
  - User can enable/disable to get notification when other users creates comments under his posts/comments.
  - User can subscribe/unsubscribe for new posts or comments under a forum.

- Settings in real time.

  - Admin can update app settings via Admin page and the change will apply to app immediately.

- Internalization (Localization) in real time.

  - Texts in menu, text screens could be translated/update at any via Admin page and it appears in the app immediately.

- Security

  - Tight Firestore security rules are applied.
  - For some functionalities that cannot be covered by Firestore security are covered by Cloud Functions.

- Fully Customizable
  - FireFlutter package does not involve in any of part application's login or UI. It is completely separated from the app. Thus, it's highly customizable.

## References

- [FireFlutter Package](https://pub.dev/packages/fireflutter) - This package.
- [FireFlutter Sample App](https://github.com/thruthesky/fireflutter-sample-app) - Sample flutter application.
- [FireFlutter Firebase Project](https://github.com/thruthesky/fireflutter-firebase) - Firebase project for Firestore security rules and Functions.

## Components

- Firebase.
  Firebase is a leading cloud system powered by Google. It has lots of goods to build web and app.

  - We first built it with Firebase and LEMP(Linux + Nginx + MySQL + PHP). Then, we realized maintaing two different systems would be a pressure for many of developers. So, We decided to remove LEMP and we built it again.

  - You may use Firebase as free plan for a test. But for production, you need `Pay as you go` plan since `Cloud Function` works only on `Pay as you go` plan.
    - You may not use `Cloud Function` for testing.

- Algolia.
  Firebase does not support full text search which means users cannot search posts and comments.
  Algolia does it.

## Installation

- If you are not familiar with Firebase and Flutter, you may have difficulties to install it.

  - FireFlutter is not a smple package that you just add it into pubspec.yaml and ready to go.
  - Furthermore, the settings that are not directly from coming FireFlutter package like social login settings, Algolia setting, Android and iOS developer's accont settings are also hard to implement if you are not get used to them.

  We cover all the settings and will try to put it as demonstrative as it can be.
  We also have a premium paid servie to support installation and development.

### Firebase Installation

#### Firebase Project Creation

- Create Firebase Project.

#### Firebase Authentication

- Under Authentication => Sign-in Methods, Enable

  - Email/Password
  - Google
  - Apple
  - Facebook
  - Phone
    All of them are optional. You may only enable those you want to provide for user login.

- Settings for Firebase Social login are in Android and iOS platform already done app. You need to set the settings on Apple, Facebook.

  - If you are not going to use the sample app, you need to setup by yourself.

- Refer [Firebase Authentication](https://firebase.google.com/docs/auth) and [FlutterFire Social Authenticatino](https://firebase.flutter.dev/docs/auth/social) for details.

#### Firestore and Functions

- Enable(Start) Cloud Firestore by clicking the menu.
- Choose `protected mode`
- Choose your region.
- Refer [Cloud Firestore](https://firebase.google.com/docs/firestore) for details.

#### Firestore security and Functions Settings.

- Firestore needs security rules and Functions needs functions to support FireFlutter package.

  - If you wish, you can continue without this settings. But it's not secure and some functionality may not work.

- Install firebase tools.

```
# npm install -g firebase-tools
$ cd firebase
$ firebase login
```

- Git clone(or fork) https://github.com/thruthesky/fireflutter-firebase and install with `npm i`
- Update Firebase project ID in `.firebaserc ==> projects ==> default`.
- Save `Firebase SDK Admin Service Key` to `firebase-service-account-key.json`.
- Run `firebase deploy --only firestore,functions`. You will need Firebase `Pay as you go` plan to deploy it.

### Push Notification

- Settings of push notification on Android and iOS platform are done in the sample app.

  - If you are not going to use the sample app, you need to setup by yourself.

- Refer [Firestore Messaging](https://pub.dev/packages/firebase_messaging)

#### Security Rules Testing

- If you wish to test Firestore security rules, you may do so with the following;

Run Firebase emualtor first.

```
$ firebase emulators:start --only firestore
```

Then, run the tests.

```
$ npm run test
$ npm run test:basic
$ npm run test:user
$ npm run test:admin
$ npm run test:category
$ npm run test:post
$ npm run test:comment
$ npm run test:vote
$ npm run test:user.token
```

#### Funtions Test

- If you whish to test Functins, you may do so with the following;

```
$ cd functions
$ npm test
```

#### Issues

- If you have an issues, please leave it on https://github.com/thruthesky/fireflutter-firebase/issues.

### Flutter Installation

- Add `fireflutter` to pubspec.yaml
- see our [sample flutter app](https://github.com/thruthesky/fireflutter-sample-app).

#### Localization

- To add a language, the language needs to be set in Info.plist of iOS platform. No setting is needed on Android platform.
- Then, you need to add the translation under Firestore `translations` collection.
- Then, you need to use it in your app.
- Localization could be used for menus, texts in screens.
-

### Algolia Installation

- There are two settings for Algolia.
- First, you need to put ALGOLIA_ID(Application ID), ALGOLIA_ADMIN_KEY, ALGOLIA_INDEX_NAME in `firebase-settings.js`.
  - Then, deploy with `firebase deploy --only functions`.
  - For testing, do `npm run test:algolia`.
- Second, you need to add(or update) ALGOLIA_APP_ID(Application ID), ALGOLIA_SEARCH_KEY(Search Only Api Key), ALGOLIA_INDEX_NAME in Firestore `settings/app` document.
  Optionally, you can put the settings inside `FireFlutter.init()`.
- Algolia free account give you 10,000 free search every months. This is good enough for small sized projects.

### Admin Account Setting

- Any user who has `isAdmin` property with `true`.
- Admin property is protected by Firestore security rules and cannot be edited by client app.

## App Management

- The app management here is based on the sample code and app.
- FireFlutter is a flutter package to build social apps and is fully customizable. When you may build your own customized app, we recommend to use our sample codes.

### App Settings

- Developers can set default settings on `FireFlutter.init()`.
- Admin can overwrite all the settings by updating Firestore `settings` docuemnts.

### Internalization (Localization)

- Menus and page contents can be translated depending on user's device. Or developer can put a menu to let users to choose their languages.

- When admin update the translation text in Firestore `translations` collectin, the will get the update in real time. The app, then, should update the screen.

- The localization is managed by `GetX` package that is used for routing and state management on the sample code.

### Forum Management

#### Forum Category Management

- You can create forum categories in admin screen.

## For Developers

### FireFlutter package initialization

- app settings
- translations

### Firestore Structure

- Principle. Properties and sub collections(documents) of a document should be under that document.

- `users/{uid}` is user's private data document.

  - `users/{uid}/meta/public` is user's public data document.
  - `users/{uid}/meta/tokens` is where the user's tokens are saved.

- `/posts/{postId}` is the post document.
  - `/posts/{postId}/votes/{uid}` is the vote document of each user.
  - `/posts/{postId}/comments/{commentId}` is the comment document under of the post document.

### Coding Guidelines

- `null` event will be fired for the first time on `FireFlutter.userChange.listen`.
- `auth` event will be fired for the first time on `FirebaseAuth.authChagnes`.

### User

- Private user information is saved under `/users/{uid}` documentation.
- User's notification subscription information is saved under `/users/{uid}/meta/public` documents.
- Push notification tokens are saved under `/users/{uid}/meta/tokens` document.

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

### Logic for Vote

- Post voting and comment voting have same logic and same(similiar) document structure.
- Choice of vote could be one of `empty string('')`, `like`, `dislike`. Otherwise, permission error will happen.
- When a user votes for the first time, choice must be one of `like` or `dislike`. Otherwise, permission error will happen.
- Properties names of like and dislike in post and comment documents are in plural forms that are `likes` and `dislikes`.
- `likes` and `dislikes` may not exists in the document or could be set to 0.
- For votes under post, `/posts/{postId}/votes/{uid}` is the document path.
- For votes under comments, `/posts/{postId}/comments/{commentId}/votes/{uid}` is the document path.
- User can vote on his posts and comments.
- A user voted `like` and the user vote `like` again, he means, he wants to cancel the vote. The client should save empty string('').
- A user voted `like` and the user vote `dislike`, then `likes` will be decreased by 1 and `dislikes` will be increased by 1.
- Admin should not fix vote document manually, since it may produce wierd results.
- Voting works asynchronously.
  - When a user votes in the order of `like => dislike => like => dislike`,
    the server(Firestore) may receive in the order of `like => like => dislike => dislike` since it is **asynchronous**.
    So, client app should block the user not to vote again while voting is in progress.

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

#### Facebook Login

- Follow the instructions on how to setup Facebook project.

```dart
RaisedButton(
  child: Text('Facebook Sign-in'),
  onPressed: ff.signInWithFacebook,
);
```

#### Apple Login

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

### External Logins

#### Kakao Login

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

<!-- - `GcpApiKey` is the GCP ApiKey and if you don't know what it is, then here is a simple tip. `GCP ApiKey` is a API Key to access GCP service and should be kept in secret. `Firebase` is a part of GCP Service and GCP ApiKey is needed to use Firebase functionality. And FireFlutter needs this key to access GCP service like phone number verification.
  - To get `GcpApiKey`,
    - Go to `GCP ==> Choose Project ==> APIs & Service ==> Credentials ==> API Kyes`
    - `+ CREATE CREDENTIALS => RESTRICT KEY`
    - Name it to `FireFlutterApiKey`
    - Choose `None` under `Application restrictions`
    - Choose `Don't restrict key` under `API restrctions`
    - `Save`
    - Copy the Api Key on `FireFlutterApiKey`.
    - Paste it into `Firestore` => `/settings` collection => `app` document => `GcpApiKey`.
  - You may put the `GcpApiKey` in the source code (as in FireFlutter initialization) but that's not recommended. -->
