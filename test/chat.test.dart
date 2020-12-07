// import 'package:fireflutter/functions.dart';
// import 'package:fireflutter/fireflutter.dart';
// import 'package:flutter/material.dart';

// const String password = '12345a,*,';
// const String aEmail = 'AAA@gmail.com';
// const String bEmail = 'BBB@gmail.com';
// const String cEmail = 'CCC@gmail.com';
// const String dEmail = 'DDD@gmail.com';

// /// Chat Test
// ///
// /// ! Warning. When you test, don't open chat screen since the test uses serveral di_fferent accounts often
// /// ! and that causes permission-error on my room listening.
// class ChatTest {
//   ChatTest({@required FireFlutter inject}) : this._ff = inject;

//   FireFlutter _ff;
//   Map<String, Map<String, String>> users = {
//     'a': {'uid': 'iiVOFXhlVcPBvhC7BtBsyF1AfH52', 'displayName': 'UserA'},
//     'b': {'uid': 'vm7F4mdex9TrY1wmVrPgYWANkYH2', 'displayName': 'UserB'},
//     'c': {'uid': 'f5xZJYNjL6UuLpjRn7g9OJCoGqH3', 'displayName': 'UserC'},
//     'd': {'uid': 'GYfxU2FQzgMobRBxt9er99i1fah1', 'displayName': 'UserD'},
//     'iiVOFXhlVcPBvhC7BtBsyF1AfH52': {'email': aEmail},
//     'vm7F4mdex9TrY1wmVrPgYWANkYH2': {'email': bEmail},
//     'f5xZJYNjL6UuLpjRn7g9OJCoGqH3': {'email': cEmail},
//     'GYfxU2FQzgMobRBxt9er99i1fah1': {'email': dEmail},
//   };

//   Map<String, String> userA = {
//     'email': aEmail,
//     'password': password,
//     'displayName': 'UserA'
//   };
//   Map<String, String> userB = {
//     'email': bEmail,
//     'password': password,
//     'displayName': 'UserB'
//   };
//   Map<String, String> userC = {
//     'email': cEmail,
//     'password': password,
//     'displayName': 'UserC'
//   };
//   Map<String, String> userD = {
//     'email': dEmail,
//     'password': password,
//     'displayName': 'UserD'
//   };

//   /// login or register user A, B, C, D.
//   ///
//   /// Once it has logged in, it prints the UID and DisplayName of the users.
//   /// You need to save the user UID and DisplayName into [users] variable.
//   prepareUserABCD() async {
//     if (users != null) return;
//     print(userA);
//     dynamic a = await _ff.loginOrRegister(
//         email: userA['email'], password: userA['password']);
//     dynamic b = await _ff.loginOrRegister(
//         email: userB['email'], password: userB['password']);
//     dynamic c = await _ff.loginOrRegister(
//         email: userC['email'], password: userC['password']);
//     dynamic d = await _ff.loginOrRegister(
//         email: userD['email'], password: userD['password']);
//     print("{'uid': '${a.uid}', 'displayName': 'a.displayName'}");
//     print("{'uid': '${b.uid}', 'displayName': 'b.displayName'}");
//     print("{'uid': '${c.uid}', 'displayName': 'c.displayName'}");
//     print("{'uid': '${d.uid}', 'displayName': 'd.displayName'}");
//   }

//   success(String message) {
//     print("[SUCCESS] $message");
//   }

//   failture(String message) {
//     print("------------------> [FAILURE] $message");
//   }

//   isTrue(bool re, [String message]) {
//     if (re)
//       success(message);
//     else
//       failture(message);
//   }

//   runChatTest() {
//     _ff.firebaseInitialized.listen((value) async {
//       if (!value) return;

//       prepareUserABCD();

//       await _ff.loginOrRegister(
//           email: userA['email'], password: userA['password']);

