import 'package:fireflutter/functions.dart';
import 'package:fireflutter/fireflutter.dart';

/// Chat Test
///
/// ! Warning. When you test, don't open chat screen since the test uses serveral different accounts often
/// ! and that causes permission-error on my room listening.
class ChatTest {
  ChatTest(FireFlutter ff) : this.ff = ff;

  FireFlutter ff;
  Map<String, Map<String, String>> users = {
    'a': {'uid': 'xbTphnD5QBejlDuBgDK2hXmUxp62', 'displayName': 'UserA'},
    'b': {'uid': 'g3bJ3C3BiZYe9AhLPbtjJASB9622', 'displayName': 'UserB'},
    'c': {'uid': 'QlymWR6GSYOWzHKq92S4ErNSMzH3', 'displayName': 'UserC'},
    'd': {'uid': '9tRhNodWtpRuDI9isvi4DCbc7xC2', 'displayName': 'UserD'},
    'xbTphnD5QBejlDuBgDK2hXmUxp62': {'email': 'aaaa@gmail.com'},
    'g3bJ3C3BiZYe9AhLPbtjJASB9622': {'email': 'bbbb@gmail.com'},
    'QlymWR6GSYOWzHKq92S4ErNSMzH3': {'email': 'cccc@gmail.com'},
    '9tRhNodWtpRuDI9isvi4DCbc7xC2': {'email': 'dddd@gmail.com'},
  };

  Map<String, String> userA = {
    'email': 'aaaa@gmail.com',
    'password': '12345a,*',
    'displayName': 'UserA'
  };
  Map<String, String> userB = {
    'email': 'bbbb@gmail.com',
    'password': '12345a,*',
    'displayName': 'UserB'
  };
  Map<String, String> userC = {
    'email': 'cccc@gmail.com',
    'password': '12345a,*',
    'displayName': 'UserC'
  };
  Map<String, String> userD = {
    'email': 'dddd@gmail.com',
    'password': '12345a,*',
    'displayName': 'UserD'
  };

  /// login or register user A, B, C, D.
  ///
  /// Once it has logged in, it prints the UID and DisplayName of the users.
  /// You need to save the user UID and DisplayName into [users] variable.
  prepareUserABCD() async {
    if (users != null) return;
    dynamic a = await ff.loginOrRegister(
        email: userA['emain'], password: userA['password']);
    dynamic b = await ff.loginOrRegister(
        email: userB['emain'], password: userB['password']);
    dynamic c = await ff.loginOrRegister(
        email: userC['emain'], password: userC['password']);
    dynamic d = await ff.loginOrRegister(
        email: userD['emain'], password: userD['password']);
    print("{'uid': '${a.uid}', 'displayName': 'a.displayName'}");
    print("{'uid': '${b.uid}', 'displayName': 'b.displayName'}");
    print("{'uid': '${c.uid}', 'displayName': 'c.displayName'}");
    print("{'uid': '${d.uid}', 'displayName': 'd.displayName'}");
  }

  success(String message) {
    print("[SUCCESS] $message");
  }

  failture(String message) {
    print("------------------> [FAILURE] $message");
  }

  isTrue(bool re, [String message]) {
    if (re)
      success(message);
    else
      failture(message);
  }

