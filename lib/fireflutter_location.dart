part of './fireflutter.dart';

const String geoFieldName = 'location';

class UserLocation {
  UserLocation({@required FireFlutter inject}) : _ff = inject {
    _checkPermission();
    _initLocation();
  }
  FireFlutter _ff;

  /// [change] event will be fired not only when user changes his location
  /// but also when there is any event to notice like when the app has no
  /// permission, or the `Location service` is not enabled by the device
  /// settings, [change] event will be fired.
  // ignore: close_sinks
  BehaviorSubject change = BehaviorSubject<dynamic>.seeded(null);

  final Location _location = new Location();

  /// Expose `Location` instance.
  Location get instance => _location;
  final Geoflutterfire _geo = Geoflutterfire();

  /// Expose `geo` instance.
  Geoflutterfire get geo => _geo;

  Future<bool> hasPermission() async {
    return await _location.hasPermission() == PermissionStatus.granted;
  }

  // ignore: unused_field
  // bool locationPermission = false;
  // bool locationService = false;

  _checkPermission() async {
    print('_checkPermission');

    /// Check if `Location service` is enabled by the device.
    bool locationService = await _location.serviceEnabled();
    if (locationService == false) {
      /// If not, request if not enabled
      locationService = await _location.requestService();

      /// And if the user really rejects to enable the `Location service`,
      if (locationService == false) {
        change.add(null);
        return;
      }
    }
    change.add('locationServiceEnabled');

    /// Check if the user give permission to the app to use location service
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      /// Request if permission is not granted.
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        change.add(null);
        return;
      }
    }

    /// Notify the app that permission has granted.
    /// App knows it by checking `_locationPermission`.
    change.add('permissionGranted');

    print('permission granted:');
  }

  /// Listing user location changes.
  ///
  /// It does not matter weather the location service is eanbled or not. Just
  /// listen it here and when the location is enabled later, it will work
  /// alreday.
  _initLocation() async {
    print('initUserLocation');

    // Changes settings to whenever the `onChangeLocation` should emit new locations.
    _location.changeSettings(accuracy: LocationAccuracy.high);

    print('location on changed listen');

    /// Listen to location change when the user is moving
    _location.onLocationChanged.listen((LocationData newLocation) {
      if (_ff.notLoggedIn) return;
      print('update user location on firestore');

      final GeoFirePoint point = _geo.point(
        latitude: newLocation.latitude,
        longitude: newLocation.longitude,
      );

      // _ff.publicDoc.set(
      //   {geoFieldName: point.data},
      //   SetOptions(merge: true),
      // );
      change.add(point.data);
    });
  }
}
