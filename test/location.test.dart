import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

/// * There is user A, B, C, D.
/// Log into A, B, C, D repectively and update fake geo information.
///
/// A search users near himself for 100km radius and got B in the user-near-me screen.
/// C goes in(to the radius of search) and appears in the user-near-me screen of A.
/// C search users near himself for 5km radius and got D in his user-near-me screen.
/// B goes out from A's search and goes into C's search.
/// B moves and goes out from C's search and goes in A's search.
/// C moves and goes out from A's search.
///
class LocationTest {
  LocationTest(FireFlutter ff, UserLocation location)
      : this.ff = ff,
        this.location = location;

  FireFlutter ff;
  UserLocation location;

  Map<String, dynamic> locations = {
    'a': {'geohash': '', 'latitude': 15.1410147, 'longitude': 120.5844096},
    'b': {'geohash': '', 'latitude': 15.1246466, 'longitude': 119.9154129},
    'b2': {'geohash': '', 'latitude': 15.1256682, 'longitude': 121.6562343},
    'c': {'geohash': '', 'latitude': 15.1446401, 'longitude': 121.060072},
    'c2': {'geohash': '', 'latitude': 15.1446401, 'longitude': 122.560072},
    'd': {'geohash': '', 'latitude': 15.1442681, 'longitude': 121.0889745},
  };

  Map<String, String> userA = {
    'uid': 'LUF7KTkwiabjdPphjiJX5wbsyhF3',
    'email': 'apple@gmail.com',
    'password': '12345a',
  };
  Map<String, String> userB = {
    'uid': 'gy0VSDAw8gNI11rXburZlqhkz0s2',
    'email': 'berry@gmail.com',
    'password': '12345a',
  };
  Map<String, String> userC = {
    'uid': 'WkeLfnhshSNFdK11j8qDPpuCFrE3',
    'email': 'cherry@gmail.com',
    'password': '12345a',
  };
  Map<String, String> userD = {
    'uid': 'ayqVJr9UNLNGuFMR3t5pTIkpsyo2',
    'email': 'dragon@gmail.com',
    'password': '12345a',
  };

  /// reset locations
  prepareUserABCD() async {
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    await updateUserLocation('a');
    await ff.loginOrRegister(
      email: userB['email'],
      password: userB['password'],
    );
    await updateUserLocation('b');
    await ff.loginOrRegister(
      email: userC['email'],
      password: userC['password'],
    );
    await updateUserLocation('c');
    await ff.loginOrRegister(
      email: userD['email'],
      password: userD['password'],
    );
    await updateUserLocation('d');
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

  Future updateUserLocation(String user) async {
    dynamic point = locations[user];
    double lat = point['latitude'];
    double lng = point['longitude'];
    return location.updateUserLocation(lat, lng);
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

  bool usersIsNearMe(
    List<Map<String, dynamic>> users,
    List<DocumentSnapshot> usersInLocation, {
    bool inRadius = true,
  }) {
    bool ret = true;
    users.forEach((user) {
      /// Check if the user is existing in the current collection of user inside the search readius
      usersInLocation.contains((document) => ret = user['uid'] == document.id);
    });
    return ret;
  }

  runLocationTest() {
    ff.firebaseInitialized.listen((v) async {
      if (!v) return;
      prepareUserABCD();
      List<DocumentSnapshot> usersInLocation;

      /// * A search users near himself for 100km radius and got B in the user-near-me screen.
      /// - login to A
      /// - check user near A
      await ff.loginOrRegister(
        email: userA['email'],
        password: userA['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        usersIsNearMe([userB], usersInLocation),
        'User B is near User A [100km]',
      );

      /// C goes in(to the radius of search) and appears in the user-near-me screen of A.
      /// - login to C
      /// - update location near to A
      /// - login to A
      /// - check if C is near A
      ///
      await ff.loginOrRegister(
        email: userC['email'],
        password: userC['password'],
      );
      await updateUserLocation('c');
      await ff.loginOrRegister(
        email: userA['email'],
        password: userA['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        usersIsNearMe([userC], usersInLocation),
        'User C is near User A [100km search radius]',
      );

      /// C search users near himself for 5km radius and got D in his user-near-me screen. /
      /// - login to C
      /// - check if D is near within 5KM
      ///
      await ff.loginOrRegister(
        email: userC['email'],
        password: userC['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['c'],
        radius: 5,
      );
      isTrue(
        usersIsNearMe([userD], usersInLocation),
        'User D is near User C [5km search radius]',
      );

      /// B goes out from A's search and goes into C's search. /
      /// - login to B
      /// - move location near C and far from A.
      /// - login A, check if B is not near.
      /// - login C, check if B is near.
      await ff.loginOrRegister(
        email: userB['email'],
        password: userB['password'],
      );
      await updateUserLocation('b2');
      await ff.loginOrRegister(
        email: userA['email'],
        password: userA['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        usersIsNearMe([userB], usersInLocation) == true,
        'User B is not near User A [100km search radius]',
      );
      await ff.loginOrRegister(
        email: userC['email'],
        password: userC['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['c'],
      );
      isTrue(
        usersIsNearMe([userB], usersInLocation),
        'User B is near User C [100km search radius]',
      );

      /// B moves and goes out from C's search and goes in A's search.
      /// - login to B
      /// - move location near A and far from C.
      /// - login C, check if B is not near.
      /// - login A, check if B is near.
      ///
      await ff.loginOrRegister(
        email: userB['email'],
        password: userB['password'],
      );
      await updateUserLocation('b');
      await ff.loginOrRegister(
        email: userA['email'],
        password: userA['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        usersIsNearMe([userB], usersInLocation) == true,
        'User B is near User A [100km search radius]',
      );
      await ff.loginOrRegister(
        email: userC['email'],
        password: userC['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['c'],
      );
      isTrue(
        usersIsNearMe([userB], usersInLocation),
        'User B is not near User C [100km search radius]',
      );

      /// C moves and goes out from A's search.
      /// - login to C.
      /// - move location out of A's search radius.
      /// - login to A, check if C is not near.
      /// 
      await ff.loginOrRegister(
        email: userC['email'],
        password: userC['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['c2'],
      );
      await ff.loginOrRegister(
        email: userA['email'],
        password: userA['password'],
      );
      usersInLocation = await getUsersNearMe(
        locations['a'],
      );
      isTrue(
        usersIsNearMe([userB], usersInLocation),
        'User C is not near User A [100km search radius]',
      );
    });
  }
}
