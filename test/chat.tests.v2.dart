// import 'package:fireflutter/functions.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String password = '12345a,*,';
const String aEmail = 'AAA@gmail.com';
const String bEmail = 'BBB@gmail.com';
const String cEmail = 'CCC@gmail.com';
const String dEmail = 'DDD@gmail.com';

class ChatTest {
  ChatTest({@required FireFlutter inject}) : this._ff = inject;

  FireFlutter _ff;
  int _countError = 0;

  String a = 'iiVOFXhlVcPBvhC7BtBsyF1AfH52';
  String b = 'vm7F4mdex9TrY1wmVrPgYWANkYH2';
  String c = 'f5xZJYNjL6UuLpjRn7g9OJCoGqH3';
  String d = 'GYfxU2FQzgMobRBxt9er99i1fah1';
  runTests() async {
    _ff.firebaseInitialized.listen((value) async {
      if (!value) return;
      await _roomCreateTest();
      await _enterRoomTest();
      await _sendMessageTest();
      await _leaveTest();
      await _userInvitationTest();
      await _addModeratorTest();
      await _removeModeratorTest();
      await _blockTest();
      await _kickoutTest();

      print('ERROR: [ $_countError ]');
    });
  }

  _enterRoomTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c]);
    ChatRoomInfo _info = await chat.lastMessage;
    isTrue(_info.text == ChatProtocol.roomCreated, 'roomCreated a');

    await _ff.loginOrRegister(email: bEmail, password: password);
    _info = await chat.lastMessage;
    isTrue(_info.text == ChatProtocol.roomCreated, 'roomCreated b');

    await _ff.loginOrRegister(email: cEmail, password: password);
    _info = await chat.lastMessage;
    isTrue(_info.text == ChatProtocol.roomCreated, 'roomCreated c');

    await _ff.loginOrRegister(email: dEmail, password: password);
    try {
      _info = await chat.lastMessage;
      isTrue(false, 'Expect failure for d');
    } catch (e) {
      isTrue(e == ROOM_NOT_EXISTS, 'Chat room not exist for d.');
    }
  }

  _sendMessageTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c]);
    final ChatRoomInfo _info = await chat.lastMessage;
    isTrue(_info.text == ChatProtocol.roomCreated, 'roomCreated');
    final String text = 'Yo ... !';

    await chat.sendMessage(text: text);
    final ChatRoomInfo lastMessageA = await chat.lastMessage;
    isTrue(lastMessageA.text == text, 'Got last message for a');

    await _ff.loginOrRegister(email: bEmail, password: password);
    final ChatRoomInfo lastMessageB = await chat.lastMessage;
    isTrue(lastMessageB.text == text, 'Got last message for b');

    await _ff.loginOrRegister(email: cEmail, password: password);
    final ChatRoomInfo lastMessageC = await chat.lastMessage;
    isTrue(lastMessageC.text == text, 'Got last message for c');
  }

  _leaveTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c], hatch: true);

    await _ff.loginOrRegister(email: bEmail, password: password);
    final chatB = ChatRoom(inject: _ff);
    await chatB.enter(id: chat.id);
    await chatB.leave();

    await _ff.loginOrRegister(email: aEmail, password: password);
    final chatA = ChatRoom(inject: _ff);
    await chatA.enter(id: chat.id);
    final lastMessageA = await chatA.lastMessage;
    isTrue(lastMessageA.text == ChatProtocol.leave, 'leave checked by a');

    await _ff.loginOrRegister(email: cEmail, password: password);
    final chatC = ChatRoom(inject: _ff);
    await chatC.enter(id: chat.id);
    final lastMessageC = await chatC.lastMessage;
    isTrue(lastMessageC.text == ChatProtocol.leave, 'leave checked by c');

    await _ff.loginOrRegister(email: bEmail, password: password);
    try {
      await chatB.lastMessage;
      isTrue(false, 'room must not exist after leave');
    } catch (e) {
      isTrue(e == ROOM_NOT_EXISTS, 'room not exist after leave');
    }
  }

  _userInvitationTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter();
    await chat.addUser({b: 'B'});
    final lastMassage = await chat.lastMessage;
    isTrue(lastMassage.text == ChatProtocol.add, 'b added');
    isTrue(lastMassage.newUsers.length == 1, 'one user added');
    isTrue(lastMassage.newUsers.first == 'B', 'The user is B');

    // ? Strange action: It produce permission-error here if it does not read
    // ? updated room. The security rule is very clean.
    await chat.getGlobalRoom(chat.id);

    await _ff.loginOrRegister(email: bEmail, password: password);
    final bChat = ChatRoom(inject: _ff);
    await bChat.enter(id: chat.id);
    await bChat.addUser({c: 'C', d: 'D'});

    final lastMassageB = await bChat.lastMessage;
    isTrue(lastMassageB.text == ChatProtocol.add, 'C & D added');
    isTrue(lastMassageB.newUsers.length == 2, 'One user added');
    isTrue(lastMassageB.newUsers.contains('C'), 'The user C is included');
    isTrue(lastMassageB.newUsers.contains('D'), 'The user D is included');

    final room = await bChat.getGlobalRoom(bChat.id);
    isTrue(room.users.length == 4, 'Four users are in the room');
    isTrue(room.users.contains(a), 'A is included');
    isTrue(room.users.contains(b), 'B is included');
    isTrue(room.users.contains(c), 'C is included');
    isTrue(room.users.contains(d), 'D is included');

    bChat.leave();

    await _ff.loginOrRegister(email: cEmail, password: password);
    final cChat = ChatRoom(inject: _ff);
    await cChat.enter(id: chat.id);
    final cRoom = await cChat.getGlobalRoom(chat.id);

    isTrue(cRoom.users.length == 3, 'Four users are in the room');
    isTrue(cRoom.users.contains(a), 'A is included');
    isTrue(cRoom.users.contains(b) == false, 'B is NOT included');
    isTrue(cRoom.users.contains(c), 'C is included');
    isTrue(cRoom.users.contains(d), 'D is included');
  }

  _addModeratorTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c]);
    await chat.addModerator(b);
    var room = await chat.getGlobalRoom(chat.id);
    print(room);
    isTrue(room.moderators.length == 2, '2 moderators are in the room');
    isTrue(room.moderators.contains(a), 'A is included as moderator');
    isTrue(room.moderators.contains(b), 'B is included as moderator');

    try {
      await chat.addModerator(d);
      isTrue(false, 'await chat.addModerator(c);');
    } catch (e) {
      isTrue(
          e == MODERATOR_NOT_EXISTS_IN_USERS, 'moderator must exists in users');
    }

    await _ff.loginOrRegister(email: cEmail, password: password);
    final cChat = ChatRoom(inject: _ff);
    await cChat.enter(id: chat.id);
    await cChat.addUser({d: 'User D'});

    try {
      await cChat.addModerator(d);
      isTrue(false, 'You are not moderator');
    } catch (e) {
      isTrue(e == YOU_ARE_NOT_MODERATOR,
          'Only moderator can add another moderator');
    }

    // room = await chat.getGlobalRoom(chat.id);
    // print(room);
  }

  _removeModeratorTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c]);
    await chat.addModerator(b);
    var room = await chat.getGlobalRoom(chat.id);
    isTrue(room.moderators.length == 2, '2 moderators are in the room');
    isTrue(room.moderators.contains(a), 'A is included as moderator');
    isTrue(room.moderators.contains(b), 'B is included as moderator');

    await chat.removeModerator(b);
    room = await chat.getGlobalRoom(chat.id);
    isTrue(room.moderators.length == 1, '2 moderators are in the room');
    isTrue(room.moderators.contains(a), 'A is included as moderator');
    isTrue(
        room.moderators.contains(b) == false, 'B is NOT included as moderator');
  }

  _blockTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c]);
    await chat.blockUser(b, 'Name of B');
    var room = await chat.getGlobalRoom(chat.id);
    isTrue(room.users.length == 2, '2 user is in the room');
    isTrue(room.blockedUsers.length == 1, '1 user is in block list');
    isTrue(room.blockedUsers.first == b, 'b is blocked');

    try {
      await chat.addUser({b: 'Name of B'});
      isTrue(false, "await chat.addUser({b: 'Name of B'});");
    } catch (e) {
      isTrue(e == ONE_OF_USERS_ARE_BLOCKED, 'One of users are in block list');
    }
  }

  _kickoutTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c]);

    await _ff.loginOrRegister(email: bEmail, password: password);
    final bChat = ChatRoom(inject: _ff);
    await bChat.enter(id: chat.id);

    try {
      await bChat.kickout(c, 'Name of C');
      isTrue(false, "await bChat.kickout(c, 'Name of C');");
    } catch (e) {
      isTrue(e == YOU_ARE_NOT_MODERATOR, 'Only moderator can kick a user out');
    }

    await _ff.loginOrRegister(email: aEmail, password: password);
    await chat.kickout(c, 'Name of C');

    var room = await chat.getGlobalRoom(chat.id);
    isTrue(room.users.length == 2, '2 user is in the room');

    isTrue(room.users.contains(a), 'A is included');
    isTrue(room.users.contains(b), 'B is included');
    isTrue(room.users.contains(c) == false, 'C is NOT included');
  }

  _roomCreateTest() async {
    // User user = await _ff.l
    // create room alone
    final chat = ChatRoom(inject: _ff, render: null);
    await chat.enter();
    isTrue(chat.users.length == 1, "chat.users.length == 1");
    await chat.enter();
    isTrue(chat.users.first == _ff.user.uid, "Alone in the room(myself only)");

    final newChatRoom = ChatRoom(inject: _ff, render: null);
    await newChatRoom.enter();
    isTrue(chat.id != newChatRoom.id, 'chat.id != newChatRoom.id');

    // hatch test
    final hatchChat = ChatRoom(inject: _ff);
    hatchChat.enter(hatch: false);

    final hatchChat2 = ChatRoom(inject: _ff);
    hatchChat2.enter(hatch: false);

    isTrue(hatchChat.id == hatchChat2.id, 'hatchChat.id == hatchChat2.id');

    // create room with users.
    // when user login changes, there might be some errors on auth state change, updating user & public doc
    await _ff.loginOrRegister(email: aEmail, password: password);

    final cab1 = ChatRoom(inject: _ff);
    await cab1.enter(users: [b]);

    isTrue(cab1.users.length == 2, 'cab1.users.length == 2');
    isTrue(cab1.users.contains(a), 'a exists in the room - cab1');
    isTrue(cab1.users.contains(b), 'b exists in the room - cab1');

    final cab2 = ChatRoom(inject: _ff);
    await cab2.enter(users: [b]);

    isTrue(cab1.id != cab2.id, 'cab1 and cab2 are different rooms');

    final chatAB = ChatRoom(inject: _ff);
    await chatAB.enter(users: [b], hatch: false);
    isTrue(chatAB.users.length == 2, 'chatAB.users.length == 2');
    isTrue(chatAB.users.contains(a), 'a exists in the room');
    isTrue(chatAB.users.contains(b), 'b exists in the room');

    isTrue(cab1.id != chatAB.id, 'cab1.id != chatAB.id');
    isTrue(cab2.id != chatAB.id, 'cab2.id != chatAB.id');

    // hatch test
    final chatAB2 = ChatRoom(inject: _ff);
    await chatAB2.enter(users: [b], hatch: false);
    isTrue(chatAB2.users.length == 2, 'chatAB.users.length == 2');
    isTrue(chatAB2.users.contains(a), 'a exists in the room');
    isTrue(chatAB2.users.contains(b), 'b exists in the room');
    isTrue(chatAB.id == chatAB2.id,
        'Using existing room by hatch option. chatAB and chatAB2 are same room');

    // login into B
    // when user login changes, there might be some errors on auth state change, updating user & public doc
    await _ff.loginOrRegister(email: bEmail, password: password);

    final ca = ChatRoom(inject: _ff);
    await ca.enter(users: [a], hatch: false);
    isTrue(ca.id == chatAB.id,
        'Using existing room by hatch option. ca.id == chatAB.id');

    final chatBA = ChatRoom(inject: _ff);
    await chatBA.enter(users: [b, a], hatch: false);
    isTrue(chatAB.id == chatBA.id,
        'Using existing room by hatch option. chatAB.id == chatBA.id');
    isTrue(chatAB2.id == chatBA.id,
        'Using existing room by hatch option. chatAB.id == chatBA.id');

    await _ff.loginOrRegister(email: aEmail, password: password);

    final cdb = ChatRoom(inject: _ff);
    await cdb.enter(users: [c, d, b], hatch: false);
    final badc = ChatRoom(inject: _ff);
    await badc.enter(users: [b, a, d, c], hatch: false);
    final aabdc = ChatRoom(inject: _ff);
    await aabdc.enter(users: [a, a, b, d, c], hatch: false);

    isTrue(cdb.id == badc.id,
        'Using existing room by hatch option. cdb.id == badc.id');

    isTrue(cdb.id == aabdc.id,
        'Using existing room by hatch option. ccdb.id == aabdc.id');

    await _ff.loginOrRegister(email: bEmail, password: password);

    final rbc = ChatRoom(inject: _ff);
    await rbc.enter(users: [c], hatch: false);
    final rbc2 = ChatRoom(inject: _ff);
    await rbc2.enter(users: [c], hatch: false);

    isTrue(rbc.id == rbc2.id,
        'Using existing room by hatch option. ccdb.id == aabdc.id');

    final rbcd = ChatRoom(inject: _ff);
    await rbcd.enter(users: [b, c, d], hatch: false);

    isTrue(rbc.id != rbcd.id,
        'Using existing room by hatch option. rbc.id == rbcd.id');

    final rabc = ChatRoom(inject: _ff);
    await rabc.enter(users: [a, b, c], hatch: false);
    isTrue(rabc.id != rbcd.id,
        'Using existing room by hatch option. rabc.id != rbcd.id,');

    final abcd = ChatRoom(inject: _ff);
    await abcd.enter(users: [a, b, c, d], hatch: false);
    isTrue(abcd.id == aabdc.id,
        'Using existing room by hatch option. rabcd.id == aabdc.id');

    await _ff.loginOrRegister(email: cEmail, password: password);
    final abcd2 = ChatRoom(inject: _ff);
    await abcd2.enter(users: [a, b, c, d], hatch: false);
    isTrue(abcd2.id == aabdc.id,
        'Using existing room by hatch option. abcd2.id == aabdc.id');
  }

  success(String message) {
    print("[SUCCESS] $message");
  }

  failture(String message) {
    print("-----------------------------------------> [FAILURE] $message");
    _countError++;
  }

  isTrue(bool re, [String message]) {
    if (re)
      success(message);
    else
      failture(message);
  }
}
