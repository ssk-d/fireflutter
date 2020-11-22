## [0.0.34] - Add user's public document data variable.

- `_voteChange()` has been removed.
- Adding `ff.publicData` to hold user's public document data.

## [0.0.33] - Phone authentication

Users can now sign in with their phone numbers. Or user can also link their phone authentication to existing account. It's now optional.

## [0.0.31] - Remove Cloud Functions

Cloud Functions has been removed from the project and security rules has been changed. Voting(like and dislike) works better now.

- Algolia search works without functions.
- Post voteing(like and dislike) works without functions.

## [0.0.30] - chat

- sort options for room list.
- remove newMessage properties on room info.

## [0.0.29] - chat functionality

- basic chat functionality has been added. It's already good enough to build a chat app.
- fix on typo.

## [0.0.27] - meta path update

- bug fix. meta path upate.

## [0.0.26] - firestore structure change

- breaking change. user public and token collection has been changed.

## [0.0.25] - updateUserPublic

- `updateUserPublic` method is added to update user public data.

## [0.0.24] - createdAt, updatedAt on user document

- When user registers, `createdAt` and `updatedAt` will be added to user document.
- Whenever user updates profile, `updatedAt` will be updated and `userChange` event fires.

- document update.
- algolia search settings.

## [0.0.22] - push notification setting change. user language setting.

- change. push notification settings has been changed.
- language settings has been simplified by adding `userLanguage` getter.

## [0.0.21] - cancellation on user data

- fix on listening on user data. It produced error on user logout due to improper way of canncellation the subscription.

## [0.0.20] - Phone auth

- fix bug on phone auth

## [0.0.19] - Push notification update

- fix on push notification

## [0.0.18] - userChange event on photoURL

- userChange event fires on photoURL change

## [0.0.16] - deprecation of data

- data variable is now deprecated. Use `userData` instead.

## [0.0.16] - commentEdit

- Breaking change. The parameters of commentEdit method has been changed.
- Minor fixes.

## [0.0.15] - non-blocking initialze

- Fireflutter now introduces a non-blocking initialization. It's not a breaking change.

## [0.0.14] - Minor fix

- Minor fix

## [0.0.14] - ForumStatus has been added

- Breaking change
  - noPostsYet, noMorePosts has been replaced with `ForumData.staus`.

## [0.0.12] - minor fixes

- Minor code fixes.

## [0.0.11] - default settings

- should work without any settings.
- document update.

## [0.0.10] - Updating documents and minor fixes

- Updating documents and minor fixes

## [0.0.9] - document.

- Updating documents
- Minor bug fixes.

## [0.0.8] - Refactoring, minor bug fixes, document update.

- Refactoring codes on push notification, removing unused packages.
- Bug fixes.
- Document updates.

## [0.0.7] - App settings, localizations.

- App settings and localizations are updated in real time.
- Document update.

## [0.0.6] - typo.

- fix typo warning

## [0.0.5] - voting.

- voting for posts and comments.
- minor bug fixes.

## [0.0.4] - Forum CRUD, Push Notifications, User CRUD, Social Login.

- User CRUD.
- Forum CRUD is in progress.
- Push notification is in progress.
- Social Login is in progress.

## [0.0.3] - User registration, login, update, logout.

- Registration and more works on User crud.

## [0.0.2] - Adding user functions.

- Registration

## [0.0.1] - initial release.

- initial release.
