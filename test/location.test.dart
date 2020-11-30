import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
///
///```dart
/// /// sample code.
/// /// how to use this test.
///
/// /// imports
/// import 'package:fireflutter/fireflutter.dart';
/// import 'file:///<some_folders>/sms/flutter/v1/packages/fireflutter/test/location.test.dart';
///
/// ...
/// testLocation() {
///   FireFlutter ff = FireFlutter();
///   FireFlutterLocation location = FireFlutterLocation(inject: ff);
///   ff.init();
///   LocationTest lt = LocationTest(ff, location);
///   lt.runLocationTest();
/// }
///```
class LocationTest {
  LocationTest(
    FireFlutter ff,
    FireFlutterLocation location,
  )   : this.ff = ff,
        this.location = location;

  FireFlutterLocation location;
  FireFlutter ff;

  Map<String, dynamic> locations = {
    'a': {'latitude': 15.1410147, 'longitude': 120.5844096},
    'b': {'latitude': 15.1246466, 'longitude': 119.9154129},
    'b2': {'latitude': 15.1256682, 'longitude': 121.6562343},
    'c': {'latitude': 15.1446401, 'longitude': 121.060072},
    'c2': {'latitude': 15.1446401, 'longitude': 122.560072},
    'd': {'latitude': 15.1442681, 'longitude': 121.0889745},
    'e': {'latitude': 11.6736141, 'longitude': 118.1261972},

    /// countries
    'australia': {'latitude': -24.9924915, 'longitude': 115.2264875},
    'mongolia': {'latitude': 46.5283099, 'longitude': 94.8624631},
    'china': {'latitude': 34.4555907, 'longitude': 86.0803082},
    'southkorea': {'latitude': 35.1047551, 'longitude': 124.638392},
    'philippines': {'latitude': 11.6736141, 'longitude': 118.1261972}
  };

  Map<String, String> userA = {
    'uid': '',
    'email': 'apple@gmail.com',
    'password': '12345a',
  };
  Map<String, String> userB = {
    'uid': '',
    'email': 'berry@gmail.com',
    'password': '12345a',
  };
  Map<String, String> userC = {
    'uid': '',
    'email': 'cherry@gmail.com',
    'password': '12345a',
  };
  Map<String, String> userD = {
    'uid': '',
    'email': 'dragon@gmail.com',
    'password': '12345a',
  };

  Map<String, String> userE = {
    'uid': '',
    'email': 'evergreen@gmail.com',
    'password': '12345a',
  };

