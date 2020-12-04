# Fire Flutter

A free, open source, rapid development flutter package to build apps like shopping mall, social community, or any kind of apps.

- Complete features.\
  This package has complete features (see Features below) that most of apps are needed.
- `Simple, easy and the right way`.\
  We want it to be deadly simple but right way for ourselves and for the developers in the world.
  We know when it gets complicated, our lives would get even more complicated.
- Real time.\
  We design it to be real time when it is applied to your app. All the events like post and comment creation, voting(like, dislike), deletion would appears on all the user's phone immediately after the event.

# Table of Contents

<!-- TOC -->

- [Fire Flutter](#fire-flutter)
- [Table of Contents](#table-of-contents)
- [Features](#features)
- [References](#references)
- [Components](#components)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Create Firebase Project](#create-firebase-project)
  - [Enable Firestore](#enable-firestore)
    - [Install Firestore Security Rules](#install-firestore-security-rules)
      - [Security Rules Testing](#security-rules-testing)
    - [Update Firestore Index](#update-firestore-index)
  - [Firebase Email/Password Login](#firebase-emailpassword-login)
  - [Create Flutter project](#create-flutter-project)
    - [Setup Flutter to connect to Firebase](#setup-flutter-to-connect-to-firebase)
      - [iOS Setup](#ios-setup)
      - [Android Setup](#android-setup)
  - [Create a keystore](#create-a-keystore)
    - [Debug hash key](#debug-hash-key)
      - [Debug hash key base64](#debug-hash-key-base64)
    - [Release hash key](#release-hash-key)
      - [Release hash key base64](#release-hash-key-base64)
  - [Add fireflutter package to Flutter project](#add-fireflutter-package-to-flutter-project)
  - [Firebase Social Login](#firebase-social-login)
    - [Google Sign-in Setup](#google-sign-in-setup)
    - [Google Sign-in Setup for iOS](#google-sign-in-setup-for-ios)
    - [Google Sign-in Setup for Android](#google-sign-in-setup-for-android)
    - [Facebook Sign In Setup](#facebook-sign-in-setup)
      - [Facebook Sign In Setup for Android](#facebook-sign-in-setup-for-android)
      - [Facebook Sign In Setup for iOS](#facebook-sign-in-setup-for-ios)
    - [Apple Sign In Setup for iOS](#apple-sign-in-setup-for-ios)
    - [Phone Auth Setup](#phone-auth-setup)
      - [Additional Phone Auth Setup for Android](#additional-phone-auth-setup-for-android)
      - [Additional Phone Auth Setup for iOS](#additional-phone-auth-setup-for-ios)
  - [Permission handler setup](#permission-handler-setup)
  - [Permission handler setup for Android](#permission-handler-setup-for-android)
  - [Image Picker Setup](#image-picker-setup)
    - [Image picker setup for Android](#image-picker-setup-for-android)
    - [Image Picker Setup for iOS](#image-picker-setup-for-ios)
  - [Location Setup](#location-setup)
    - [Location Setup For Android](#location-setup-for-android)
    - [Location Setup For iOs](#location-setup-for-ios)
  - [I18N Setup](#i18n-setup)
  - [Push Notification Setup](#push-notification-setup)
    - [Additional Android Setup](#additional-android-setup)
    - [Additional iOS Setup](#additional-ios-setup)
  - [Algolia Setup](#algolia-setup)
  - [Admin Account Setting](#admin-account-setting)
- [App Management](#app-management)
  - [App Settings](#app-settings)
  - [Internalization (Localization)](#internalization-localization)
  - [Forum Management](#forum-management)
    - [Forum Category Management](#forum-category-management)
- [Developer Coding Guidelines](#developer-coding-guidelines)
  - [General Setup](#general-setup)
  - [FireFlutter global variable](#fireflutter-global-variable)
    - [FireFlutter Initialization](#fireflutter-initialization)
      - [Blocking mode](#blocking-mode)
      - [Non-blocking mode](#non-blocking-mode)
    - [Add GetX](#add-getx)
  - [Firestore Structure](#firestore-structure)
  - [User](#user)
  - [Create Register Screen](#create-register-screen)
  - [Create Login Screen](#create-login-screen)
  - [Create Profile Screen](#create-profile-screen)
  - [User Email And Password Registration](#user-email-and-password-registration)
  - [Display User Login](#display-user-login)
  - [Login with email and password](#login-with-email-and-password)
  - [Profile update](#profile-update)
  - [Create admin page](#create-admin-page)
  - [Forum Coding](#forum-coding)
    - [Create forum category management screen](#create-forum-category-management-screen)
    - [Create post edit screen](#create-post-edit-screen)
    - [Photo upload](#photo-upload)
    - [Create post list screen](#create-post-list-screen)
    - [Post list with photos](#post-list-with-photos)
    - [Post edit](#post-edit)
    - [Post delete](#post-delete)
    - [Photo delete](#photo-delete)
    - [Voting](#voting)
      - [Logic for Vote](#logic-for-vote)
    - [Comment crud, photo upload/update, vote like/dislike](#comment-crud-photo-uploadupdate-vote-likedislike)
  - [Search](#search)
  - [Push Notification](#push-notification)
    - [Notification Settings for the Reactions](#notification-settings-for-the-reactions)
    - [Notification Settings for Topic Subscription](#notification-settings-for-topic-subscription)
    - [Logic of Push Notification](#logic-of-push-notification)
      - [Cavits of push notification](#cavits-of-push-notification)
  - [Social Login](#social-login)
    - [Google Sign-in](#google-sign-in)
    - [Facebook Sign In](#facebook-sign-in)
    - [Apple Sign In](#apple-sign-in)
  - [External Logins](#external-logins)
    - [Kakao Login](#kakao-login)
  - [Phone Verification](#phone-verification)
- [Language Settings, I18N](#language-settings-i18n)
- [Settings](#settings)
  - [Phone number verification](#phone-number-verification)
  - [Forum Settings](#forum-settings)
- [Chat](#chat)
  - [Preview of chat functionality](#preview-of-chat-functionality)
  - [Firestore structure of chat](#firestore-structure-of-chat)
  - [Logic of chat](#logic-of-chat)
  - [Pitfalls of chat logic](#pitfalls-of-chat-logic)
  - [Code of chat](#code-of-chat)
    - [Preparation for chat](#preparation-for-chat)
    - [Begin chat with a user](#begin-chat-with-a-user)
  - [Scenario of extending chat functionality](#scenario-of-extending-chat-functionality)
  - [Unit tests of chat](#unit-tests-of-chat)
- [Location](#location)
  - [Firestore structure of Location](#firestore-structure-of-location)
  - [Code of Location](#code-of-location)
    - [Initialization of Location](#initialization-of-location)
- [Tests](#tests)
  - [Unit Test](#unit-test)
  - [Integration Test](#integration-test)
- [Developers Tips](#developers-tips)
  - [Extension method on fireflutter](#extension-method-on-fireflutter)
- [Extending your app with Fireflutter](#extending-your-app-with-fireflutter)
  - [Social photo gallery](#social-photo-gallery)
  - [Keeping deleted post when user delete post](#keeping-deleted-post-when-user-delete-post)
- [Trouble Shotting](#trouble-shotting)
  - [Add GoogleService-Info.plist](#add-googleservice-infoplist)
  - [Stuck in registration](#stuck-in-registration)
  - [MissingPluginException(No implementation found for method ...](#missingpluginexceptionno-implementation-found-for-method-)
    - [By pass MissingPluginException error](#by-pass-missingpluginexception-error)
  - [com.apple.AuthenticationServices.AuthorizationError error 1001 or if the app hangs on Apple login](#comappleauthenticationservicesauthorizationerror-error-1001-or-if-the-app-hangs-on-apple-login)
  - [sign_in_failed](#sign_in_failed)
  - [operation-not-allowed](#operation-not-allowed)
  - [App crashes on second file upload](#app-crashes-on-second-file-upload)
  - [Firestore rules and indexes](#firestore-rules-and-indexes)
  - [After ff.editPost or ff.editComment, nothing happens?](#after-ffeditpost-or-ffeditcomment-nothing-happens)
  - [SDK version not match](#sdk-version-not-match)
  - [flutter_image_compress error](#flutter_image_compress-error)
  - [Authentication setup error on iOS](#authentication-setup-error-on-ios)
  - [Dex problem on Android](#dex-problem-on-android)
  - [App is not authorized](#app-is-not-authorized)
  - [If app exists when picking photo](#if-app-exists-when-picking-photo)

<!-- /TOC -->

# Features

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
  - Block users who didn't verify their phone nubmers to create posts & comments.
  - Forum search with Algolia.
  - Infinite scroll.
  - Real time.
    - If a user create a comment, it will appear on other user's phone. And this goes same to all edit/delete, likes/dislikes.
  - A category of forum could be re-designed for any purpose like online shopping mall, blog, etc.

- Search

  - posts and comments search.

- Push notifications

  - Admin can send push notifications to all users.
  - Admin can send push notifications to users of a forum.
  - User can enable/disable to get notification when other users creates comments under his posts/comments.
  - User can subscribe/unsubscribe for new posts or comments under a forum.

- Chat

  - A complete chat functionality which includes
    - Group chat
    - Inviting users
    - Blocking users
    - Kickout users
    - Changing settings of chat room
  - Expect more to come.

- Location

  - App can update login user's location
  - App can search other users near the login user.

- Settings in real time.

  - Admin can update app settings via Admin page and the change will apply to app immediately.

- Internalization (Localization) in real time.

  - Texts in menu, text screens could be translated/update at any via Admin page and it appears in the app immediately.

- Security

  - Tight Firestore security rules are applied.
  - For some functionalities that cannot be covered by Firestore security are covered by Cloud Functions.

- Fully Customizable
  - FireFlutter package does not involve in any of part application's login or UI. It is completely separated from the app. Thus, it's highly customizable.

# References

- [FireFlutter Package](https://pub.dev/packages/fireflutter) - This package.
- [FireFlutter Firebase Project](https://github.com/thruthesky/fireflutter-firebase) - Firebase project for Firestore security rules and Functions.

- [FireFlutter Sample App](https://github.com/thruthesky/fireflutter_sample_app) - Sample flutter application.

# Components

- Firebase.\
  Firebase is a leading cloud system powered by Google. It has lots of goods to build web and app.

  - We first built it with Firebase and LEMP(Linux + Nginx + MariaDB + PHP). It is a pressure to maintain two different systems. So, We decided to remove LEMP and we built it again only with Firebase.

  - You may use Firebase as free plan for a test.

- Algolia.\
  Firebase does not support full text search which means users cannot search posts and comments.
  Algolia does it.

- And other open source Flutter & Dart packages.

# Requirements

- Basic understanding of Flutter and Dart.
- Basic understanding of Firebase.
- OS: Windows or Mac.
- Editor: VSCode, Xcode(for Mac OS).\
  Our primary editor is VSCode and we use Xcode for Flutter settings. We found it more easy to do the settings with Xcode for iOS development.

# Installation

- If you are not familiar with Firebase and Flutter, you may have difficulties to install it.

  - FireFlutter is not a smple package that you just add it into pubspec.yaml and ready to go.
  - Many of the settings are coming from the packages that fireflutter is using.
  - And for release, it may need extra settgins.
  - Most of developers are having troubles with settings. You are not the only one. Ask us on [Git issues](https://github.com/thruthesky/fireflutter/issues).

- We will cover all the settings and try to put it as demonstrative as it can be.

  - We will begin with Firebase settings and contiue gradual settings with Flutter.

- And please let us know if there is any mistake on the installation.

## Create Firebase Project

- You need to create a Firebase project for the first time. You may use existing Firebase project.

- Go to Firebsae console, https://console.firebase.google.com/

  - click `(+) Add project` menu.
  - enter project name. You can enter any name. ex) fireflutter-test
  - click `Continue` button.
  - disable `Enable Google Analytics for this project`. You can eanble it if you can handle it.
    - click `Continue` button.
  - new Firebase project will be created for you in a few seconds.
    - Tehn, click `Continue` button.

- Read [Understand Firebase projects](https://firebase.google.com/docs/projects/learn-more) for details.

## Enable Firestore

- Go to `Cloud Firestore` menu.
- Click `Create Database`.
- Choose `Start in production mode`.
- Click `Next`.
- Choose nearest `Cloud Firestore location`.
  - To know the right location, click `Learn more`.
- Click `Enable`.

### Install Firestore Security Rules

Firestore needs security rules to secure its data.

- Copy the rules from [fireflutter firestore security rules](https://raw.githubusercontent.com/thruthesky/fireflutter-firebase/main/firestore.rules)
- Go `Cloud Firestore => Rules => Edit rules` and delete all the rules there and paste the `fireflutter firestore security rules`.
- Click `publish`.

#### Security Rules Testing

- If you wish to test Firestore security rules, you may do so with the following command.

Run Firebase emualtor first.

```
$ firebase emulators:start --only firestore
```

run the tests.

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
$ npm run test:chat
```

### Update Firestore Index

- Create complex indexes ike below.
  - Go `Cloud Firestore => Indexes => Composite => + Create Index`

| Collection ID | Fields indexed                                                    | Query scope | Status  |
| ------------- | ----------------------------------------------------------------- | ----------- | ------- |
| posts         | category **Ascending** createdAt **Descending**                   | Collection  | Enabled |
| posts         | category **Ascending** uid **Ascending** createdAt **Descending** | Collection  | Enabled |

Example of adding Firestore indexes)
![Firestore Index](wiki/firestore-index.jpg)

- Or you can deploy Firestore index using CLI.
  - You can clone the [fireflutter firebase project](https://github.com/thruthesky/fireflutter-firebase) and deploy firestore index.
  - See [Cloud Firestore Index Definition Reference](https://firebase.google.com/docs/reference/firestore/indexes) for details.

## Firebase Email/Password Login

- [Create Firestore Database](#enable-firestore)
- [Install firestore security rules](#install-firestore-security-rules)
- Do [Android Setup](#android-setup) and [iOS Setup](#ios-setup)
- Go to Authentication => (Click `Get started` menu if you see ) => Sign-in Method
- Click `Enable/Password` (without Email link).
- It is your choice weather you would let users to register by their email and password or not. But for installation test, just enable it.

- Refer [Firebase Authentication](https://firebase.google.com/docs/auth) and [FlutterFire Social Authentication](https://firebase.flutter.dev/docs/auth/social) for details.

## Create Flutter project

- Create a Flutter project like below;

```
$ flutter create fireflutter_sample_app
$ cd fireflutter_sample_app
$ flutter run
```

### Setup Flutter to connect to Firebase

#### iOS Setup

What to do: Create iOS app in Firebase and add the GoogleService-Info.plist into Flutter project.

- Click `iOS` icon on `Project Overview` page to add `iOS` app to Firebase.
- Enter iOS Bundle ID. Ex) com.sonub.fireflutter
  - From now on, we assume that your iOS Bundle ID is `com.sonub.fireflutter`.
- click `Register app`.
- click `Download GoogleService-Info.plist`
  - And save it under `[flutter_project]/ios/Runner` folder.
- click `Next`.
- click `Next` again.
- click `Next` again.
- click `Continue to console`.

- open `[flutter_project]/ios/Runner.xcworkspace` with Xcode.
- click `Runner` on the top of left pane.
- click `Runner` on TARGETS.
- edit `Bundle Identifier` to `com.sonub.fireflutter`.
- set `iOS 11.0` under Deployment Info.
- Darg `[flutter_project]/ios/Runner/GoogleService-Info.plist` file under `Runner/Runner` on left pane of Xcode.
- Close Xcode.

- You may want to test if the settings are alright.
  - Open VSCode and do [FireFlutter Initialization](#fireflutter-initialization) do some registration code. see [User Registration](#user-email-and-password-registration) for more details.

#### Android Setup

- Go to Firebase console.
- Click `Android` icon on `Project Overview` page to add `Android` app to Firebase.
  - If you don't see `Android` icon, look for `+ Add app` button and click, then you would see `Android` icon.
- Enter `iOS Bundle ID` into `Android package name`. `iOS Bundle ID` and `Android package name` should be kept in idendentical name for easy to maintain. In our case, it is `com.sonub.fireflutter`.
- Click `Register app` button.
- Click `Download google-services.json` file to downlaod
- And save it under `[flutter_project_folder]/android/app` folder.
- Click `Next`
- Click `Next`
- Click `Continue to console`.
- Open Flutter project using VSCode.
- Open `[flutter_project_folder]/android/app/build.gradle` file.
- Update `minSdkVersion 16` to `minSdkVersion 21`.
- Add below to the end of `[flutter_project_folder]/android/app/build.gradle`. This is for Flutter to read `google-services.json`.

```gradle
apply plugin: 'com.google.gms.google-services'
```

- Open `[flutter_project_folder]/android/build.gradle`. Do not confuse with the other build.gradle.
- Add the dependency below in the buildscript tag.

```gradle
dependencies {
  // ...
  classpath 'com.google.gms:google-services:4.3.3' // Add this line.
}
```

- Open the 5 files and update the package name to `com.sonub.fireflutter` (or with your app's package name).

  - android/app/src/main/AndroidManifest.xml
  - android/app/src/debug/AndroidManifest.xml
  - android/app/src/profile/AndroidManifest.xml
  - android/app/build.gradle
  - android/app/src/main/kotlin/….MainActivity.kt

- That's it.
- You may want to test if the settings are alright.
  - Open VSCode and do [FireFlutter Initialization](#fireflutter-initialization) do some registration code. see [User Registration](#user-email-and-password-registration) for more details.

## Create a keystore

This is for Android only.

You will need to create a keystore file for Android platform. Keystore file is used to upload and to update app binary file to Playstore and is alos used to generate hash keys for interacting with 3rd party service like facebook login.

It's important to know that Playstore will generate another Keystore file for publishing and you may need the hash key of it to interact with 3rd party.

- Enter the command below and input what it asks.

```sh
keytool -genkey -v -keystore keystore.key -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

- Refer [Flutter - Create a keystore](https://flutter.dev/docs/deployment/android#create-a-keystore) for details.

### Debug hash key

- To get debug hash key (SHA1 and others), enter the command below,

  - Just press enter if it asks password,

```sh
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```

- And copy SHA1 key and paste it into `Project Settings => Android apps => SHA cetificate fingerprints`.

#### Debug hash key base64

- Some 3rd party service like Facebook may ask base64 encrypted hash key, you can get it with the following command

  - Just press enter if it asks password,

```sh
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

### Release hash key

- To get release hash key (SHA1 and others), enter the command below,

  - Just press enter if it asks password,

```sh
keytool -exportcert -list -v -alias [key] -keystore [keystore.key]
```

You can replace `[key]` with real key and `[keystore.key]` with real keystore file path.

#### Release hash key base64

- Some 3rd party service like Facebook may ask base64 encrypted hash key, you can get it with the following command

  - Just press enter if it asks password,

```sh
keytool -exportcert -alias YOUR_RELEASE_KEY_ALIAS -keystore YOUR_RELEASE_KEY_PATH | openssl sha1 -binary | openssl base64
```

- It's important to know that Playstore will generate another Keystore for publish. And you need to input the hash key of it.

## Add fireflutter package to Flutter project

- Add `fireflutter` to pubspec.yaml
  - fireflutter package contains other packages like algolia, dio, firebase related packages, and more as its dependency. You don't have to install the same packages again in your pubspec.yaml
  - To check what versions of the packages are installed, see pubspec.lock file.
  - See [the pubspect.yaml in sample app](https://github.com/thruthesky/fireflutter_sample_app/blob/fireflutter/pubspec.yaml).
  - You need to update the latest version of `fireflutter`.
- See [FireFlutter Initialization](#fireflutter-initialization) to initialize `fireflutter` package.
- See [Add GetX](#add-getx) to use route, state management, localization and more.

## Firebase Social Login

- Social login is one of difficult part of settings.
  Each social login takes its own settings.
  For instance, you will need to create an app in Facebook developer account and do settings there.
  And then do settings in Firebase to relate both.

- We will cover Google, Apple, Facebook social logins.
  You can customise to remove some of the social logins or add other social logins.

- [FireFlutter sample app](https://github.com/thruthesky/fireflutter_sample_app) has social login settings, but only on Flutter part. You still need to set the settings on Firebase and the social service site.

- Refer [Firebase Authentication](https://firebase.google.com/docs/auth) and [FlutterFire Social Authentication](https://firebase.flutter.dev/docs/auth/social) for details.

### Google Sign-in Setup

Most of interactive apps need Social login like Google, Apple, Facebook and the likes. Once you put Google sign button in the app, then it is mandatory to put Apple sign in button also. Or your app will be rejected on iOS review. When you have Google and Apple, you would definitedly like to have Facebook login. Fireflutter has the code for these three social logins. If you want more social logins, then you need to implement it by yourself.

- Go to Authentication => Sign-in method
- Click Google
- Click Enable
- Choose your email address in Project support email.
- Click Save.

### Google Sign-in Setup for iOS

- Open Xcode with the project.
- Add `REVERSE_CLIENT_ID` in URL Schemes box in `URL Types under Runner (on top of left pain) => Runner (under TARGETS) => Info => URL Types => (+)`
  - You can get the REVERSE_CLIENT_ID from GoogleService-Info.plist under `Runner => Runner on left pane`.
- Add `BUNDLE_ID` in URL Schemes box in `URL Types under Runner (on top of left pain) => Runner (under TARGETS) => Info => URL Types => (+)`

  - You can get the REVERSE_CLIENT_ID from GoogleService-Info.plist under `Runner => Runner on left pane`.

- To see if this setting works, try the code in [Google Sign-in](#google-sign-in) section.

### Google Sign-in Setup for Android

- Generate debug hash and get SHA1 as described in [Debug hash key](#debug-hash-key)
- Add it into `Firebase => Project Settings => General => Your apps => Android apps => com.sonub.fireflutter => Add finger print`
- Click save.

- It's important to know that you need to generate two release SHA1 keys for production app. One for upload SHA1, the other for deploy SHA1.
- [Facebook Sign In Setup for Android](#facebook-sign-in-setup-for-android) is required to sign in with Google (in our case). Since Facebook login package is installed and relies on Google sign in package, it will produce missing plugin error when you try Google sign in. You can by pass Facebook settings as described in trouble shooting.

- To see if this setting works, try the code in [Google Sign-in](#google-sign-in) section.

- Warning: If you meet error `MissingPluginException(No implementation found for method init on channel plugins.flutter.io/google_sign_in)`, see the [MissingPluginException google_sign_in](#missingpluginexception-google_sign_in)

### Facebook Sign In Setup

#### Facebook Sign In Setup for Android

In this chapter, Facebook sign in setup for Android is explained in detail.

All the information is coming from [flutter_facebook_auth](https://pub.dev/packages/flutter_facebook_auth) which is the package we use for Facebook login.

- Go to [Facebook developers account app page](https://developers.facebook.com/apps/)
- Create a new app (Or you may click existing one to use the app)
  - Choose `Build Connected Experiences`
  - Click continue
  - Input `App Display Name`
  - Click `Create App`
    - Then, you will be redirected to the app page
- Click `Setup` under `Dashboard ==> Add Products to Your App ==> Facebook Login`.
- Click `Android`
- Click `Next`. No need to download SDK.
- Click `Next`. No need to import the SDK.
- Input the package name. In our case, it is `com.sonub.fireflutter`.
- Input `com.sonub.fireflutter.MainActivity` into `Default Activity Class Name`.
  - You need to replace `com.sonub.comfirefluter` to your package name and add the main activity class that is stated in AndroidManifest.xml. Default is `.MainActivity`.
- Click save.
- Click `use this package naem` if you see it.
- Click continue.
- Get debug hash key and release hash key as described in [Debug hash key base64](#debug-hash-key-base64) and [Release hash key base64](#release-hash-key-base64)
  - And add them into `Key Hashes`
- Click save
- Click continue
- Enable Sing Sing On. Set it to Yes.
- Click save
- Click next
- You will see some settings for Android platform in Flutter.
- Open `android/app/src/main/AndroidManifest.xml`
- Set `android:label` to `@string/app_name` in application tag like below.

```xml
<application ... android:label="@string/app_name" ...>
```

- Open `/android/app/src/main/res/values/strings.xml` ( or create if it is not existing)
- And copy facebook_app_id and fb_login_protocol_scheme, past into the XML file like below.
  - Replace `xxxxxxxxxxxxxxxxx` with right value.

```xml
<resources>
    <string name="app_name">SMS APP</string>
    <string name="facebook_app_id">xxxxxxxxxxxxxxxxx</string>
    <string name="fb_login_protocol_scheme">xxxxxxxxxxxxxxxxx</string>
</resources>
```

- Open `android/app/src/main/AndroidManifest.xml`
- Add the following uses-permission element after the application element (outside application tag)

```xml
  <uses-permission android:name="android.permission.INTERNET"/>
```

- Add the following meta-data element, an activity for Facebook, and an activity and intent filter for Chrome Custom Tabs inside your application element:

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<activity android:name="com.facebook.FacebookActivity" android:configChanges=
            "keyboard|keyboardHidden|screenLayout|screenSize|orientation" android:label="@string/app_name" />
<activity android:name="com.facebook.CustomTabActivity" android:exported="true">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="@string/fb_login_protocol_scheme" />
  </intent-filter>
</activity>
```

- Add `Privacy Policy URL` uin `Settings => Basic => Privacy Policy URL`.
  - Click `Save Changes`
- Click `Use this package name` if you see it.
- Click `In development` to enable live mode.

  - Choose app category.
  - Click `Switch Mode`.

- Go to Facebook App => Settings => Basic
- Get App ID and App Secret
- Go to Firebase => Authentication => Sign in method
- Click Facebook
- Enable
- Paste App ID and App Secret into the relative input boxes.
- And copy `OAuth redirect URI` (before save)
- Save
- Go to Facebook Ap => Facebook Login => Settings
- Paste the `OAuth Redirect URI` into `Valid OAuth Redirect URI` box.
- Click `Save Changes`.
- That's it. To test the settings, try the code in [Facebook Sign In](#facebook-sign-in)

#### Facebook Sign In Setup for iOS

- Open `ios/Podfile`
- Uncomment the `platform` line and update it to 11.0 like below

```Podfile
platform :ios, '11.0'
```

- Add the following into Info.plist with proper values

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb{your-app-id}</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>{your-app-id}</string>
<key>FacebookDisplayName</key>
<string>{your-app-name}</string>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
  <string>fbauth2</string>
  <string>fbshareextension</string>
</array>
```

- That's it. To test the settings, try the code in [Facebook Sign In](#facebook-sign-in)

### Apple Sign In Setup for iOS

It is a mandatory to add Apple Sign In if the app has other social sign in method. Or you app will be rejected on iOS app review.

We add `Apple sign in` only on iOS platform.

- Open Xcode with the project

- Click `+ Capability` under `Runner(left pane) => Runner(TARGETS) => Signing & Capabilities`.
- Click(or double click) to enable `Sign in with Apple`.
- If you see `Signing for "Runner" requires a development team.` then, you need to apply proper signing.
- Go to Firebase => Authentication => Sign-in method
- Click Apple
- Click Enable
- Click Save
- That's it. To test the settings, try the code in [Apple Sign In](#apple-sign-in)

- Refer [Eanble Sign In with App](https://help.apple.com/xcode/mac/11.0/#/dev50571b902) for details.

### Phone Auth Setup

- Enable `Phone` under Firebase => Authentication => Sign-in method

#### Additional Phone Auth Setup for Android

- Do [Debug hash key](#debug-hash-key) for test mode.
- Do [Release hash key](#release-hash-key) for release mode.

#### Additional Phone Auth Setup for iOS

- Get REVERSED_CLIENT_ID from GoogleService-Info.plist
- Go to Runner(Left pane) => Runner(TARGETS) => Info => URL Types => Click (+) to add one,

  - And add the REVERSED_CLIENT_ID into URL Schemes.

- See [FlutterFire Phone Authentication Setup](https://firebase.flutter.dev/docs/auth/phone#setup) for details.

## Permission handler setup

## Permission handler setup for Android

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.sonub.dating">
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:protectionLevel="dangerous" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <application>
    <!-- ... -->
  </application>
  </manifest>
```

## Image Picker Setup

To upload files(or photos), we will use [image_picker](https://pub.dev/packages/image_picker) package.

### Image picker setup for Android

API 29+
No configuration required - the plugin should work out of the box.

API < 29
Add `android:requestLegacyExternalStorage="true"` as an attribute to the `<application>` tag in AndroidManifest.xml. The attribute is false by default on apps targeting Android Q.

- See [image_picker](https://pub.dev/packages/image_picker) package page for detail.

### Image Picker Setup for iOS

- Open `ios/Runner/Info.plist` with VSCode
- Add the three keys.
  - `NSPhotoLibraryUsageDescription` - describe why your app needs permission for the photo library. This is called Privacy - Photo Library Usage Description in the visual editor.
  - `NSCameraUsageDescription` - describe why your app needs access to the camera. This is called Privacy - Camera Usage Description in the visual editor.
  - `NSMicrophoneUsageDescription` - describe why your app needs access to the microphone, if you intend to record videos. This is called Privacy - Microphone Usage Description in the visual editor

Example)

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>$(EXECUTABLE_NAME) need access to Photo Library.</string>
<key>NSCameraUsageDescription</key>
<string>$(EXECUTABLE_NAME) need access to Camera.</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(EXECUTABLE_NAME) need access to Microphone.</string>
```

## Location Setup

When app boots we save user's location into Firestore. The app can do so much things with user location.

We use `location` package to get user's location.
See [location](https://pub.dev/packages/location) for more information.

### Location Setup For Android

- Open `AndroidManifest.xml` under `android/app/src/main` and add the following:

```xml
<manifest>
    ...
  <!-- add user-permission for accessing location -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
</manifest>
```

### Location Setup For iOs

- Open `Info.plist` under `ios/Runner` and add the following:

```xml
  <key>NSLocationAlwaysUsageDescription</key>
  <string>This app needs the location service enabled to provide locational information.</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app needs the location service enabled to provide locational information.</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>This app needs the location service enabled to provide locational information.</string>
```

## I18N Setup

If an app serves only for one nation with one language, the app may not need localization. But if the app serves for many nations with many languages, then the app should have internationalization. The app should display Chinese language for Chinese people, Korean langauge for Korean people, Japanese for Japanese people and so on.

You can set texts on menu, buttons, screens in different languages.

Android platform does not need to have any settings.

For iOS,

- Open `Info.plist`
- Add the following. You can add more languages.

```xml
<key>CFBundleLocalizations</key>
<array>
	<string>en</string>
	<string>ch</string>
	<string>ja</string>
	<string>ko</string>
</array>
```

- Create `translations.dart` file in the same folder of `main.dart`
  - and add the following code.
  - In the code below, we add only English and Korean. You may add more languages and translations.

Example of translations.dart

```dart
import 'package:get/get.dart';

/// Default translated texts.
///
/// This will be available immediately after app boots before downloading from
/// Firestore.
Map<String, Map<String, String>> translations = {
  "en": {
    "app-name": "App Name",
    "home": "Home",
  },
  "ko": {
    "app-name": "앱 이름",
    "home": "홈",
  }
};

/// Update translation document data from Firestore into `GetX locale format`.
updateTranslations(Map<dynamic, dynamic> data) {
  data.forEach((ln, texts) {
    for (var name in texts.keys) {
      translations[ln][name] = texts[name];
    }
  });
}

/// GetX locale text translations.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => translations;
}
```

- Open main.dart

- You can initialize fireflutter like below. It will set the default language when the user didn't choose his language yet.

```dart
await ff.init(
  settings: {
    'app': {
      'default-language': 'ko',
    }
  },
  translations: translations,
);
```

- Add `Locale(ff.userLanguage)` and `AppTranslations()` to GetMaterialApp() like below. `ff.userLanguage` has the user language.
  - If user set his own language, then it will follow the user language.
  - If the language is set on Firestore settings, it will follow the Firestore setting.
  - Or it follow the language that was set on device setting.
  -

```dart
GetMaterialApp(
  locale: Locale(ff.userLanguage),
  translations: AppTranslations(),
)
```

- Open home.screen.dart
  - Update app bar title with the following and you will see translated text in Korean.

```dart
Scaffold(
  appBar: AppBar(
    title: Text('app-name'.tr),
  ),
```

- When user change his language, the app should change the text in user's language.

Display selection box like below

```dart
DropdownButton<String>(
  value: ff.userLanguage,
  items: [
    DropdownMenuItem(value: 'ko', child: Text('Korean')),
    DropdownMenuItem(value: 'en', child: Text('English')),
  ],
  onChanged: (String value) {
    ff.updateProfile({'language': value});
  },
),
```

Then update the language like below.

```dart
class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    ff.translationsChange.listen((x) => setState(() => updateTranslations(x)));
    ff.userChange.listen((x) {
      setState(() {
        Get.updateLocale(Locale(ff.userLanguage));
      });
    });
    // ...
```

- To update translations in real time,
  - You can code like below in `initState()` of `MainApp`. It listens for the changes in Firestore translations collection and update the screen with the translations.

```dart
ff.translationsChange.listen((x) => setState(() => updateTranslations(x)));
```

- Admin can overwrite the translated texts simply by updating it under `/translations` collection in Firestore.
  - Go to Firestore
  - Create `translations` collection if it is not existing.
  - Create `en` document if not existing.
  - Add(or update) `app-name` property in `en` document.
  - And you will see the `app-name` has changed on the app.

## Push Notification Setup

- Settings of push notification on Android and iOS platform are done in the sample app.

- Refer to [Firestore Messaging](https://pub.dev/packages/firebase_messaging)

  - If you are not going to use the sample app, you need to setup by yourself.

### Additional Android Setup

- If you dont have `google-services.json` yet, you may refer for the
  basic configuration of [Android Setup](#android-setup).
- If you want to be notified in your app (via onResume and onLaunch) when you
  click the notification on the system tray you need to include the following `intent-filter`
  under the `<activity>` tag of your `android/app/src/main/AndroidManifest.xml`.

```xml
<activity>
  <!-- default configuration here -->
  <intent-filter>
      <action android:name="FLUTTER_NOTIFICATION_CLICK" />
      <category android:name="android.intent.category.DEFAULT" />
  </intent-filter>
</activity>
```

- For testing on real device you need to add the `SHA certificate fingerprints` on your firebase console project.
  - To get the SHA-1 you can refer to [Debug hash key](#debug-hash-key).
  - Open [Firebase Console](https://console.firebase.google.com)
  - Project `Settings` => `General` => `Your Apps`, Select `Android apps` then under `SHA certificate fingerprints`
    you can add the SHA-1 that you have copy from your pc.

### Additional iOS Setup

- To Generate the certificate required by Apple for receiving push notifcation.
  You can follow this guideline [Generate Certificates](https://firebase.google.com/docs/cloud-messaging/ios/certs)
  Skip the section titled "Create the Provisioning Profile".

- If you dont have `GoogleService-Info.plist` yet, you may refer for the
  basic configuration of [iOS Setup](#ios-setup).

- Open Xcode, select `Runner` in the Project Navigator.
  In the `Capabilities` Tab turn on `Push Notifications` and `Background Modes`, and
  enable Background fetch and Remote notifications under Background Modes.

- Follow the steps in the [Upload your APNs certificate](https://firebase.google.com/docs/cloud-messaging/ios/client#upload_your_apns_certificate)
  section of the Firebase docs.

- Add/Update Capabilities.

  - In Xcode, select `Runner` in the `Project Navigator`. In the `Capabilities Tab` turn on `Push Notifications` and `Background Modes`, and enable `Background fetch` and `Remote notifications` under `Background Modes`.

- If you need to disable the method swizzling done by the FCM iOS SDK (e.g. so that you can use this plugin with other notification plugins)
  Add the following into Info.plist

```Info.plist
  <key>FirebaseAppDelegateProxyEnabled</key>
  <false/>
```

- To test the setup, try the code in [Push Notification](#push-notification)

- For more detailed information about Firebase messaging refer [Firestore Messaging](https://pub.dev/packages/firebase_messaging)

## Algolia Setup

Firestore does not support full text search, which means users cannot search the title or content of posts and comments. But this is a must functionality for those apps that provide a lot of information to usres.

One option(recomended by Firebase team) to solve this matter is to use Algolia. Algolia has free account that gives 10,000 search every months. This is good enough for small sized projects.

Before setup Algolia, you may try forum code as described in [Forum Coding](#forum-coding) to test if this settings work.

- Go to Algolia site and Register.
- Create app in Algolia.
- Then, you need to add(or update) ALGOLIA_APP_ID(Application ID), ALGOLIA_ADMIN_API_KEY, ALGOLIA_INDEX_NAME in Firestore `settings/app` document.
  Optionally, you can put the settings inside `FireFlutter.init()`.

## Admin Account Setting

You can set a user to admin by updating user document of Firestore directly. Admin property is protected by Firestore security rules and cannot be edited by client app.

- Do [User Email And Password Registration](#user-email-and-password-registration) and register with a user as `admin@user.com`.

  - You may add a user manually by entering email and password under Users in Firebase Authentication. But we recommend you to create a user account through the app after coding registration page.

- Open Firebase => Authentication => Users
  - And Copy `User UID` of `admin@user.com`.
- Open Firebase => Firestore

  - You will see `users` collection under data tab. Click `users`
  - Search the `User UID` of `admin@user.com`
    - And click the `User UID`.
  - Click `+ Add field`.
  - Input `isAdmin` in Field.
  - Select `boolean` in Type.
  - Select `true` as Value.
  - Click Add

- Now the user is an admin.

# App Management

- The app management here is based on the sample code and app.
- FireFlutter is a flutter package to build social apps and is fully customizable. When you may build your own customized app, we recommend to use our sample codes.

## App Settings

- Developers can set default settings on `FireFlutter.init()`.
- Admin can overwrite all the settings by updating Firestore `settings` docuemnts.

## Internalization (Localization)

- Menus and page contents can be translated depending on user's device. Or developer can put a menu to let users to choose their languages.

- When admin update the translation text in Firestore `translations` collectin, the will get the update in real time. The app, should update the screen.

- The localization is managed by `GetX` package that is used for routing and state management on the sample code.

## Forum Management

### Forum Category Management

Forum category is a list(or a collection) of posts to differentiate from each kind. Category ID is a word(or words with dash separated) like `reminder`, `qna`, `discussion`, `public-photos` or whatever you want.

- Post can be created only under an existing category.
- You can create forum categories editing `categories` collection in Firestore
  - Or if there is an admin screen, admin may do so in admin screen.

To create a creategory,

- Open `Cloud Firestore`
- Create the `categories` collection if it is not present( by clicking `+ Start collection`)
- Then click `add a document`.
  - Put category id in `Document ID` and this should not be changed after.
  - And put `id` in Field column and the same category id in Value column.
  - You may optionally add more Field with `title` and `description`.

# Developer Coding Guidelines

## General Setup

- Add latest version of [FireFlutter](https://pub.dev/packages/fireflutter) in pubspec.yaml
- Add latest version of [GetX](https://pub.dev/packages/get).
  - We have chosen `GetX` package for routing, state management, localization and other functionalities.
    - GetX is really simple. We recommed you to use it.
    - All the code explained here is with GetX.
    - You may choose different packages and that's very fine.

## FireFlutter global variable

- The variable `ff` is an instace of `FireFlutter` and should be shared across all the screens.

- Create a `global_variables.dart` on the same folder of main.dart.

  - And move the `ff` variable into `global_variables.dart`.

- The complete code is on [fireflutter sample app](https://github.com/thruthesky/fireflutter_sample_app/blob/main/lib/global_variables.dart) of sample app.

### FireFlutter Initialization

There are two ways of initializing the fireflutter package. One is blocking and the other is non-blocking. This is deu to initializing Firebase inside fireflutter. We recommend non-blocking method since the app would boot faster.

#### Blocking mode

- Import global variable of fireflutter instance - `ff`.
- You need to call `WidgetsFlutterBinding.ensureInitialized()` before `ff.init()`.

```dart
import 'package:fireflutter/fireflutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ff.init();
  runApp(MainApp());
}
```

#### Non-blocking mode

- For non-blocking mode, the `ff.init()` could be in `MainApp()` or any where after `runApp()` call.

```dart
import 'package:fireflutter/fireflutter.dart';
void main() async {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    ff.init();
  }
```

- But be sure the app accesses any Firebase related function only after it is initialized.
  - Or the app would get `[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()` error.
  - To avoid this error(or to use Firebase after it is initialized), use `ff.firebaseInitialized.listen` stream.
    Since it is a stream, you need to cancel listening after use.

```dart
String gender = '';
// ...
ff.firebaseInitialized.listen((re) async {
  if (re == false) return;
  var doc = await FirebaseFirestore.instance
      .collection('users')
      .doc('KXfKXYdAUUgvO9pxOAfKQexZmjD3')
      .get();
  setState(() {
    gender = 'Genger: ' + doc.data()['gender'];
  });
});
// ...
Text(gender)
```

- To make it easy, you may create a custom wiget to wait to until Firebase is initialized.

```dart

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: FirebaseReady( /// Use FirebaseReady.
          builder: (BuildContext context, snapshot) {
            if (snapshot.data == null || snapshot.data == false)
              return Container();
            else
              return Text(
                'Firbase Ready. User login: ${ff.loggedIn ? 'yes' : 'no'}',
              );
          },
        ),
      ),
    );
  }
}

/// Display [child] widget only after Firebase is initialized.
class FirebaseReady extends StatelessWidget {
  const FirebaseReady({
    Key key,
    this.builder,
  }) : super(key: key);

  final Function builder;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ff.firebaseInitialized,
      builder: builder,
    );
  }
}
```

- `FirebaseReady` will wait until Firebase firebase is initialized and then it will display the child widget.

- It is worth to know that check firebase is initialization with `ff.firebaseInitialized` or `FirebaseReady` widget may only be needed on home screen(or first screen) since Firebase will initialize itself quick enough and be ready by next screen.

### Add GetX

- To add GetX to Flutter app,
  - open main.dart
  - split `Home Screen` into `lib/screens/home/home.screen.dart`.
  - and replace `MaterialApp` with `GetMaterialApp`.
  - add `initialRotue: 'home'`
  - add HomeScreen to route.
  - To see the complete code, visit [getx branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/install-getx).

## Firestore Structure

- Principle. Properties and sub collections(documents) of a document should be under that document.

- `users/{uid}` is user's private data document.

  - `users/{uid}/meta/public` is user's public data document.
  - `users/{uid}/meta/tokens` is where the user's tokens are saved.

- `/posts/{postId}` is the post document.
  - `/posts/{postId}/votes/{uid}` is the vote document of each user.
  - `/posts/{postId}/comments/{commentId}` is the comment document under of the post document.

## User

- `null` event will be fired for the first time on `FireFlutter.userChange.listen`.
- `auth` event will be fired for the first time on `FirebaseAuth.authChagnes`.

- Private user information is saved under `/users/{uid}` documentation.
- User's notification subscription information is saved under `/users/{uid}/meta/public` documents.
- Push notification tokens are saved under `/users/{uid}/meta/tokens` document.

## Create Register Screen

- Do [General Setup](#general-setup).
- Create register screen with `lib/screens/register/register.screen.dart` file.
- Put a route named `register`
- See complete code on [route banch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/routes)

## Create Login Screen

- See complete code on [route banch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/routes)

## Create Profile Screen

- See complete code on [route banch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/routes)

## User Email And Password Registration

- Open register.screen.dart
- Put a button for opening register screen.
- Then, add email input box, password input box and a submit button.

  - You may add more input box for displaName and other informations.
  - You may put a profile photo upload button.

  - For the complete code, see [register branch in sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/register/lib).

- When the submit button is pressed, you would write codes like below for the user to actually register into Firebase.

```dart
try {
  User user = await ff.register({
    'email': emailController.text,
    'password': passwordController.text,
    'displayName': displayNameController.text,
    'favoriteColor': favoriteColorController.text
  });
  // register success. App may redirect to home screen.
} catch (e) {
  // do error handling
}
```

- It may take serveral seconds depending on the user's internet connectivity.
  - And FireFlutter package does a lot of works under the hood.
    - When the `register()` method invoked, it does,
      - create account in Firebase Auth,
      - update displayName,
      - update extra user data into Firestore,
      - reload Firebase Auth account,
      - push notification token saving,
        thus, it may take more than a second. It is recommended to put a progress spinner while registration.
- As you may know, you can save email, display name, profile photo url in Firebase Auth. Other information goes into `/users/{uid}` firebase.
- After registration, you will see there is a new record under Users in Firebase console => Authentication page.

- Visit [register branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/register) for registration sample code.

- You can add some extra public data like below.
  - User's information is private and is not available for other.
  - User's public data is open to the world. But it can only be updated by the user.

```dart
User user = await ff.register({
  // ...
}, meta: {
  "public": {
    "notification_post": true,
    "notification_comment": true,
  }
});
```

- There is another branch for more complete regration sample code. See [register-v2 branch](https://github.com/thruthesky/fireflutter_sample_app/tree/register-v2) for more complete regiration code.
- We recommend you to copy the sample code and apply it into your own project.

## Display User Login

Let's display user login information on home screen.

- Open home screen with Xcode
- Code like below

## Login with email and password

Let's create a login page.

- `login()` method of fireflutter will handle email and password login.

```dart
await ff.login(
    email: emailController.text,
    password: passwordController.text);
```

## Profile update

- See [profile.screen.dart in profile update branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/blob/profile-update/lib/screens/profile/profile.screen.dart)

## Create admin page

- Do [Admin Account Setting](#admin-account-setting)
- Login as the admin account.
- Add a button on home screen like below.

```dart
if (ff.isAdmin) ...[
  Divider(),
  RaisedButton(
    onPressed: () => Get.toNamed('admin'),
    child: Text('Admin Screen'),
  ),
],
```

- See the code in [login-with-email-password branch](https://github.com/thruthesky/fireflutter_sample_app/blob/login-with-email-password/lib/screens/login/login.screen.dart).

- Create admin.screen.dart under lib/screens/admin foler.
  - And code like below

```dart
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
      ),
      body: Container(),
    );
  }
}
```

- Add admin screen route like below in main.dart

```dart
GetMateriaApp(
  getPages: [
    GetPage(name: 'admin', page: () => AdminScreen()),
  ]
)
```

- Now, you will be able to login admin page. A user may accidentally enter admin page but he cannot see administrative information since Firestore security rules are in blocking the middle.

- See [admin-page branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/admin-page) for complete code.

## Forum Coding

FireFlutter does not involve any of the app's in UI/UX. Because of this, you can customize your app as whatever you like.

There are many works to do to complete forum functionality.

### Create forum category management screen

- Do [Admin Account Setting](#admin-account-setting)
- Login as the admin account.
- Do [Create admin page](#create-admin-page)
- And see [forum-admin branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/category-admin) for the code of forum category management page.
  - The code is in `lib/screens/admin/admin.category.screen.dart`.
- Then, create a category ID as 'qna'.

### Create post edit screen

In forum edit screen, user can create or update a post and he can upload photos.

- You need to create 'qna' category as described in [Create forum category management screen](#create-forum-category-management-screen)
- And follow the code in [forum-edit branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/post-create)

  - In the code,
    - Forum edit screen is created at `lib/screens/forum/forum.edit.dart`
    - And the route is added in main.dart
    - A button is added in home.screen.dart to open forum edit screen.

- Post create and update are done with `editPost()` method.
  - If `id` is null, then, it will create a post. Or it will update the post of the id.

```dart
ff.editPost({
  'id': post == null ? null : post['id'],
  'category': category,
  'title': titleController.text,
  'content': contentController.text,
  'uid': ff.user.uid,
});
```

- See [sample app's post-edit branch](https://github.com/thruthesky/fireflutter_sample_app/tree/post-create)

### Photo upload

To upload a photo(or any file), we are going to put a photo upload button(or camera icon) for user to choose a phone.

- Do [Create post edit screen](#create-post-edit-screen)
- Do [Image Picker Setup](#image-picker-setup)
- FireFlutter's `uploadFile()` method will do the upload. The parameters are,

  - `folder` - where the uploaded file would be saved under Firebase Stroage.
  - `source` - the `ImageSource` to tell the app to get images from. It would be Gallary or Camera.
  - `progress` - callback function to get upload progress in percentage.
  - `quality` - jpeg quality
  - `maxWidth` - max width of image.

- When user click file upload icon, the app should show a dialog or bottom sheet for user to choose to get photo from Camera or Gallery.
- After user choose the choice where to get photo, it needs to call `uploadFile()` with the parameters.
- See [sample app's file-upload branch](https://github.com/thruthesky/fireflutter_sample_app/tree/photo-upload) for complete code.
  - Code for deleting uploaded photo is not in the branch. We will cover it on post update branch.

### Create post list screen

We have put the concept of the forum functionality to work in real time which means if a user creates a comment, it will appear on other user's phone immediately (without reloading).

To manage forum data, you need to create an instance of `ForumData` class.
It needs to `category` of the forum and a callback which will be called if there any update to re-render the screen.

Call `fetchPosts()` method the ForumData instance and fireflutter will get posts from Firestore storing the posts in `ForumData.posts` and the app can render the posts within the callback of ForumData instance.

- Do [Firestore security rules](#firestore-security-rules). When the app list posts, it will require indexes.
- Do [Cloud Functions Setup](#cloud-functions-setup). When the app is displaying posts, the Clould Funtions soubld be ready.
- See [smaple app's forum-list branch](https://github.com/thruthesky/fireflutter_sample_app/tree/forum-list) for the sample code.
  - You would open [forum.list.dart](https://github.com/thruthesky/fireflutter_sample_app/blob/forum-list/lib/screens/forum/forum.list.dart) to see what's going on to list a forum.
    - It first gets category
    - then, fetches posts
    - then, display it in list view.
    - If there is no post existing, then it will dispaly 'no post existing' message.
    - If there is no more posts to fetch, then it will display 'no more posts' message.
    - It has a `+` button to open post create screen.
    - It has a code for infinite scrolling to fectch more posts.
  - The code is not complete. Many functionalities are missing like editing, voting for like and dislike, deleting, etc. We will cover this things on the following code samples.

### Post list with photos

- Do [Create post list screen](#create-post-list-screen)
- See [sample app's forum-list-with-photo branch](https://github.com/thruthesky/fireflutter_sample_app/tree/forum-list-with-photo). It is an extented example of [Create post list screen](#create-post-list-screen) with photo list.
  - Code for displaying images is very simple. You just need to add the code below into the list view.

```dart
if (post['files'] != null)
  for (String url in post['files'])
    Image.network(url)
```

### Post edit

- Do [Create post edit screen](#create-post-edit-screen)
- Do [Create post list screen](#create-post-list-screen)
- The only thing that takes to edit post is to add a button to open post edit page. That's it. all the code is already done in [Create post edit screen](#create-post-edit-screen) section.
- You cannot edit other user's post. you may customise UX to prevent for the user to enter forum edit screen when it is not his post.

### Post delete

- Do [Post edit](#post-edit)
- And add the follow code

```dart
RaisedButton(
  onPressed: () async {
    try {
      await ff.deletePost(post['id']);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  },
  child: Text('Delete'),
),
```

- See [sample app's post delete branch](https://github.com/thruthesky/fireflutter_sample_app/tree/post-delete) for sample code.

### Photo delete

- Do [Post edit](#post-edit)
- See [sample app's photo edit branch](https://github.com/thruthesky/fireflutter_sample_app/tree/photo-delete) for detail code.

### Voting

- Do [Create post list screen](#create-post-list-screen)
- See [sample app's vote branch](https://github.com/thruthesky/fireflutter_sample_app/tree/vote) for the code.
- You may customise UI/UX of vote funtionality.
  - You may show/hide vote buttons based on forum settings.
  - You should show a progress indicator ( or disable ) while the voting is in progress.

#### Logic for Vote

Voting is actually a simple logic but when it comes with the Firestore security, it is a hard to achevie.

Imagin anyone can update the no of likes or dislikes on any post or comment, then the no of votes would be untrustable.

It must be protected by the security rules, not by the logic of the code alone.

The logic of the vote should like below;

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
    So, client app should block (by showing a progress indicator) the user not to vote again while voting is in progress.

- Note. the logic is to be chagned as described at https://github.com/thruthesky/fireflutter/issues/3

### Comment crud, photo upload/update, vote like/dislike

If you are following the path of how to create a post, list posts, and edit post, then you would have be familiar with fireflutter. If not, please practice more.

[Comment crud branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/comment-crud) has all the source code. The code is a bit long since it has comment create form, comment list, photo upload, buttons. So, the codes are splitted into small sized of widgets.

## Search

- Do [Algolia Setup](#algolia-setup)
- See [sample app's algolia branch](https://github.com/thruthesky/fireflutter_sample_app/tree/algolia) for the code.

## Push Notification

- FireFlutter comes with `Push Notification functionality`. It is disable by default.

- When user registers, the settings of receiving message for new comment under my post or comment will be enabled by default.

- When the app boots the device will record its `push notification token` to Firestore and subscribe to `allTopic`.

  - This means, when you released your app without push notification enabled, the device will not save tokens to Firestore and does not subscribe to `allTopic`.
    - So, it is important to enable from the first publish.
  - Whether `push notification` is enabled or not, all devices(users) is going to subscribe to `notify new comment unber my post` and `notify new comment under my comment` by default.

- Do [Push Notification Setup](#push-notification-setup)
- To enable push notification you must set `enableNotification: true` on main in `FireFlutter init()`.
- Once enabled it will ask the user if they want to receive push notification in iOS.
- For android it was done automatically.
- By default it subscribes to `allTopic`. So you can use this topic to send to all users.
- It also subscribes to `notification_post` when new comment is created under the user post it will receive notification.
- And `notification_comment` when a comment is created under the user comment it will receive notification also.
- Push Notification includes

  - Subscribe/Unsubscribe to topic
  - Sending notification to `Topic`, `Token`, `list of tokens`

- To use the `sendNotification()` you must provide the `Cloud Messaging Server Key` from your Firebase Console.

  - To get the Server key login to [Firebase Console](https://console.firebase.google.com)
  - Select your current `project`, then go to `Project Settings`.
  - Click `Cloud Messaging` and under `Project Credentials` you can Copy the `Server key Token`.

- Enabling push notification and providing cloud messaging server key.

```dart
  @override
  void initState() {
    super.initState();
    ff.init(
        enableNotification: true,
        firebaseServerToken: "AAAAj...bM:APA91....ist2N........AAA"
      );
  }
```

- To handle the notification message you can listen to it using the `ff.notification.listen(() {})`
- The return data has 3 Notification type `onMessage` , `onLaunch` , `onResume`.
- Meaning you can handle the message depending when you have receive the message.
- For example when you recieved the notification

  - And you need to show an alert message, if it was send while the app is open.
  - Or move to specific page when you click the notification from tray.

- Listening to incoming notification.

```dart
void initState() {
  super.initState();

  ff.init(
      enableNotification: true,
      firebaseServerToken: "AAAAj...bM:APA91....ist2N........AAA"
    );

  ff.notification.listen(
        (x) {
          Map<dynamic, dynamic> notification = x['notification'];
          Map<dynamic, dynamic> data = x['data'];
          NotificationType type = x['type'];
          if (type == NotificationType.onMessage) {
            // Display or Alert the notification message
          } else {
            // Move to different Screen
          }
        },
      );
}
```

- Sending push notification
  - Providing `topic` as string will send notification to that topic. This is the recommended way of sending push notification.
  - Providing `token` as string will send to specific Device.
  - Providing `tokens` as list of string will send to list of Device provided. Sending multiple tokens has limitation. See the comment of the code.

```dart
RaisedButton(
  onPressed: () async {
      ff.sendNotification(
        'title message only',
        'test body message',
        id: '0X1upoaLklWc2Z07dsbn',
        screen: '/forumView',
        token: 'Replace DeviceToken here',
      );
    });
  },
  child: Text('Send Notification to Token.'),
),
RaisedButton(
  onPressed: () async {
      ff.sendNotification(
        'title message only',
        'test body message',
        id: '0X1upoaLklWc2Z07dsbn',
        screen: '/forumView',
        topic: ff.allTopic,
      );
    });
  },
  child: Text('Send Notification to topic.'),
),
RaisedButton(
  onPressed: () async {
      ff.sendNotification(
        'title message only',
        'test body message',
        id: '0X1upoaLklWc2Z07dsbn',
        screen: '/forumView',
        tokens: ['Device Token', 'Another Device Token'],
      );
    });
  },
  child: Text('Send Notification to multiple tokens.'),
),
```

### Notification Settings for the Reactions

Push notification is one kind of basic functionality that all apps should have. Hence, we put some push notification logic inside fireflutter. Once the app has enabled push notification settings, it will automactially activate push ntoification with following;

- By default, all users had subscribed to `notify new comment unber my post` and `notify new comment under my comment` when they registered.

  - They can turn it off in settings page. You have to implement the settings screen. See [sample app's settings branch](https://github.com/thruthesky/fireflutter_sample_app/tree/settings) for the code.

- To test,
  - Run app in device A and login with user A and Run app in device B and login with user B
  - User A creates a post
  - User B creates a comment under the post
  - And A will get a push notificaiton.
  - Now, user A creates a comment under the comment of User B.
  - Then, user B will get a push notificaiton.

### Notification Settings for Topic Subscription

A user can subscribe
- Forum for new post or comment.
- Chat room for new chats.
- And much more.

- To enable the subscription, you need to put on/off swich some where(forum list or chat room). When it is swtiched on, then it need to subscribe to the topic name.
  - All topic must begin with `notify`. For instance `notify-post-qna`, `notify-comment-disucssion`, `notify-chatroom-roomId`, and so on.
    - You can name topic anything you want as long as that starts with `notify`.
  - And save the topic as a boolean property in `/meta/user/public/{uid}` and when the user's auth state changes, it will re-subscribe all the topics. Therefore all devices of the user will be synced to subscribe same topics.
  - See `Cavists of push notification`


- See [forum-subscription branch](https://github.com/thruthesky/fireflutter_sample_app/tree/forum-subscription) for the code.

### Logic of Push Notification





#### Cavits of push notification

- When a user A subscribed a topic with his three devices D1, D2.
  - And A unsubscribes a topic from device D1,
  - But A will still get push notifications from devices D2 until A restarts(or auth state changes) the app on B, C.
- Another cavits is,
  - A logs in both D1 and D2.
  - A subscribes to a new topic in D1, 
  - Then D2 will not get message from that device until A restarts(or auth state chnages) the app in P2 again.

- This is the limitation of `Flutter Firebase SDK - Cloud Messaging` package. Other SDKs like Nodejs Admin SDK, PHP Admin SDK have a method to subscribe to a topic by specifying tokens.
  - If `Flutter Firebase SDK - Cloud Messaging` allows this, then when D1 subscribes(or unsubscribes) to a topic, the app can get all the tokens of the user and subscribes(or unsubscribes) to the topic with all the tokens. But since this is not supported, we will just wait until the SDK changes.

## Social Login

### Google Sign-in

- [Google Sign In Setup for Android](#google-sign-in-setup-for-android) and [Facebook Sign In Setup for Android](#facebook-sign-in-setup-for-android) are required.
- Open login.screen.dart or create following [Create Login Screen](#create-login-screen)
- Code like below,
  - You can use the social Login by calling fireflutter `signInWithGoogle` method.

```dart
RaisedButton(
  child: Text('Google Sign-in'),
  onPressed: () async {
    try {
      await ff.signInWithGoogle();
      Get.toNamed('home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  },
),
```

- After login, the user will be redirected to home screen. Add some code like what is described in [Display User Login](#display-user-login).

- Tip: you may customize your registration page to put a button saying `Login with social accounts`. When it is touched, redirect the user to login screen where actual social login buttons are appear.

### Facebook Sign In

- [Google Sign In Setup for Android](#google-sign-in-setup-for-android) and [Facebook Sign In Setup for Android](#facebook-sign-in-setup-for-android) are required.
- Open login.screen.dart or create following [Create Login Screen](#create-login-screen)
- Code like below,

```dart
RaisedButton(
  child: Text('Facebook Sign-in'),
  onPressed: () async {
    try {
      await ff.signInWithFacebook();
      Get.toNamed('home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  },
),
```

### Apple Sign In

- Do [Apple Sign In Setup for iOS](#apple-sign-in-setup-for-ios).
- Apple sign in may not work for some versions of simualtor. We recommend you to test the code in real device.

```dart
if (GetPlatform.isIOS)
  SignInWithAppleButton(
    onPressed: () async {
      try {
        await ff.signInWithApple();
        Get.toNamed('home');
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    },
  )
```

## External Logins

### Kakao Login

- Kakao login is completely separated from `fireflutter` since it is not part of `Firebase`.
  - The sample app has an example code on how to do `Kakao login` and link to `Firebase Auth` account.

## Phone Verification

FireFlutter phone verication relies on Firebase's Phone Authentication. We made it easy to use.

The app can ask users to verify their phone numbers. It is fully customizable, but we put here few recommendations on its implementation.

Admin can set rules like below

- Verify phone after email/password registration.
- Verify phone after login(all login including social login).
- Force users to verify phone or the app does not work.
- Block users to create post or comment without phone verification.

We will apply this rules to the [sample app's phone-verification branch] and it is upto you weather you would follow this rules or not. You may want to block users to create post or comment differently on each forum.

Do apply the rules,

- Do [Additional Phone Auth Setup for iOS](#additional-phone-auth-setup-for-ios).
- Push notification

- First, you will need to add a setting in main.dart. Admin can overwrite all the settings in main.dart through Firestore `settings/app` document update.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ff.init(
    settings: {
      'app': {
        'verify-after-register': true,
        'verify-after-login': true,
        'force-verification': false,
        'block-non-verified-users-to-create': true,
      },
    },
  );
  runApp(MainApp());
}
```

- We recommend you to use [country_code_picker](https://pub.dev/packages/country_code_picker) package for selecting country code. But it's up to you to use it or not.

- If the app is forcing users to verify their numbers,

  - skip button shouldn't appear but the user can still go back.
  - all the menu will redirect phone auth page except home screen.
    This is done in `redirectCallback()` of `main.dart` in phone-verification branch.

- If `block-non-verified-users-to-create` is set to true,

  - It displays warning dialog when user press on create button.
  - It displays warning dialog when user submit comment button.

- See [sample app's phone verification branch](https://github.com/thruthesky/fireflutter_sample_app/tree/phone-verification) for codes. Again, it is fully customizable.

# Language Settings, I18N

`I18n` means to display different languages for different users. For instance, App will display texts in Korean for Korean people.

We decided to adopt `GetX i18n` feature. See [GetX Internationalization](https://pub.dev/packages/get#internationalization) for details

- If you want to add a language, do [I18N Setup](#i18n-setup)
- See [sample app's language settings branch](https://github.com/thruthesky/fireflutter_sample_app/tree/language-settings) for the code.

# Settings

- Default settings can be set through `FireFlutter` initialization and is overwritten by `settings` collection of Firebase.
  The Firestore is working offline mode, so overwriting with Firestore translation would happen so quickly.

## Phone number verification

We recommend you to follow our logic of phone number verification. You need to copy the code from sample app. You can customise everything byself, though.

- If `verify-after-register` in `/settings/app/{verify-after-register: boolean }` is set to true, then newly registered users will be directed to phone verification screen.

- If `verify-after-login` in `/settings/app/{verify-after-login: boolean }` is set to true, then unverified users will be directed to phone verification screen.

- If `force-verification` is set to true, then all user must verify to continue using app.

- If `block-non-verified-users-to-create` is set to true, non verified users cannot create post or comment.

## Forum Settings

All the settings of forum are overwritable by `/settings` collection in real time.

For instance, to get the settings of showing like or dislike buttons, the app will

- look for settings in the forum category at `/settings/{category name}` document, and if there is no settings about it
- then, look for settings in the forum at `/settings/forum` document, and if there is no settings about it,
- then, look for settings in `ff.init(settings: { ... })`, and if there is no settings about it,
- then, it will use the hard coded setting in fireflutter.

The `/settings/forum` has global settings of all forum categories and can be overwritten by each category setting. For instance, the settings are set like `/settings/forum/{like: true}` and `/settings/qna/{like: false}`. Then like button will appear on all forum categories except qna category.

The settings are

- like: boolean
- dislike: boolean
- no-of-posts-per-fetch: int

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

# Chat

If you are looking for a package that support a complete chat functionality, fireflutter is for you. Unlike other sample (tutorial) code on the Internet, it has really complete features like

- listing my room list (chat list or friend list).
- group chat
- creating chat room with one user or multip users.
- adding user.
- blocking user.
- search user.
- sending photo
- changing settings of the room like room title update.
- and much more.

## Preview of chat functionality

- All chat functionality works with user login. If a user didn't log in, then the user must not be able to enter chat screen.
- All chat related methods throw permission error when a user tries something that is not permitted.
- To use chat functionality, `openProfile` option of `ff.init()` must be set.

## Firestore structure of chat

Before we begin, let's put an assumption.

- There are 3 users. User `A`, user `B`, user `C`, and user `D`. User A is the moderator which means he is the one who created the room.
- The room that moderator A created is `RoomA` and there are two users in the room. User A, B.
- The UIDs of user A, B, C, D is A, B, C, D respectively.
- The room id of RoomA is RoomA.

Firestore structure and its data are secured by Firestore security rules.

- `/chat/info/room-list/{roomId}` is where each room information(setting) is stored.
  - When a room is created, the `roomId` will be autogenrated by Firestore by adding a document under `/chat/info/room-list` collection.
  - Document properties
    - `moderators` is an array of user's uid. Users in this array are the moderators.
    - `users` is an array of participant users' uid.
    - `blockedUsers` is an array of blocked users' uid.
    - `createdAt` has the time when the chat room was created.
    - `title` is the title of chat room.
  - When `{users: [ ... ]}` is updated to add or remove user, other properties cannot be edited.
- `/chat/my-room-list/{uid}/{roomId}` is where each user's room list are stored. The document has information about the room and last message.
  - If a user has unread messages, it has no of new messages.
  - It has last message information of who sent what, time, and more.
  - It may have information about who added, blocked.
    When A chat in RoomA, the (last) message goes to `/chat/info/room-list/RoomA` and to all the users in the room which are
    - `/chat/my-room-list/A/RoomA`
    - `/chat/my-room-list/B/RoomA`
  - Document properties

```text
{
  text: is the text.
  createdAt: FieldValue.serverTimestamp() indicating when the message created.
  newMessages: no of unread messages.
  senderUid: the sender uid.
  senderDisplayname: the sender name.
  senderPhotoURL: the sender photo URL.
  photoURL: if there is a photo coming from the sender.
}
```

- `/chat/messages/{roomId}/{message}` is where all the chat messages for the room are stored.

## Logic of chat

- User who begin(or create) chat becomes the moderator.
- Moderator can add another moderator.
- User will enter `chat entrance screen` and the app should display all of the user's chat room list.
- User may search another user by openning a `user search screen` and select a user (or multiple users) to begin chat. Then the app should redirect the user to `chat room screen`
- User can enter chat room by selecting a chat room in his chat room list.
- User can add other users by selecting add user button in the chat room.
- User can create a chat room with the same user(s) over again. That means, A can begin chat with B by creating a room. And then, A can begin chat with B again by creating another room.
- When a room is created, `ChatProtocol.roomCreated` message will devlivered to all users.
  - This protocol message can be useful to display that there is no more messages or this is the first message.
- When a room is added, `ChatProtocol.enter` message (with user information) will devlivered to all users.
- When a room left, `ChatProtocol.leave` message (with user information) will devlivered to all users.
- When a user is blocked, `ChatProtocol.block` message will (with user information) devlivered to all users. Only moderator can blocks a user and the user's uid will be saved in `{ blockedUsers: [ ... ]}` array.
- When a room is created or a user is added, protocol message will be delivered to newly added users. And the room list will be appears on their room list.
- Blocked users will not be added to the room until moderator remove the user from `{ blockedUsers: [ ... ]}` array.
- When a user(or a moderator) leaves the room and there is no user left in the room, then that's it.
- When a user logs out or logs into another account while listening room list will causes permission error. Especially on testing, you would not open chat screen since testing uses several accounts at the same time.
- Logically, a user can search himself and begin chat with himself. This is by design and it's not a bug. You may add some logic to prevent it if you want.
- When a user is blocked by moderator, the user received no more messages except the `ChatProtocol.blocked` message.

## Pitfalls of chat logic

- User cannot remove(or block) another user. Only moderator can do it.
  - A add B.
  - B goes offline.
  - B add C. Since Firebase works offline, B can still add user C even if he has no connection.
  - A add D.
  - At this point, there are [A, B, D] in the room. C is not added yet, since B was offline when he added C.
  - B goes online and tries to update users array with [A, B, C].
    - It will produce permission error since, the users in the room is [A, B, D] and when B updates [A, B, C], D is missing. It is like B is trying to add C and remove D.

## Code of chat

- The best code sample is in firefutter sample app.


### Preparation for chat

- By default, app can search users by name in `/meta/user/public/{uid}`. You may extend to search by gender and age.
  - And it requires `openProfile` option to be set in `fireflutter` initialization like below.
  - This option updates user's profile name and photo under `/meta/user/public/{uid}` and a user can search other users name and photo.

```dart
ff.init({
  'openProfile': true,
})
```

### Begin chat with a user

- Let's assume there are user A, B, C and whose UIDs are also A, B, C respectively.
  - And A is the logged in user(of current device).
- To create a chat room, you can create an instance of `ChatRoom`.
  - The code below creates a room without users but the login user himself. A will be alone in the room.
```dart
ChatRoom(inject: ff);
```

- To create a chat room with user B,

```dart
ChatRoom(inject: ff, users: ['A']);
```


- You would code like below to enter a chat room.
  - if `id` (as chat room id) is given, it will enter the chat room and listens all the event of the room.
  - Or if `id` is null, then a room will be created with the `users` of UIDs list.
  - If both of `id` and `users` are null(or empty), then a room will be created without any users except the login user himself. He will be alone in the room.
  - If both of `id` and `users` have value, then, it enters the room if the room of the `id` exists. Or it will create a room with the `id` and with the users.
    - This will be a good option for 1:1 chat. If the app only allows 1:1 chat, or the user chats to admin for help, this will be a good option.
    - The `id` can be an md5 string of the login user's uid(A) and other user's uid(B).
      - When it creates the room, it will create a room for A and B, and next time A or B try to chat each other again, it will not create a new room. Instead, it will use previously created room.

- One important thing to know is when A begins to chat with B, a new room will be create for A and B.
  - And later A begins to chat with B again, then another room for A and b will be created.
  - This is by design to create new room over and over again with same user. 
  - You may code to block this.


- Below is a sample code to enter a chat room. If it has an incoming room id, then it will enter that room. Or it will create a room with uid1.
  - If the user is entering from chat room list, then there will be room id.
  - Or if the user is entering by searching user, then it will create a room.
  - In this way, it will create rooms over again with same user.

```dart
class A extends StatefullWidget {
  ChatRoom chat;
  @override
  initState() {
    chat = ChatRoom(
      inject: ff,
      id: argument['id'],
      users: ['uid1']
      render: () {
        setState(() {});
      },
    );
  }
}
```

- Below is a sample code to show to block creating rooms again with same user.
  - When A creates a room for the first time, it sets the room id of MD5 string based on uid. So, next time when the user begins to chat with same user again, it will not create a new room id, instead, it will use the same room id of MD5 string. So, it will not create a new room any more. the user continues to chat in previous chat room.

```dart
String id;
if (args['id'] == null) {
  var digest = md5.convert(utf8.encode(ff.user.uid + args['uid']));
  id = digest.toString();
} else {
  id = args['id'];
}

chat = ChatRoom(
  inject: ff,
  id: id,
  users: args['uid'] == null ? null : [args['uid']],
  render: () {
    setState(() {});
  },
);
```


- Once an instance of `ChatRoom` created, it begins to listen to any messages(event) that happen in the room and `render` function will be called. The app, then, re-render the screen with updated information.
  - `ChatRoom.message` has all the messages of the chat room including `who enters`, `who leaves`, `who blocked`, `who becomes moderator` and much more.

- `ChatRoom.info` has the chat room information.


- It is important to put `leave()` method on my chat room list and chat room to release the listeners.

For chat my room list leave,

```dart
@override
void dispose() {
  myRoomList.leave();
  super.dispose();
}
```

For chat room leave,

```dart
  @override
  void dispose() {
    chat.leave();
    super.dispose();
  }
```

- How to send a chat message

```dart

```


## Scenario of extending chat functionality

- If the app must inform new messages to the user when the user is not in room list screen,
  - The app can listen `my-room-list` collection on app screen (or homescreen)
  - And when a new message arrives, the app can show snackbar.
  - For this case, the app must unsubscribe when user is logs out and subscribe again when user is logs in.

## Unit tests of chat

There are two kinds of unit tests for chat. One is Firestore security rules test and the other is unit test.

- See [Unit Test](#unit-test).

# Location

Location is one of the necessary functionality on all apps. Do the [location setup](#location-setup) first.

Some of use case might be

- Users want to search other users near to them.
- You have an app of introducing your company and one to give navigation to users who want to visit your company.
  - Or simply, you want to show a map(navigator).
- The app wants to check locale(where the user is coming from) and do something based on it.
  - Maybe checking user's location, country. So that the app can suggest language, phone code for the user.

## Firestore structure of Location

- It will save location information on user's public document (`/meta/user/public/{uid}`).
  - Document property

```text
{
  location: {
    geohash: "8s8qquaz",          // string type
    geopoint: {                   // geopoint type
      Latitue: "38.334188",
      Longitude: "-122.314313"
    }
  }
}
```

## Code of Location

- To use location, create an instance of `FireFlutterLocation` class by injecting fireflutter in it.
  - When `FireFlutterLocation` has been instantiated, it will check the Location permission and listens the location, then update it on Firestore.

```dart
import 'package:fireflutter/fireflutter.dart';

final FireFlutter ff = FireFlutter();
final FireFlutterLocation location = FireFlutterLocation(inject: ff);
```

By instantiating an instance, it will check(and ask) the permission to the user. Then the app will begin to record the location on firestore.

- To display if the user has proper permission,

```dart
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool permission = false;
  bool service = false;
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    /// If the app resumed(from background), check the status again.
    if (state == AppLifecycleState.resumed) {
      permission = await location.hasPermission();
      service = await location.instance.serviceEnabled();
      setState(() {});
    }
  }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    () async {
      permission = await location.hasPermission();
      service = await location.instance.serviceEnabled();
      setState(() {});
    }();
  }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Text('Location Service: ' + (service ? 'ON' : 'OFF')),
        Text('Location Permission: ' + (permission ? 'ON' : 'OFF')),
      ]),
    );
  }
}
```

- When the device cannot fetch location information(GEO point), all the app can get from `FireFlutterLocation` is null event on `FireFlutterLocation.change` event and empty map data on `FireFlutterLocation.users` event.
  - This may happens when you run the app in Emulator for the first time.
  - To display that the device cannot fetch GEO point, use the following code.

```dart
if (location.lastPoint == null)
  Text(
      "Warning: the device cannot fetch location information(GEO location)!"),
```

### Initialization of Location

# Tests

## Unit Test

Since fireflutter is a bit complicated and depends on many other packages, we found out that the standard unit testing is not an ideal option. So, we wrote our own simple unit test code.

You can add the code below in Home screen. You need to fix the import path.

```dart
import 'file:///Users/thruthesky/apps/fireflutter_sample_app/packages/fireflutter/test/chat.test.dart';
FireFlutter ff = FireFlutter();
ff.init({});
ChatTest ct = ChatTest(ff);
ct.runChatTest();
```

After test, you need to remove the code.

## Integration Test

Please read [Testing Flutter apps](https://flutter.dev/docs/testing) for details about Flutter app testing.

We don't do unit testing on fireflutter since its backend is Firebase and there is no doubt about Firebase's performance and quality assurance.

And we don't do widget testing. Instead, we do integration test.

- See [sample app's intergration-test branch](https://github.com/thruthesky/fireflutter_sample_app) for the codes.

- We have tested it on Android app only since iOS app displays push notification consent box and it annoys the test.

- Youtube video on integration test

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/wg4yTldihh8/0.jpg)](https://www.youtube.com/watch?v=wg4yTldihh8)

# Developers Tips

## Extension method on fireflutter

- To write an extension method, see the example below.

```dart
import 'package:fireflutter/fireflutter.dart';
extension on FireFlutter {
  getUid() {
    return user.uid;
  }
}
print('uid: ' + ff.getUid());
```

# Extending your app with Fireflutter

You can do so much things with Fireflutter. We will introduce some scenario how fireflutter could extend your app's functionality.

## Social photo gallery

Imagine that you are going to build a social app. User can upload his photos and manage it on his profile page while those photos are public.
User can see other users' photos and take actions like voting(like and dislike), commeting, and even reporting for abusement.

- You can create a forum named `gallary` and put `add photo` button in user's profile screen.
- When user uploads a photo with firelfutter upload method, create a post under gallery forum with fireflutter method.
- You can, then, get(listen) user's photo with fireflutter post fetch method and display it to screen.
- When user wants edit or delete photo, do so with fireflutter.

This may cause lots of time and effort to accomplish without fireflutter.

## Keeping deleted post when user delete post

Sometimes you may want to keep the deleted post. Imagine that you are going to build a photo gallery and keeping history of uploaded photos are mandatory.

- When user deletes a post which has the photo,
- Don't delete the document. Instead delete the title and content, add a property `{deleted: FieldValue.serverTimestamp()}`
- And when the app lists the posts, hide deleted posts.

# Trouble Shotting

## Add GoogleService-Info.plist

Proceed the installation steps when you see error messages like below. It is complaining that you have not setup properly.

```text
FirebaseException ([core/not-initialized] Firebase has not been correctly initialized. Have you added the "GoogleService-Info.plist" file to the project?
```

## Stuck in registration

When `ff.register` is called, it sets data to Firestore and if Firestore is set created, then it would hang on `Firestore...doc('docId').set()`. To fix this, just enable Firestore with security rules and indexes as described in the setup section.

## MissingPluginException(No implementation found for method ...

If you meet errors like below,

- `MissingPluginException(No implementation found for method init on channel plugins.flutter.io/google_sign_in)`
- `MissingPluginException(No implementation found for method checkPermissionStatus on channel flutter.baseflow.com/permissions/methods)`

Mostly you have

- Misconfigured your packages
- To stop running debugging session and restart
  - Or delete some caches by doing
    - `$ flutter clean`
    - `$ flutter pub cache repair`
- Set up packages properly.

This error may happen when you try to login with `google_sign_in package` but you didn't setup `facebook sign in` package. Or when you try to take photos(on Android) without setting `facebook sign in` package.

`MissingPluginException` often happens when developer didn't set up properly when they add a package that depends on(or related in) others.

Try to do `By pass MissingPluginException error` and see if the error goes away.

### By pass MissingPluginException error

If really don't want to implement Facebook sign in or you want to skip Facebook sign in for the mean time while you are implementing Gogole sign in, then you may add the following settings. You can just put fake data on `strings.xml`.

Open main/AndroidManifest.xml and update below.

```xml
<application ... android:label="@string/app_name" ...>
```

Open /android/app/src/main/res/values/strings.xml ( or create if it is not existing)
And copy facebook_app_id and fb_login_protocol_scheme, past into the XML file like below.

```xml
<resources>
    <string name="app_name">Your app name</string>
    <string name="facebook_app_id">xxxxxxxxxxxxxxxxx</string>
    <string name="fb_login_protocol_scheme">xxxxxxxxxxxxxxxxx</string>
</resources>
```

Open android/app/src/main/AndroidManifest.xml
Add the following uses-permission element after the application element (outside application tag)

```xml
  <uses-permission android:name="android.permission.INTERNET"/>
```

And add the following meta-data element, an activity for Facebook, and an activity and intent filter for Chrome Custom Tabs inside your application element:

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<activity android:name="com.facebook.FacebookActivity" android:configChanges=
            "keyboard|keyboardHidden|screenLayout|screenSize|orientation" android:label="@string/app_name" />
<activity android:name="com.facebook.CustomTabActivity" android:exported="true">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="@string/fb_login_protocol_scheme" />
  </intent-filter>
</activity>
```

## com.apple.AuthenticationServices.AuthorizationError error 1001 or if the app hangs on Apple login

If you meet error message like this,

`SignInWithAppleAuthorizationError(AuthorizationErrorCode.canceled, The operation couldn’t be completed. (com.apple.AuthenticationServices.AuthorizationError error 1001.))`

Then, check if you have enabled Facebook login under Firebase => Sign-in method.

And then, try to login with real device.

## sign_in_failed

`PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 12500: , null, null)`

This error may happens when you didn't input SHA1 key on Android app in Firebase.

## operation-not-allowed

`PlatformException(operation-not-allowed, The identity provider configuration is not found., {code: operation-not-allowed, message: The identity provider configuration is not found., nativeErrorMessage: The identity provider configuration is not found., nativeErrorCode: 17006, additionalData: {}}, null)`

This error may happens when you didn't enable the sign-in method on Firebase Authentication. For instance, you have set Facebook sign in settings but forgot to enable Facebook sign in on Firebase Authentication.

## App crashes on second file upload

It's not a bug of Flutter and image_picker.

## Firestore rules and indexes

If you see error like below, check if you have properly set Firestore rules and indexes.

`[cloud_firestore/failed-precondition] Operation was rejected because the system is not in a state required for the operation's execution. If performing a query, ensure it has been indexed via the Firebase console.`

## After ff.editPost or ff.editComment, nothing happens?

Check Internet connectivity. And fireflutter works in offline. So, even though there is no Internet, posting would works. If you want to continue without Internet, you shuold `await`.

## SDK version not match

if you see error like `sdk version not match`, then, try to update flutter sdk 1.22.x

## flutter_image_compress error

When you meet error like below,

```text
Undefined symbols for architecture arm64:
  "_SDImageCoderEncodeCompressionQuality", referenced from:
      +[CompressHandler compressDataWithImage:quality:format:] in CompressHandler.o
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

open `~/bin/flutter/.pub-cache/hosted/pub.dartlang.org/flutter_image_compress-0.7.0/ios/Classes/CompressHandler.m` file and comment out some code as described in [its Git issue](https://github.com/OpenFlutter/flutter_image_compress/issues/160).

## Authentication setup error on iOS

If you didn't set the Authentication settings property, you may meed this error.

`Please register custom URL scheme 'com.googleusercontent.apps.229679080903-i8mfbm7ojqq87c169cvurajffg3hau70' in the app's Info.plist file`.

To solve this problem, please do the setup.

## Dex problem on Android

If you meet this error, you need to set up properly on Android.

`com.android.builder.dexing.DexArchiveMergerException: Error while merging dex archives: The number of method references in a .dex file cannot exceed 64K.`

To solve this problem, please refer [Android Setup](#android-setup) in this document.

## App is not authorized

If you meet this error, you haven't set up properly on Adnroid.

`This app is not authorized to use Firebase Authentication. Please verify that the correct package name and SHA-1 are configured in the Firebase Console. [ App validation failed ]`.

To solve this problem, please refer [Create a keystore](#create-a-keystore) and [Debug has key](#debug-hash-key) to setup SHA-1 hash key into Firebase.

## If app exists when picking photo

To solve this problem, please refer [Image Picker Setup for iOS](#image-picker-setup-for-ios).
