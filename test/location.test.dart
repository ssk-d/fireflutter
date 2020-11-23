import 'package:fireflutter/fireflutter.dart';

/// * A search users near himself for 100km radius and got B in the user-near-me screen.
/// B in A screen
///
/// * C goes in(to the radius of search) and appears in the user-near-me screen of A.
/// B in A screen
/// * A in C screen
///
/// * C search users near himself for 5km radius and got D in his user-near-me screen.
/// B in A screen
/// A in C screen
/// * D in C screen
///
/// * B goes out from A's search and goes into C's search.
/// A in C screen
/// D in C screen
/// * B in C screen
///
/// * D moves and goes out from C's search and goes in A's search.
/// A in C screen
/// B in C screen
/// * D in A screen
///
/// * B moves and goes out from C's search and goes in A's search.
/// A in C screen
/// D in A screen
/// * B in A screen
///
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
      'location': {
        'geohash': 'wdty0n7t1', // angeles, pampanga, (near arayat road)
        'geopoint': {'Latitude': 15.1523928, 'Longitude': 120.5908085}
      }
    },
    'b': {
      'location': {
        'geohash': 'wdty0p63r', // Angeles, pampanga (near robinsons)
        'geopoint': {'Latitude': 15.1572565, 'Longitude': 120.5893648}
      }
    },
    'c': {
      'location': {
        'geohash': 'wdtusr7my', // calumpit, bulacan (near national highschool)
        'geopoint': {'Latitude': 14.894354, 'Longitude': 120.777427}
      }
    },
    'd': {
      'location': {
        'geohash': 'wdtvdnu1d', // san fernando, pampanga (near sky ranch)
        'geopoint': {'Latitude': 15.0666456, 'Longitude': 120.6794162}
      }
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

  updateUserLocation(String user) {
    Map<String, dynamic> point = locations[user]['location']['geopoint'];
    double lat = point['Latitude'];
    double lng = point['Longitude'];
    location.updateUserLocation(lat, lng);
  }
}
