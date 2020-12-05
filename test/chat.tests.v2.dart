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
      await _userInvitationTest();
      await _addModeratorTest();
      await _removeModeratorTest();
      await _leaveTest();
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
    print('_info: $_info');
  }

  _sendMessageTest() async {
    await _ff.loginOrRegister(email: aEmail, password: password);
    final chat = ChatRoom(inject: _ff);
    await chat.enter(users: [b, c]);
  }

  _userInvitationTest() async {}

  _addModeratorTest() async {}
  _removeModeratorTest() async {}

  _leaveTest() async {}
  _blockTest() async {}
  _kickoutTest() async {}

  _roomCreateTest() async {
    // User user = await _ff.loginOrRegister(email: aEmail, password: password);
    // a = user.uid;
    // user = await _ff.loginOrRegister(email: bEmail, password: password);
    // b = user.uid;
    // user = await _ff.loginOrRegister(email: cEmail, password: password);
    // c = user.uid;
    // user = await _ff.loginOrRegister(email: dEmail, password: password);
    // d = user.uid;

    // print("$a $b $c $d");

    /// Login A
    ///
    ///
    ///
    /// TODO: md5 is not enough. when there are many users, uid(s) must be sorted(ordered) or md5 string would have different results.
    /// TODO: give opion on ChatRoom(hatch: true). If hatch is true, then it will always create new room. By default it is false and it does md5 of uids. meaning, it will not create new room if the uids are same.
    /// so, developers does not need to do md5 by themselves.
    ///
    /// if the app can add other users into existing room, hatch should be true. If it is 1:1 chat only, hatch should be false.
    ///

    /// Create room without users.
    /// - ChatRoom() without id and users and hatch: true
    /// - ChatRoom() over again without room id and users, and hatch: true => new room will be created over again
    /// - ChatRoom() with id => no room will be created.
    /// - ChatRoom() should not create new room again if room id is given.
    /// - ChatRoom(hatch: false) should create room for the first time.
    /// - ChatRoom(hatch: false) should not create room again intead, it will enter previous room.

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