  runChatTest() {
    ff.firebaseInitialized.listen((value) async {
      if (!value) return;

      prepareUserABCD();

      await ff.login(email: userA['email'], password: userA['password']);

      print('${users['a']['displayName']} -> ${users['a']['uid']}');
      print('${users['b']['displayName']} -> ${users['b']['uid']}');
      print('${users['c']['displayName']} -> ${users['c']['uid']}');
      print('${users['d']['displayName']} -> ${users['d']['uid']}');

      /// Chat room creation test
      Map<String, dynamic> roomInfo = await ff.chatCreateRoom();
      Map<String, dynamic> info = await ff.chatGetRoomInfo(roomInfo['id']);
      isTrue(info['moderators'].length == 1, 'moderators length must be 1');
      isTrue(info['moderators'][0] == users['a']['uid'],
          'user A must be the moderator - ${users['a']['uid']}');

      roomInfo = await ff.chatCreateRoom(users: [users['b']['uid']]);
      info = await ff.chatGetRoomInfo(roomInfo['id']);

      isTrue(info['users'].length == 2, 'users.length should be 2');
      isTrue(info['users'].indexOf(users['a']['uid']) > -1,
          'user A - ${users['a']['uid']} must be in users array');
      isTrue(info['users'].indexOf(users['b']['uid']) > -1,
          'user B - ${users['b']['uid']} must be in users array');

      roomInfo = await ff
          .chatCreateRoom(users: [users['b']['uid'], users['c']['uid']]);

      info = await ff.chatGetRoomInfo(roomInfo['id']);
      isTrue(info['users'].length == 3, 'users.length should be 3');

      roomInfo = await ff.chatCreateRoom(users: [
        users['b']['uid'],
        users['b']['uid'],
        users['b']['uid'],
        users['c']['uid'],
        users['c']['uid'],
        users['c']['uid'],
        users['d']['uid']
      ]);

      info = await ff.chatGetRoomInfo(roomInfo['id']);
      isTrue(info['users'].length == 4, 'users.length should be 4');
      isTrue(info['users'].indexOf(users['a']['uid']) > -1,
          'user A - ${users['a']['uid']} must be in users array');
      isTrue(info['users'].indexOf(users['b']['uid']) > -1,
          'user B - ${users['b']['uid']} must be in users array');
      isTrue(info['users'].indexOf(users['c']['uid']) > -1,
          'user C - ${users['c']['uid']} must be in users array');
      isTrue(info['users'].indexOf(users['d']['uid']) > -1,
          'user D - ${users['d']['uid']} must be in users array');

      /// User add new users and test.
      ///
      roomInfo = await ff.chatCreateRoom(users: [users['b']['uid']]);
      info = await ff.chatGetRoomInfo(roomInfo['id']);
      isTrue(info['users'].length == 2,
          'Add user: users.length==2. roomId: ${roomInfo['id']}');
      // add user C
      await ff.chatAddUser(
          roomInfo['id'], {users['c']['uid']: users['c']['displayName']});
      //

      info = await ff.chatGetRoomInfo(roomInfo['id']);
      List _users = info['users'];
      isTrue(
          _users.toSet().containsAll([
            users['c']['uid'],
            users['b']['uid'],
            users['a']['uid'],
          ]),
          'A, B, C are included.');
      isTrue(
          !_users.toSet().containsAll([
            users['d']['uid'],
          ]),
          'D are not included.');

      Map<String, dynamic> data = await ff.chatLastMessage(info['id']);

      isTrue(data['newUsers'].length == 1, 'newUsers.legnth == 1');
      isTrue(data['newUsers'][0] == users['c']['displayName'],
          'newUsers: [UserC]');
      // print('data: ');
      // print(data);

      /// Add user C, D
      await ff.chatAddUser(roomInfo['id'], {
        users['c']['uid']: users['c']['displayName'],
        users['d']['uid']: users['d']['displayName'],
      });

      data = await ff.chatLastMessage(info['id']);

      isTrue(data['newUsers'].length == 2, 'newUsers.legnth == 2');
      isTrue(data['newUsers'][1] == users['d']['displayName'],
          'newUsers: [UserD]');
      // print('data: ');
      // print(data);

      /// Send chat message
      ///
      String text = "Yo! " + getRandomString();
      await ff.chatSendMessage(info: info, text: text);

      for (String uid in info['users']) {
        // print('get: uid:$uid, ${ff.chatUserRoomDoc(uid, info['id']).path}');
        await ff.login(email: users[uid]['email'], password: '12345a,*');

        Map<String, dynamic> room =
            (await ff.chatUserRoomDoc(uid, info['id']).get()).data();

        isTrue(room['text'] == text, 'Chat text comparison: $text');
      }

      /// User leave
      /// Login to B and leave the room
      await ff.login(email: userB['email'], password: userB['password']);

      await ff.chatRoomLeave(info['id']);

      /// Login to C to read room info
      await ff.login(email: userC['email'], password: userC['password']);

      /// test
      info = await ff.chatGetRoomInfo(info['id']);
      isTrue(info['users'].length == 3, 'users.length == 3 after removing 1');
      isTrue((info['users'] as List).contains(users['a']['uid']),
          'A is in users list');
      isTrue(!(info['users'] as List).contains(users['b']['uid']),
          'B is NOT in users list');
      isTrue((info['users'] as List).contains(users['c']['uid']),
          'C is in users list');
      isTrue((info['users'] as List).contains(users['d']['uid']),
          'D is in users list');

      /// C removes D. Expect error since C is a user and user cannot remove another user.
      try {
        await ff.chatBlockUser(
            info['id'], users['d']['uid'], users['d']['displayName']);
        isTrue(false, 'Error. User cannot block other user.');
      } catch (e) {
        isTrue(true, 'User cannot block other user.');
      }

      /// Login to A(moderator) to block user D.
      await ff.login(email: userA['email'], password: userA['password']);
      await ff.chatBlockUser(
          info['id'], users['d']['uid'], users['d']['displayName']);

      info = await ff.chatGetRoomInfo(info['id']);
      isTrue(
          info['users'].length == 2, 'users.length == 2 after blocking user D');

      isTrue((info['users'] as List).contains(users['a']['uid']),
          'A is in users list');
      isTrue((info['users'] as List).contains(users['c']['uid']),
          'C is in users list');

      /// C tries to add himself as moderator.
      await ff.login(email: userC['email'], password: userC['password']);
      try {
        await ff.chatAddModerator(info['id'], users['c']['uid']);
        isTrue(false, 'A user cannot add another user to moderators');
      } catch (e) {
        isTrue(true, 'User C cannot add a user(or himself) to moderators.');
      }

      /// A adds C to moderator
      ///
      ///
      await ff.login(email: userA['email'], password: userA['password']);
      await ff.chatAddModerator(info['id'], users['c']['uid']);
      info = await ff.chatGetRoomInfo(info['id']);
      isTrue(info['moderators'].length == 2, 'moderators.length == 2');

      isTrue((info['moderators'] as List).contains(users['a']['uid']),
          'A is in moderator list');
      isTrue((info['moderators'] as List).contains(users['c']['uid']),
          'C is in moderator list');

      /// Remove C from moderator
      await ff.chatRemoveModerator(info['id'], users['c']['uid']);
      info = await ff.chatGetRoomInfo(info['id']);
      isTrue(info['moderators'].length == 1, 'moderators.length == 2');

      isTrue((info['moderators'] as List).contains(users['a']['uid']),
          'A is in moderator list');

      /// Change title
      await ff.chatUpdateRoom(info['id'], title: 'new title');
      info = await ff.chatGetRoomInfo(info['id']);
      // print('info: ');
      // print(info);
      isTrue(info['title'] == 'new title', 'title updated');
    });
  }
}
