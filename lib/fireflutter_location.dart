/// @file flutter_location
///

part of './fireflutter.dart';

const String geoFieldName = 'location';

///
///
/// FireFlutterLocation can listen users who are comming in/out.
/// You may want to call `init` method in main.dart to listen users in radius immediately when app start.
/// To change the [radus], call `reset` method.
/// When it is
class FireFlutterLocation {
  FireFlutterLocation({
    @required FireFlutter inject,
    double radius = 20.0,
  }) : _ff = inject {
    init(radius: radius);
  }
  FireFlutter _ff;
  double _radius;

  /// [change] event will be fired when user changes his location.
  /// Since [change] is BehaviorSubject, it will be fired with null for the
  /// first time. And when the device can't fetch location information, there
  /// will be no more event after null.
  // ignore: close_sinks
  BehaviorSubject change = BehaviorSubject<GeoFirePoint>.seeded(null);

  /// Since [users] is BehaviorSubject, an event may be fired with empty user
  /// list for the first time.
  // ignore: close_sinks
  BehaviorSubject users = BehaviorSubject<Map<String, dynamic>>.seeded({});

  final Location _location = new Location();

  StreamSubscription usersNearMeSubscription;

  /// Expose `Location` instance.
  Location get instance => _location;

  final Geoflutterfire geo = Geoflutterfire();

  /// Last(movement) geo point of the user.
  GeoFirePoint _lastPoint;
  GeoFirePoint get lastPoint => _lastPoint;

  String _gender;
  DateTime _birthday;

  /// [radius] is the radius to search users. If it is not set(or set as null),
  /// 22(km) will be set by default.
  init({@required double radius}) {
    // print('location:init');
    if (radius == null) radius = 22;
    _radius = radius;
    _gender = null;
    _checkPermission();
    _updateUserLocation();
  }

  /// Reset the radius to search users.
  ///
  /// If [gender] is null, users near me will be both Male and Female
  reset({
    double radius,
    String gender,
    DateTime birthday,
  }) {
    _radius = radius ?? _radius;
    _gender = gender ?? _gender;
    _birthday = birthday ?? _birthday;
    _listenUsersNearMe(_lastPoint);
  }

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
  _updateUserLocation() async {
    // print('initFireFlutterLocation');

    // Changes settings to whenever the `onChangeLocation` should emit new locations.
    _location.changeSettings(
      accuracy: LocationAccuracy.high,
    );

    /// Listen to location change when the user is moving
    ///
    /// This will not emit new location if the device or user is not moving.
    ///
    /// If the device can't fetch location, this method will not be called.
    /// * This is going to work after user login even if the user did logged in on start up
    _location.onLocationChanged.listen((LocationData newLocation) async {
      if (_ff.notLoggedIn) return;

      GeoFirePoint _new = geo.point(
        latitude: newLocation.latitude,
        longitude: newLocation.longitude,
      );

      /// When the user change his location, it needs to search other users base on his new location.
      /// TODO do not update user location unless the user move (by 1 meter) because it may update too often.
      /// * Do not update location when the user didn't move.
      if (_new.hash != _lastPoint?.hash) {
        /// backup user's last location.
        // print('location changed: ');
        _lastPoint = _new;

        await updateUserLocation(_new);
        _listenUsersNearMe(_new);
      }
    });
  }

  Future<GeoFirePoint> updateUserLocation(GeoFirePoint _new) async {
    change.add(_new);
    await _ff.publicDoc.set({geoFieldName: _new.data}, SetOptions(merge: true));
    return _new;
  }

  // Other user's location near the current user's location.
  Map<String, dynamic> usersNearMe = {};

  /// Listen `/meta/user/public/{uid}` for geo point and search users who are
  /// within the radius from my geo point.
  ///
  /// This method will be called
  /// * immediately after the class is instantiated,
  /// * and whenever the user changes his location.
  ///
  /// When the user is moving, it will search new other users within the radiusv
  /// of his geo point. And when the other user comes in to the user's radius,
  /// the other user will be inserted into the search result.
  ///
  /// todo when user move fast (in a car), this method may be call in every seconds.
  /// And a second does not look enough to handle the stream listening(updating UI) of hundreds users within the radius.
  /// ? This is a clear race condition. How are you going to handle this racing?
  ///
  _listenUsersNearMe(GeoFirePoint point) {
    if (point == null) {
      /// If the device can't fetch location information, then [point] will be null.
      return;
    }
    // print('_listenUsersNearMe: $_radius km');

    Query colRef = _ff.publicCol;

    /// filter [gender]
    if (_gender == null) {
      if (_ff.publicData['gender'] == null) return;
      _gender = _ff.publicData['gender'] == 'F' ? 'M' : 'F';
      colRef = colRef.where('gender', isEqualTo: _gender);
    }

    if (usersNearMeSubscription != null) usersNearMeSubscription.cancel();

    // .where('birthday', isGreaterThan: ...),

    usersNearMeSubscription = geo
        .collection(collectionRef: colRef)
        .within(
          center: point,
          radius: _radius, // km
          field: geoFieldName,
          strictMode: true,
        )
        .listen((List<DocumentSnapshot> documents) {
      // print('Users near me: documents:');
      // print(documents);

      /// No more users in within the radius
      ///
      /// since it fetch again, then reset user list, also removing users outside the radius.
      usersNearMe = {};

      if (documents.length == 0) {
        users.add(usersNearMe);
        return;
      }

      documents.forEach((document) {
        // print("user location near me");

        // if this is the current user's data. don't add it to the list.
        if (document.id == _ff.user.uid) return;

        Map<String, dynamic> data = document.data();
        GeoPoint _point = data[geoFieldName]['geopoint'];

        data['uid'] = document.id;

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
