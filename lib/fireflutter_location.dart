part of './fireflutter.dart';

const String geoFieldName = 'location';

class UserLocation {
  UserLocation({@required FireFlutter inject}) : _ff = inject {
    _checkPermission();
    _initLocation();
  }
  FireFlutter _ff;

  /// [change] event will be fired when user changes his location.
  // ignore: close_sinks
  BehaviorSubject change = BehaviorSubject<GeoFirePoint>.seeded(null);
  // ignore: close_sinks
  BehaviorSubject users = BehaviorSubject<Map<String, dynamic>>.seeded({});

  final Location _location = new Location();

  StreamSubscription usersNearMeSubscription;

  /// Expose `Location` instance.
  Location get instance => _location;

  final Geoflutterfire geo = Geoflutterfire();

  /// Last(movement) geo point of the user.
  GeoFirePoint _lastPoint;

  Future<bool> hasPermission() async {
    return await _location.hasPermission() == PermissionStatus.granted;
  }

  /// Return true if the permission is granted
  Future<bool> _checkPermission() async {
    // print('_checkPermission');

    /// Check if `Location service` is enabled by the device.
    bool locationService = await _location.serviceEnabled();
    if (locationService == false) {
      /// If not, request if not enabled
      locationService = await _location.requestService();

      /// And if the user really rejects to enable the `Location service`,
      if (locationService == false) {
        return false;
      }
    }

    /// Check if the user give permission to the app to use location service
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      /// Request if permission is not granted.
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }

    // print('permission granted:');
    return true;
  }


  /// Listing user location changes.
  ///
  /// It does not matter weather the location service is eanbled or not. Just
  /// listen it here and when the location is enabled later, it will work
  /// alreday.
  _initLocation() async {
    // print('initUserLocation');

    // Changes settings to whenever the `onChangeLocation` should emit new locations.
    _location.changeSettings(
      accuracy: LocationAccuracy.high,
    );

    /// Listen to location change when the user is moving
    ///
    /// this will not emit new location if the device or user is not moving.
    _location.onLocationChanged.listen((LocationData newLocation) {
      if (_ff.notLoggedIn) return;

      /// TODO do not update user location unless the user move (by 1 meter).

      GeoFirePoint _new = geo.point(
        latitude: newLocation.latitude,
        longitude: newLocation.longitude,
      );
      change.add(_new);

      _ff.publicDoc.set({geoFieldName: _new.data}, SetOptions(merge: true));
      // print('update user location on firestore');

      // don't fetch user's near if position is not changed.
      if (_new != _lastPoint) {
        listenUsersNearMe(_new);
      }
      _lastPoint = _new;
    });
  }

  // Other user's location near the current user's location.
  Map<String, dynamic> usersNearMe = {};

  /// todo remove user from the [usersNearMe] when the user goes out of the radius.
  listenUsersNearMe(GeoFirePoint point) {
    // print('listenUsersNearMe');

    if (usersNearMeSubscription != null) usersNearMeSubscription.cancel();
    usersNearMeSubscription = geo
        .collection(collectionRef: _ff.publicCol)
        .within(
          center: point,
          radius: 2, // 2 km
          field: geoFieldName,
          strictMode: true,
        )
        .listen((List<DocumentSnapshot> documents) {
      /// No more users in within the radius
      ///
      /// since it fetch again, then reset user list, also removing users outside the radius.
      usersNearMe = {};

      documents.forEach((document) {
        // print("user location near me");

        // if this is the current user's data. don't add it to the list.
        if (document.id == _ff.user.uid) return;

        Map<String, dynamic> data = document.data();
        GeoPoint _point = data[geoFieldName]['geopoint'];

        // get distance from current user.
        data['distance'] = point.distance(
          lat: _point.latitude,
          lng: _point.longitude,
        );

        // print(document.id);
        usersNearMe[document.id] = data;
        users.add(usersNearMe);
      });
    });
  }
}
