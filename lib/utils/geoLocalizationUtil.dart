import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


class Geolocalizationutil {
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled
    print('Location services are disabled.');
    return null;
  }

  // Check location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied
      print('Location permissions are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever
    print('Location permissions are permanently denied.');
    return null;
  }

  // Get the current location
  Position position = await Geolocator.getCurrentPosition(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 100,
  )
  )
  ;
  print(position);
  return position;
}  
}