  /// prepare / reset user locations
  _prepareCloseRangeLocations() async {
    User user;

    /// A
    user = await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    userA['uid'] = user.uid;
    print(userA.toString());
    await updateUserLocation('a', 'User A initial location');

    /// B
    user = await ff.loginOrRegister(
      email: userB['email'],
      password: userB['password'],
    );
    userB['uid'] = user.uid;
    print(userB.toString());
    await updateUserLocation('b', 'User B initial location');

    /// C
    user = await ff.loginOrRegister(
      email: userC['email'],
      password: userC['password'],
    );
    userC['uid'] = user.uid;
    print(userC.toString());
    await updateUserLocation('c', 'User C initial location');

    /// D
    user = await ff.loginOrRegister(
      email: userD['email'],
      password: userD['password'],
    );
    userD['uid'] = user.uid;
    print(userD.toString());
    await updateUserLocation('d', 'User D initial location');

    /// E
    user = await ff.loginOrRegister(
      email: userE['email'],
      password: userE['password'],
    );
    userE['uid'] = user.uid;
    print(userE.toString());
    await updateUserLocation('d', 'User E initial location');
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

  /// Update the user location on `FireStore`
  ///
  /// [user] is the user letter (a/b/c/d).
  /// [message] can be anything string which will be logged if not empty or null
  Future<GeoFirePoint> updateUserLocation(
    String user, [
    String message = '',
  ]) async {
    if (message != '') print('[LOCATION UPDATE] $message');
    dynamic point = locations[user];
    double lat = point['latitude'];
    double lng = point['longitude'];
    final geo = Geoflutterfire();
    GeoFirePoint _new = geo.point(
      latitude: lat,
      longitude: lng,
    );
    return location.updateUserLocation(_new);
  }

  /// Return list of user near the given coordinates
  ///
  /// [data]'s `latitude` & `longitude` should not be null.
  /// [radius] is in KM (Kilometers)
  ///
  /// Note: Instead of listening for changes, it will cast it as a `Future`
  /// returning list of user inside the given [radius]
  Future<List<DocumentSnapshot>> getUsersNearMe(
    data, {
    double radius = 100,
  }) async {
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

  /// Returns true if all [users] are included in [usersInLocation]
  ///
  /// will return a boolean value if [users] are existing or not on the list of documents [usersInLocation]
  ///
  /// [users] are the list of sample user.
  /// [usersInLocation] are list of document from `Firestore`
  ///
  bool userIsNearMe(
    Map<String, dynamic> user,
    List<DocumentSnapshot> usersInLocation,
  ) {
    // usersInLocation.every((doc) => users.contains(element) )

    // bool re = users.fold(
    //     false,
    //     (prev, user) => prev
    //         ? prev
    //         : usersInLocation.contains((doc) => doc.id == user['uid']));

    /// Check if the user is existing in the current collection of user inside the search readius
    // bool re = usersInLocation.firstWhere((document) { user['uid'] == document.id });
    DocumentSnapshot re = usersInLocation.firstWhere(
      (document) => user['uid'] == document.id,
      orElse: () => null,
    );

    return re != null;
  }

  /// Run test
  ///
  /// Comments are added so it is clear what steps are being executed.
  runLocationTest() {
    ff.firebaseInitialized.listen((v) async {
      if (!v) return;
      // await _closeRangeTest();
      await _otherCountryTest();
    });
  }

  /// Close range test (Philippines)
  _closeRangeTest() async {
    await _prepareCloseRangeLocations();
    List<DocumentSnapshot> usersInLocation;

    /// User A search users near himself for 100km radius and got B in the user-near-me screen.
    /// - login to A
    /// - check user near A, B should be near.
    ///
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(
      locations['a'],
    );
    isTrue(
      userIsNearMe(userB, usersInLocation),
      'User B is near User A [100km]',
    );

    /// C goes in (to the radius of search) and appears in the user-near-me screen of A.
    /// - login to C
    /// - update location near to A
    /// - login to A
    /// - check if C is near A
    ///
    await ff.loginOrRegister(
      email: userC['email'],
      password: userC['password'],
    );
    await updateUserLocation(
      'c',
      'User C Enters User A and D search radius',
    );
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(
      locations['a'],
    );
    isTrue(
      userIsNearMe(userC, usersInLocation),
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
      userIsNearMe(userD, usersInLocation),
      'User D is near User C [5km search radius]',
    );

    /// B goes out from A's search and goes into C's search. /
    /// - login to B
    /// - move location near C and far from A.
    /// - login A, check if B is not near.
    /// - login C, check if B is near.
    ///
    await ff.loginOrRegister(
      email: userB['email'],
      password: userB['password'],
    );
    await updateUserLocation(
      'b2',
      'User B leaves User A and enters User C search radius',
    );
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(
      locations['a'],
    );
    isTrue(
      userIsNearMe(userB, usersInLocation) == false,
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
      userIsNearMe(userB, usersInLocation),
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
    await updateUserLocation(
      'b',
      'User B leaves user C and enters user A search radius',
    );
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(
      locations['a'],
    );
    isTrue(
      userIsNearMe(userB, usersInLocation),
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
      userIsNearMe(userB, usersInLocation) == false,
      'User B is not near User C [100km search radius]',
    );

    /// C is out from A's search.
    /// - login to C.
    /// - move location out of A's search radius.
    /// - login to A, check if C is not near.
    ///
    await ff.loginOrRegister(
      email: userC['email'],
      password: userC['password'],
    );
    await updateUserLocation(
      'c2',
      'User C leaves user A and D search radius',
    );
    usersInLocation = await getUsersNearMe(
      locations['c2'],
    );
    await ff.loginOrRegister(
      email: userD['email'],
      password: userD['password'],
    );
    usersInLocation = await getUsersNearMe(
      locations['d'],
      radius: 5,
    );
    isTrue(
      userIsNearMe(userB, usersInLocation) == false,
      'User C is not near User D [5km search radius]',
    );
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(
      locations['a'],
    );
    isTrue(
      userIsNearMe(userC, usersInLocation) == false,
      'User C is not near User A [100km search radius]',
    );
  }

  _prepareOtherCountyLocations() async {
    User user;

    /// Users A, B, C, D goes to different countries
    ///
    /// A - Australia
    user = await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    userA['uid'] = user.uid;
    await updateUserLocation('australia', 'User A goes to Australia');

    /// B - China
    user = await ff.loginOrRegister(
      email: userB['email'],
      password: userB['password'],
    );
    userB['uid'] = user.uid;
    await updateUserLocation('china', 'User B goes to China');

    /// C - Korea
    user = await ff.loginOrRegister(
      email: userC['email'],
      password: userC['password'],
    );

    userC['uid'] = user.uid;
    await updateUserLocation('southkorea', 'User C goes to South Korea');

    /// D - Mongolia
    user = await ff.loginOrRegister(
      email: userD['email'],
      password: userD['password'],
    );

    userD['uid'] = user.uid;
    await updateUserLocation('mongolia', 'User D goes to Mongolia');

    /// E - Philippines
    user = await ff.loginOrRegister(
      email: userE['email'],
      password: userE['password'],
    );

    userE['uid'] = user.uid;
    await updateUserLocation('philippines', 'User E goes to Philippines');
  }

  /// Long range test (Other countries)
  _otherCountryTest() async {
    await _prepareOtherCountyLocations();
    List<DocumentSnapshot> usersInLocation;

    /// Location test - [ Country ]
    ///
    /// E should not be near A
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(locations['australia']);
    isTrue(
      userIsNearMe(userE, usersInLocation) == false,
      'User E is not near User A',
    );

    /// E should be near A
    await ff.loginOrRegister(
      email: userE['email'],
      password: userE['password'],
    );

    /// Update user E location to Australia
    await updateUserLocation(
      'australia',
      "User E enters User A's search radius in Australia",
    );

    /// Login user A and check if User E is nearby
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(locations['australia']);
    isTrue(
      userIsNearMe(userE, usersInLocation),
      'User E is near User A',
    );

    /// E should not be near A and should be near B
    ///
    /// change user E location to china
    await ff.loginOrRegister(
      email: userE['email'],
      password: userE['password'],
    );
    await updateUserLocation(
      'china',
      "User E enters User B's search radius in China",
    );

    /// Get users near A
    await ff.loginOrRegister(
      email: userA['email'],
      password: userA['password'],
    );
    usersInLocation = await getUsersNearMe(locations['australia']);
    isTrue(
      userIsNearMe(userE, usersInLocation) == false,
      'User E is not near User A',
    );

    /// Login B, check if C is not nearby
    await ff.loginOrRegister(
      email: userB['email'],
      password: userB['password'],
    );
    usersInLocation = await getUsersNearMe(locations['china']);
    isTrue(
      userIsNearMe(userE, usersInLocation),
      'User E is near User B',
    );
  }
}