//       print('${users['a']['displayName']} -> ${users['a']['uid']}');
//       print('${users['b']['displayName']} -> ${users['b']['uid']}');
//       print('${users['c']['displayName']} -> ${users['c']['uid']}');
//       print('${users['d']['displayName']} -> ${users['d']['uid']}');

//       /// Chat room creation test
//       // Map<String, dynamic> roomInfo = await _ff.chatCreateRoom();

//       /// Create chat instance
//       ChatRoom chat = ChatRoom(inject: _ff);

//       /// Create chat room without users but myself.
//       ChatRoomInfo roomInfo = await chat.create();

//       ChatRoomInfo info = await chat.getRoomInfo(roomInfo.id);
//       isTrue(info.moderators.length == 1, 'moderators length must be 1');
//       isTrue(info.moderators[0] == users['a']['uid'],
//           'user A must be the moderator - ${users['a']['uid']}');

//       /// Create chat room with a user and myself.
//       roomInfo = await chat.create(users: [users['b']['uid']]);

//       /// Get room info
//       info = await chat.getRoomInfo(roomInfo.id);

//       isTrue(info.users.length == 2, 'users.length should be 2');
//       isTrue(info.users.indexOf(users['a']['uid']) > -1,
//           'user A - ${users['a']['uid']} must be in users array');
//       isTrue(info.users.indexOf(users['b']['uid']) > -1,
//           'user B - ${users['b']['uid']} must be in users array');

//       roomInfo =
//           await chat.create(users: [users['b']['uid'], users['c']['uid']]);

//       info = await chat.getRoomInfo(roomInfo.id);
//       isTrue(info.users.length == 3, 'users.length should be 3');

//       roomInfo = await chat.create(users: [
//         users['b']['uid'],
//         users['b']['uid'],
//         users['b']['uid'],
//         users['c']['uid'],
//         users['c']['uid'],
//         users['c']['uid'],
//         users['d']['uid']
//       ]);

//       info = await chat.getRoomInfo(roomInfo.id);
//       isTrue(info.users.length == 4, 'users.length should be 4');
//       isTrue(info.users.indexOf(users['a']['uid']) > -1,
//           'user A - ${users['a']['uid']} must be in users array');
//       isTrue(info.users.indexOf(users['b']['uid']) > -1,
//           'user B - ${users['b']['uid']} must be in users array');
//       isTrue(info.users.indexOf(users['c']['uid']) > -1,
//           'user C - ${users['c']['uid']} must be in users array');
//       isTrue(info.users.indexOf(users['d']['uid']) > -1,
//           'user D - ${users['d']['uid']} must be in users array');

//       /// User add new users and test.
//       ///
//       roomInfo = await chat.create(users: [users['b']['uid']]);
//       info = await chat.getRoomInfo(roomInfo.id);
//       isTrue(info.users.length == 2,
//           'Add user: users.length==2. roomId: ${roomInfo.id}');
//       // add user C
//       await chat
//           .addUser(roomInfo.id, {users['c']['uid']: users['c']['displayName']});
//       //

//       info = await chat.getRoomInfo(roomInfo.id);
//       List _users = info.users;
//       isTrue(
//           _users.toSet().containsAll([
//             users['c']['uid'],
//             users['b']['uid'],
//             users['a']['uid'],
//           ]),
//           'A, B, C are included.');
//       isTrue(
//           !_users.toSet().containsAll([
//             users['d']['uid'],
//           ]),
//           'D are not included.');

//       Map<String, dynamic> data = await _ff.chatLastMessage(info.id);

//       isTrue(data['newUsers'].length == 1, 'newUsers.legnth == 1');
//       isTrue(data['newUsers'][0] == users['c']['displayName'],
//           'newUsers: [UserC]');
//       // print('data: ');
//       // print(data);

//       /// Add user C, D
//       await chat.addUser(roomInfo.id, {
//         users['c']['uid']: users['c']['displayName'],
//         users['d']['uid']: users['d']['displayName'],
//       });

//       data = await _ff.chatLastMessage(info.id);

