# Fire Flutter

A free, open source, rapid development flutter package to build social apps, community apps, blogs apps, and much more.

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
- [TODOs](#todos)
- [Features](#features)
- [References](#references)
- [Components](#components)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Firebase Project Creation](#firebase-project-creation)
  - [Firebase Email/Password Login](#firebase-emailpassword-login)
  - [Create Firestore Database](#create-firestore-database)
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
  - [Firebase tools installation](#firebase-tools-installation)
  - [Download and Set FireFlutter Firebase Project](#download-and-set-fireflutter-firebase-project)
  - [Firestore security rules](#firestore-security-rules)
    - [Security Rules Testing](#security-rules-testing)
  - [Cloud Functions](#cloud-functions)
    - [Funtions Test](#funtions-test)
  - [Image Picker Setup](#image-picker-setup)
    - [Image Picker Setup for iOS](#image-picker-setup-for-ios)
  - [Localization Setup](#localization-setup)
  - [Push Notification Setup](#push-notification-setup)
  - [Algolia Setup](#algolia-setup)
  - [Admin Account Setting](#admin-account-setting)
- [App Management](#app-management)
  - [App Settings](#app-settings)
  - [Internalization (Localization)](#internalization-localization)
  - [Forum Management](#forum-management)
    - [Forum Category Management](#forum-category-management)
- [Developer Coding Guidelines](#developer-coding-guidelines)
  - [General Setup](#general-setup)
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
  - [Push Notification](#push-notification)
  - [Social Login](#social-login)
    - [Google Sign-in](#google-sign-in)
    - [Facebook Sign In](#facebook-sign-in)
    - [Apple Sign In](#apple-sign-in)
  - [External Logins](#external-logins)
    - [Kakao Login](#kakao-login)
- [I18N](#i18n)
- [Settings](#settings)
- [Trouble Shotting](#trouble-shotting)
  - [MissingPluginException google_sign_in](#missingpluginexception-google_sign_in)
  - [sign_in_failed](#sign_in_failed)
  - [operation-not-allowed](#operation-not-allowed)
  - [App crashes on second file upload](#app-crashes-on-second-file-upload)

<!-- /TOC -->

# TODOs

- Adding sample code for phone number verification
- Sample code for blocking users to create posts/comments if they didn't verify their phone numbers.
  - Do it on settings.
- Sample code for search posts and comments with Algolia
- Adding sample code for live change of user language.
- Integration test

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

# References

- [FireFlutter Package](https://pub.dev/packages/fireflutter) - This package.
- [FireFlutter Sample App](https://github.com/thruthesky/fireflutter_sample_app) - Sample flutter application.
- [FireFlutter Firebase Project](https://github.com/thruthesky/fireflutter-firebase) - Firebase project for Firestore security rules and Functions.

# Components

- Firebase.
  Firebase is a leading cloud system powered by Google. It has lots of goods to build web and app.

  - We first built it with Firebase and LEMP(Linux + Nginx + MySQL + PHP). we realized maintaing two different systems would be a pressure for many of developers. So, We decided to remove LEMP and we built it again.

  - You may use Firebase as free plan for a test. But for production, you need `Pay as you go` plan since `Cloud Function` works only on `Pay as you go` plan.
    - You may not use `Cloud Function` for testing.

- Algolia.
  Firebase does not support full text search which means users cannot search posts and comments.
  Algolia does it.

# Requirements

- Basic understanding of Firebase.
- Basic understanding of Flutter and Dart.
- OS: Windows or Mac.
- Editor: VSCode, Xcode(for Mac OS). Our primary editor si VSCode and we use Xcode for Flutter settings. We found it more easy to do the settings with Xcode for iOS development.

# Installation

- If you are not familiar with Firebase and Flutter, you may have difficulties to install it.

  - FireFlutter is not a smple package that you just add it into pubspec.yaml and ready to go.
  - Furthermore, the settings that are not directly from coming FireFlutter package like social login settings, Algolia setting, Android and iOS developer's accont settings are also hard to implement if you are not get used to them.
  - And for release, you will need to have extra settgins.
  - Most of developers are having troubles with settings. You are not the only one.

- We cover all the settings and will try to put it as demonstrative as it can be.

  - We will begin with Firebase settings and contiue gradually with Flutter.

- If you have any difficulties on installation, you may ask it on
  [Git issues](https://github.com/thruthesky/fireflutter/issues).

- And please let us know if there is any mistake on the installation.

- We also have a premium paid servie to support installation and development.

## Firebase Project Creation

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

## Firebase Email/Password Login

- Go to Authentication => Sign-in Method
- Click `Enable/Password` (without Email link).
- It is your choice weather you would let users to register by their email and password or not. But for installation test, just enable it.

- Refer [Firebase Authentication](https://firebase.google.com/docs/auth) and [FlutterFire Social Authenticatino](https://firebase.flutter.dev/docs/auth/social) for details.

## Create Firestore Database

- Go to `Cloud Firestore` menu.
- Click `Create Database`.
- Choose `Start in test mode`. We will change it to `production mode` later.
- Click `Next`.
- Choose nearest `Cloud Firestore location`.
- Click `Enable`.

## Create Flutter project

- Create a Flutter project like below;

```
$ flutter create fireflutter_sample_app
$ cd fireflutter_sample_app
$ flutter run
```

### Setup Flutter to connect to Firebase

#### iOS Setup

- Click `iOS` icon on `Project Overview` page to add `iOS` app to Firebase.
- Enter iOS Bundle ID. Ex) com.sonub.fireflutter
  - From now on, we assume that your iOS Bundle ID is `com.sonub.fireflutter`.
- click `Register app`.
- click `Download GoogleService-Info.plist`
  - And save it under `fireflutter_sample_app/ios/Runner` folder.
- click `Next`.
- click `Next` again.
- click `Next` again.
- click `Continue to console`.

- open `fireflutter_sample_app/ios/Runner.xcworkspace` with Xcode.
- click `Runner` on the top of left pane.
- click `Runner` on TARGETS.
- edit `Bundle Identifier` to `com.sonub.fireflutter`.
- set `iOS 11.0` under Deployment Info.
- Darg `fireflutter_sample_app/ios/Runner/GoogleService-Info.plist` file under `Runner/Runner` on left pane of Xcode.
- Close Xcode.

- You may want to test if the settings are alright.
  - Open VSCode and do [FireFlutter Initialization](#fireflutter-initialization) do some registration code. see [User Registration](#user-email-and-password-registration) for more details.

#### Android Setup

- Click `Android` icon on `Project Overview` page to add `Android` app to Firebase.
  - If you don't see `Android` icon, look for `+ Add app` button and click, then you would see `Android` icon.
- Enter `iOS Bundle ID` into `Android package name`. `iOS Bundle ID` and `Android package name` should be kept in idendentical name for easy to maintain. In our case, it is `com.sonub.fireflutter`.
- Click `Register app` button.
- Click `Download google-services.json` file to downlaod
- And save it under `fireflutter_sample_app/android/app` folder.
- Click `Next`
- Click `Next`
- Click `Continue to console`.
- Open VSCode with `fireflutter_sample_app` project.
- Open `fireflutter_sample_app/android/app/build.gradle` file.
- Update `minSdkVersion 16` to `minSdkVersion 21`.
- Add below to the end of `fireflutter_sample_app/android/app/build.gradle`. This is for Flutter to read `google-services.json`.

```gradle
apply plugin: 'com.google.gms.google-services'
```

- Open `fireflutter_sample_app/android/build.gradle`. Do not confuse with the other build.gradle.
- Add the dependency below in the buildscript tag.

```gradle
dependencies {
  // ...
  classpath 'com.google.gms:google-services:4.3.3' // Add this line.
}
```

- Open the 5 files and update the package name to `com.sonub.fireflutter`.

  - android/app/src/main/AndroidManifest.xml
  - android/app/src/debug/AndroidManifest.xml
  - android/app/src/profile/AndroidManifest.xml
  - android/app/build.gradle
  - android/app/src/main/kotlin/….MainActivity.kt

- That's it.
- You may want to test if the settings are alright.
  - Open VSCode and do [FireFlutter Initialization](#fireflutter-initialization) do some registration code. see [User Registration](#user-email-and-password-registration) for more details.

## Create a keystore

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
- [Facebook Sign In Setup for Android](#facebook-sign-in-setup-for-android) is required to sign in with Google (in our case).

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

## Firebase tools installation

- Install Firebase tools with the following command. You may need root permission.

```sh
npm install -g firebase-tools
```

- Then, login to Firebase with the follow command.

```sh
firebase login
```

- Refer [Set up or update the CLI](https://firebase.google.com/docs/cli#mac-linux-npm) for details.

## Download and Set FireFlutter Firebase Project

- Install firebase tools as described at [Firebase tools installation](#firebase-tools-installation)

- Git clone(or fork) https://github.com/thruthesky/fireflutter-firebase
  - And enter the project folder
  - `$ cd fireflutter-firebase`
- Install node modules with the following command.
  - `$ npm i`.
- Update Firebase project ID in `.firebaserc ==> projects ==> default`.
- Set `Firebase SDK Admin Service Key`
  - Go to Project settings => Service accounts => Firebae Admin SDK
  - Click `Node.js`
  - Click `Generate new priate key`
  - Click `Generate Key`
  - Then, a file will be downloaded.
  - Rename the file to `firebase-service-account-key.json`
  - And move(or overwrite if it exists) it to the project folder(the same folder where `.firebaserc` is).

## Firestore security rules

Firestore needs security rules to secure its data or it might loose all data by hackers.

- Do [Download and Set FireFlutter Firebase Project](#download-and-set-fireflutter-firebase-project)
- Run `firebase deploy --only firestore`.

### Security Rules Testing

- If you wish to test Firestore security rules, you may do so with the following;

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
```

## Cloud Functions

We tried to limit the usage of Cloud Functions as minimum as possible. But there are some functionalities we cannot achive without it.

One of the reason why we use Cloud Funtions is to enable like and dislike functionality. It is a simple functionality but when it comes with Firestore security rule, it's not an easy work. And Cloud Functions does better with it.

- Do [Download and Set FireFlutter Firebase Project](#download-and-set-fireflutter-firebase-project)
- Install node modules under functions folder.
  - `$ cd functions`
  - `$ npm i`
  - `$ cd ..`
- Run `firebase deploy --only functions`. You will need Firebase `Pay as you go` plan to deploy it.
  - If you meet `Error: HTTP Error: 403, Unknown Error` erro, then you may try again.

### Funtions Test

- If you whish to test Functions, you may do so with the following;

```
$ cd functions
$ npm test
$ npm test:algolia
```

## Image Picker Setup

To upload files(or photos), we will use [image_picker](https://pub.dev/packages/image_picker) package.

Android platform(API 29+) does not need any settings. It works out of the box.

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

## Localization Setup

If an app serves only for one nation with one language, the app may not need localization. But if the app serves for many nations with many languages, then the app should have localization. The app should display Chinese language for Chinese people, Korean langauge for Korean people, Japanese for Japanese people and so on.

You can set different texts of different languages on menu, buttons, screens.

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
  - In the code below, we add only English and Korean. You may add more languages and its translations.

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
  - Add the following into GetMaterialApp
  - The `locale: Locale('ko')` is the default language to display texts in.

```dart
locale: Locale('ko'),
translations: AppTranslations(),
```

- Open home.screen.dart
  - Update app bar title with the following and you will see translated text in Korean.

```dart
Scaffold(
  appBar: AppBar(
    title: Text('app-name'.tr),
  ),
```

- If you want to set device language as the display langauge, you can do so like below.
  - If `ui.window.locale` is not available, it will fall back to Korean.

```dart
import 'dart:ui' as ui;
// ...
@override
Widget build(BuildContext context) {
  return GetMaterialApp(
    locale: ui.window.locale ?? Locale('ko'),
    fallbackLocale: Locale('ko'),
```

- User may want to choose what language they want to use.
  - Display selection box and when a user choose his langauge, then update the language like below.

```dart
Get.updateLocale(Locale('ko'));
```

- Updating translations in real time.
  - You can code like below in `initState()` of `MainApp`.
  - It listens for the changes in Firestore translations collection and update the screen with the translations.

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
  click the  notification on the system tray you need to include the following `intent-filter`
  under the `<activity>` tag of your `android/app/src/main/AndroidManifest.xml`.

```xml
<activity>
  ---- default configuration here -----
  <intent-filter>
      <action android:name="FLUTTER_NOTIFICATION_CLICK" />
      <category android:name="android.intent.category.DEFAULT" />
  </intent-filter>
</activity>
```

- For testing on real device you need to add the `SHA certificate fingerprints` on your firebase console project.
  - To get the SHA-1 you can refer to [Debug hash key](#debug-hash-key).
  - Open [Firebase Console](https://console.firebase.google.com)
  - Project `Settings` => `General` =>  `Your Apps`, Select `Android apps` then under `SHA certificate fingerprints`
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

Firestore does not support full text search, which means users cannot search the title or content of posts and comments. And this is a must functionality for community and blog apps.

One option(recomended by Firebase team) to solve this matter is to use Algolia. Algolia has free service and that's what we are going to use it.

Before setup Algolia, you may try forum code as described in [Forum Coding](#forum-coding) to test if this settings work.

- Go to Algolia site.
- Register.
- Create app.
- First, you need to put ALGOLIA_ID(Application ID), ALGOLIA_ADMIN_KEY, ALGOLIA_INDEX_NAME in `firebase-settings.js`.
  - deploy with `firebase deploy --only functions`.
  - For testing, do `npm run test:algolia`.
- Second, you need to add(or update) ALGOLIA_APP_ID(Application ID), ALGOLIA_SEARCH_KEY(Search Only Api Key), ALGOLIA_INDEX_NAME in Firestore `settings/app` document.
  Optionally, you can put the settings inside `FireFlutter.init()`.
- Algolia free account give you 10,000 free search every months. This is good enough for small sized projects.

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

- You can create forum categories in admin screen.

# Developer Coding Guidelines

## General Setup

- Add latest version of [FireFlutter](https://pub.dev/packages/fireflutter) in pubspec.yaml
- Add latest version of [GetX](https://pub.dev/packages/get).
  - We have chosen `GetX` package for routing, state management, localization and other functionalities.
    - GetX is really simple. We recommed you to use it.
    - All the code explained here is with GetX.
    - You may choose different packages and that's very fine.

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

- You might get error when you try to use Firebase since it might not have finished its initialization, yet. You can write the code like below in such case,

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

- You may have a customised Wiget to wait to until Firebase is ready. FirebaseReady will wait until Firebase firebase is initialized and then it will display the child widget.

```dart
FirebaseReady(child: Text('firebase is ready')),
///
class FirebaseReady extends StatelessWidget {
  const FirebaseReady({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ff.firebaseInitialized,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data == false)
          return Container();
        else
          return child;
      },
    );
  }
}
```

- The variable `ff` is an instace of `FireFlutter` and should be shared across all the screens.

- Create a `global_variables.dart` on the same folder of main.dart.

  - And move the `ff` variable into `global_variables.dart`.

- The complete code is on [fireflutter-initialization branch](https://github.com/thruthesky/fireflutter_sample_app/tree/fireflutter/lib) of sample app.

### Add GetX

- To add GetX to Flutter app,
  - open main.dart
  - split `Home Screen` into `lib/screens/home/home.screen.dart`.
  - and replace `MaterialApp` with `GetMaterialApp`.
  - add `initialRotue: 'home'`
  - add HomeScreen to route.
  - To see the complete code, visit [getx branch of sample app](https://github.com/thruthesky/fireflutter_sample_app/tree/getx).

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
- Do [Cloud Functions](#cloud-functions). When the app is displaying posts, the Clould Funtions soubld be ready.
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

## Push Notification

- FireFlutter comes with `Push Notification functionality`. It is disable by default.
- To enable push notification you must set `enableNotification: true` on main in `FireFlutter init()`.
- Once enabled it will ask the user if they want to receive push notification in iOS.
- For android it was done automatically.
- By default it subscribe to `allTopic`. So you can use this topic to send to all users.
- It also subscribe to `notification_post` when new comment is created under the user post it will receive notification.
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
  - Providing `topic` as string will send notification to that topic.
  - Providing `token` as string will send to specific Device.
  - Providing `tokens` as list of string will send to list of Device provided.

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

# I18N

- The app's i18n is managed by `GetX` i18n feature.

- If you want to add another language,

  - Add the language code in `Info.plist`
  - Add the language on `translations`
  - Add the lanugage on `FireFlutter.init()`
  - Add the language on `FireFlutter.settingsChange`
  - Add the language on Firebase `settings` collection.

- Default i18n translations(texts) can be set through `FireFlutter` initializatin and is overwritten by the `translations` collection of Firebase.
  The Firestore is working offline mode, so overwriting with Firestore translation would happen so quickly.

- You may optionally omit `translations` in `FireFlutter.init()` if you are going to set `translations` in `GetMaterialApp` since the same initial translated texts will be merged into.

# Settings

- Default settings can be set through `FireFlutter` initialization and is overwritten by `settings` collection of Firebase.
  The Firestore is working offline mode, so overwriting with Firestore translation would happen so quickly.

- If `show-phone-verification-after-login` is set to true, then users who do not have their phone numbers will be redirected to phone verification page.
  - Developers can customize it by putting 'skip' button.
- If `create-phone-verified-user-only` is set to true, only the user who verified thier phone numbers can create posts and comments.

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

# Trouble Shotting

## MissingPluginException google_sign_in

`MissingPluginException(No implementation found for method init on channel plugins.flutter.io/google_sign_in)`

This error happens (at least in our case) when Flutter has google_sign_in package and facebook sign in package. If facebook sign in is depending on google_sign_in package, setting for facebok sign in is mandatory to use google_sign_in. In short, do the settings for both google sign in and facebook sign in.

## sign_in_failed

`PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 12500: , null, null)`

This error may happens when you didn't input SHA1 key on Android app in Firebase.

## operation-not-allowed

`PlatformException(operation-not-allowed, The identity provider configuration is not found., {code: operation-not-allowed, message: The identity provider configuration is not found., nativeErrorMessage: The identity provider configuration is not found., nativeErrorCode: 17006, additionalData: {}}, null)`

This error may happens when you didn't enable the sign-in method on Firebase Authentication. For instance, you have set Facebook sign in settings but forgot to enable Facebook sign in on Firebase Authentication.

## App crashes on second file upload

It's know to be a bug of Flutter and image_picker.
