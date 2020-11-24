import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

/// @todo logic and have unit test on it.
/// * There is user A, B, C, D.
/// Log into A, B, C, D repectively and update fake geo information.
///
/// * A search users near himself for 100km radius and got B in the user-near-me screen. /
/// * C goes in(to the radius of search) and appears in the user-near-me screen of A. /
/// * C search users near himself for 5km radius and got D in his user-near-me screen. /
/// * B goes out from A's search and goes into C's search. /
/// * B moves and goes out from C's search and goes in A's search. /

/// * C sees A, B, C in his user-near-me screen.
/// * A sees C, D in his user-near-me screen.
/// * B sees D in his user-near-me screen.
///
///
///
///
class LocationTest {
  LocationTest(FireFlutter ff, UserLocation location)
      : this.ff = ff,
        this.location = location;

  FireFlutter ff;
  UserLocation location;

  Map<String, dynamic> locations = {
// A: 15.1410147 - 120.5844096 	1
    'a': {
      'geohash': '',
      'latitude': 15.1410147,
      'longitude': 120.5844096,
    },
// B: 15.1246466 - 119.9154129	1 5
    'b': {
      'geohash': '',
      'latitude': 15.1246466,
      'longitude': 119.9154129,
    },

// B2: 15.1256682 - 121.6562343	4
    'b2': {
      'geohash': '',
      'latitude': 18.2995873,
      'longitude': 129.0490182,
    },
// C: 15.1446401 - 121.060072	2
    'c': {
      'geohash': '',
      'latitude': 15.1446401,
      'longitude': 121.060072,
    },
// D: 15.1442681 - 121.0889745	3
    'd': {
      'geohash': '',
      'latitude': 18.2994515,
      'longitude': 129.088109,
    },
  };

  Map<String, String> userA = {
    'uid': 'LUF7KTkwiabjdPphjiJX5wbsyhF3',
    'email': 'apple@gmail.com',
    'password': '12345a',
    'displayName': 'apple'
  };
  Map<String, String> userB = {
    'uid': 'gy0VSDAw8gNI11rXburZlqhkz0s2',
    'email': 'berry@gmail.com',
    'password': '12345a',
    'displayName': 'berry'
  };
  Map<String, String> userC = {
    'uid': 'WkeLfnhshSNFdK11j8qDPpuCFrE3',
    'email': 'cherry@gmail.com',
    'password': '12345a',
    'displayName': 'cherry'
  };
  Map<String, String> userD = {
    'uid': 'ayqVJr9UNLNGuFMR3t5pTIkpsyo2',
    'email': 'dragon@gmail.com',
    'password': '12345a',
    'displayName': 'dragon'
  };

  /// reset locations
  prepareUserABCD() async {
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    updateUserLocation('a');
    await ff.loginOrRegister(
      email: userB['email'],
      password: userB['password'],
    );
    updateUserLocation('b');
    await ff.loginOrRegister(
      email: userC['email'],
      password: userC['password'],
    );
    updateUserLocation('c');
    await ff.loginOrRegister(
      email: userD['email'],
      password: userD['password'],
    );
    updateUserLocation('d');
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

  updateUserLocation(String user) {
    dynamic point = locations[user];
    double lat = point['latitude'];
    double lng = point['longitude'];
    dynamic data = location.updateUserLocation(lat, lng).data;
    locations[user]['geohash'] = data['geohash'];
    locations[user]['latitude'] = data['geopoint'].latitude;
    locations[user]['longitude'] = data['geopoint'].longitude;
  }

  getUsersNearMe(data, {double radius = 100}) async {
    dynamic point = location.geo.point(
      latitude: data['latitude'],
      longitude: data['longitude'],
    );

    return location.geo
        .collection(collectionRef: ff.publicCol)
        .within(
          center: point,
          radius: radius,
          field: geoFieldName,
          strictMode: true,
        )
        .firstWhere((element) => element != null);
  }

  bool checkIfUsersIsNearMe(
    List<Map<String, dynamic>> users,
    List<DocumentSnapshot> documents,
  ) {
    bool ret = true;
    users.forEach((user) {
      documents.contains((document) => ret = user['uid'] == document.id);
    });
    return ret;
  }

  runLocationTest() {
    ff.firebaseInitialized.listen((v) async {
      if (!v) return;
      prepareUserABCD();

      /// First test
      ///
      /// * A search users near himself for 100km radius and got B in the user-near-me screen. /
      await ff.loginOrRegister(
        email: userA['email'],
        password: userA['password'],
      );
      List<DocumentSnapshot> usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        checkIfUsersIsNearMe([userB], usersInLocation),
        'User B is near User A [100km]',
      );

      /// Second test
      ///
      /// C goes in(to the radius of search) and appears in the user-near-me screen of A.
      await ff.loginOrRegister(
        email: userC['email'],
        password: userC['password'],
      );
      updateUserLocation('b2');
      await ff.loginOrRegister(
        email: userA['email'],
        password: userA['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        checkIfUsersIsNearMe([userC], usersInLocation),
        'User C is near User A [100km]',
      );

      /// 3rd test
      ///
      /// C search users near himself for 5km radius and got D in his user-near-me screen. /
      await ff.loginOrRegister(
        email: userC['email'],
        password: userC['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['c'],
        radius: 5,
      );

      isTrue(
        checkIfUsersIsNearMe([userD], usersInLocation),
        'User D is near User C [5km]',
      );

      /// B goes out from A's search and goes into C's search. /
      /// B moves and goes out from C's search and goes in A's search. /
    });
  }
}
