import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

/// * A search users near himself for 100km radius and got B in the user-near-me screen.
/// * C goes in(to the radius of search) and appears in the user-near-me screen of A.
/// * C search users near himself for 5km radius and got D in his user-near-me screen.
/// * B goes out from A's search and goes into C's search.
/// * D moves and goes out from C's search and goes in A's search.
///
/// * B moves and goes out from C's search and goes in A's search.
/// * C moves and goes into A's search.
/// * C sees A, B, in his user-near-me screen.
/// * A sees C, D in his user-near-me screen.
/// * B sees D in his user-near-me screen.

/// -> Initially A and B are nearby each other.
/// -> C will move inside A's search radius.
///   -> C will see D in his search radius.
/// -> B will move out of A's radius and into C's radius.
///
class LocationTest {
  LocationTest(FireFlutter ff, UserLocation location)
      : this.ff = ff,
        this.location = location;

  FireFlutter ff;
  UserLocation location;

  Map<String, dynamic> locations = {
    'a': {
      'geohash': '',
      'latitude': 17.5804338,
      'longitude': 129.2972281,
    },
    'b': {
      'geohash': '',
      'latitude': 17.9672081,
      'longitude': 129.838777,
    },
    'c': {
      'geohash': '',
      'latitude': 18.8663689,
      'longitude': 129.9290352,
    },
    'c2': {
      'geohash': '',
      'latitude': 18.2995873,
      'longitude': 129.0490182,
    },
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
    await ff.loginOrRegister(userA);
    updateUserLocation('a');
    await ff.loginOrRegister(userB);
    updateUserLocation('b');
    await ff.loginOrRegister(userC);
    updateUserLocation('c');
    await ff.loginOrRegister(userD);
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

      /// A search users near himself and got B in the user-near-me screen.
      await ff.loginOrRegister(userA);
      List<DocumentSnapshot> usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        checkIfUsersIsNearMe([userB], usersInLocation),
        'User B is near User A [100km]',
      );

      /// C goes in(to the radius of search) and appears in the user-near-me screen of A.
      await ff.loginOrRegister(userC);
      updateUserLocation('c2');
      await ff.loginOrRegister(userA);
      usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        checkIfUsersIsNearMe([userC], usersInLocation),
        'User C is near User A [100km]',
      );

      /// C search users near himself for 5km radius and got D in his user-near-me screen.
      await ff.loginOrRegister(userC);
      usersInLocation = await getUsersNearMe(
        locations['c2'],
      );
      isTrue(
        checkIfUsersIsNearMe([userD], usersInLocation),
        'User D is near User C [5km]',
      );

      /// B goes out from A's search and goes into C's search.
    });
  }
}