//       isTrue(data['newUsers'].length == 2, 'newUsers.legnth == 2');
//       isTrue(data['newUsers'][1] == users['d']['displayName'],
//           'newUsers: [UserD]');
//       // print('data: ');
//       // print(data);

//       /// Send chat message
//       ///
//       String text = "Yo! " + getRandomString();

//       await chat.sendMessage(text: text);

//       for (String uid in chat.info.users) {
//         print(
//             'get: uid:$uid, ${chat.userRoomDoc(uid, info.id).path}, email: ${users[uid]['email']}');

//         await _ff.login(email: users[uid]['email'], password: password);

//         /// TODO error here. room is null.
//         Map<String, dynamic> room = await chat.getMyRoom(uid, chat.info.id);
//         // (await chat.userRoomDoc(uid, chat.info.id).get()).data();
//         print(room);
//         isTrue(room['text'] == text, 'Chat text comparison: $text');
//       }

//       /// User leave
//       /// Login to B and leave the room
//       await _ff.login(email: userB['email'], password: userB['password']);

//       await _ff.chatRoomLeave(info.id);

//       /// Login to C to read room info
//       await _ff.login(email: userC['email'], password: userC['password']);

//       /// test
//       info = await chat.getRoomInfo(info.id);
//       isTrue(info.users.length == 3, 'users.length == 3 after removing 1');
//       isTrue((info.users).contains(users['a']['uid']), 'A is in users list');
//       isTrue(
//           !(info.users).contains(users['b']['uid']), 'B is NOT in users list');
//       isTrue((info.users).contains(users['c']['uid']), 'C is in users list');
//       isTrue((info.users).contains(users['d']['uid']), 'D is in users list');

//       /// C removes D. Expect error since C is a user and user cannot remove another user.
//       try {
//         await chat.blockUser(
//             info.id, users['d']['uid'], users['d']['displayName']);
//         isTrue(false, 'Error. User cannot block other user.');
//       } catch (e) {
//         isTrue(true, 'Permission error: User cannot block other user.');
//       }

//       /// Login to A(moderator) to block user D.
//       await _ff.login(email: userA['email'], password: userA['password']);
//       await chat.blockUser(
//           info.id, users['d']['uid'], users['d']['displayName']);

//       info = await chat.getRoomInfo(info.id);
//       isTrue(info.users.length == 2, 'users.length == 2 after blocking user D');

//       isTrue((info.users).contains(users['a']['uid']), 'A is in users list');
//       isTrue((info.users).contains(users['c']['uid']), 'C is in users list');

//       /// C tries to add himself as moderator.
//       await _ff.login(email: userC['email'], password: userC['password']);
//       try {
//         await chat.addModerator(users['c']['uid']);
//         isTrue(false, 'A user cannot add another user to moderators');
//       } catch (e) {
//         isTrue(true, 'User C cannot add a user(or himself) to moderators.');
//       }

//       /// A adds C to moderator
//       ///
//       ///
//       await _ff.login(email: userA['email'], password: userA['password']);

//       await chat.addModerator(users['c']['uid']);
//       info = await chat.getRoomInfo(chat.info.id);
//       print('info.moderators:');
//       print(info.moderators);
//       isTrue(info.moderators.length == 2, 'moderators.length == 2');

//       isTrue((info.moderators).contains(users['a']['uid']),
//           'A is in moderator list');
//       isTrue((info.moderators).contains(users['c']['uid']),
//           'C is in moderator list');

//       /// Remove C from moderator
//       await chat.removeModerator(users['c']['uid']);
//       info = await chat.getRoomInfo(info.id);
//       isTrue(info.moderators.length == 1, 'moderators.length == 2');

//       isTrue((info.moderators).contains(users['a']['uid']),
//           'A is in moderator list');

//       /// Change title
//       await _ff.chatUpdateRoom(info.id, title: 'new title');
//       info = await chat.getRoomInfo(info.id);
//       // print('info: ');
//       // print(info);
//       isTrue(info.title == 'new title', 'title updated');
//     });
//   }
// }
