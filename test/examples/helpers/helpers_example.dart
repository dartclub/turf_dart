import 'dart:math';
import 'package:turf/turf.dart';
import 'package:turf/to_mercator.dart';
import 'package:turf/to_wgs84.dart';

/// This example demonstrates the helper functions available in turf_dart
void main() {
  // Unit conversions
  unitConversionExamples();

  // Angle conversions
  angleConversionExamples();

  // Bearing to azimuth
  bearingToAzimuthExamples();

  // Rounding
  roundingExamples();

  // Coordinate system conversions
  coordinateSystemConversionExamples();
}

void unitConversionExamples() {
  print('\n=== Unit Conversion Examples ===\n');

  print('Distance Conversions:');
  print(
      '  10 kilometers = ${convertLength(10, Unit.kilometers, Unit.miles).toStringAsFixed(2)} miles');
  print(
      '  26.2 miles = ${convertLength(26.2, Unit.miles, Unit.kilometers).toStringAsFixed(2)} kilometers');
  print(
      '  100 meters = ${convertLength(100, Unit.meters, Unit.feet).toStringAsFixed(2)} feet');
  print(
      '  1 nautical mile = ${convertLength(1, Unit.nauticalmiles, Unit.kilometers).toStringAsFixed(2)} kilometers');

  print('\nRadians to Length:');
  final oneRadian = 1.0;
  print(
      '  1 radian = ${radiansToLength(oneRadian, Unit.kilometers).toStringAsFixed(2)} kilometers');
  print(
      '  1 radian = ${radiansToLength(oneRadian, Unit.miles).toStringAsFixed(2)} miles');
  print(
      '  1 radian = ${radiansToLength(oneRadian, Unit.meters).toStringAsFixed(2)} meters');

  print('\nLength to Radians:');
  print(
      '  100 kilometers = ${lengthToRadians(100, Unit.kilometers).toStringAsFixed(6)} radians');
  print(
      '  100 miles = ${lengthToRadians(100, Unit.miles).toStringAsFixed(6)} radians');

  print('\nLength to Degrees:');
  print(
      '  100 kilometers = ${lengthToDegrees(100, Unit.kilometers).toStringAsFixed(2)} degrees');
  print(
      '  100 miles = ${lengthToDegrees(100, Unit.miles).toStringAsFixed(2)} degrees');

  print('\nArea Conversions:');
  print(
      '  1 square kilometer = ${convertArea(1, Unit.kilometers, Unit.meters).toStringAsFixed(0)} square meters');
  print(
      '  1 square mile = ${convertArea(1, Unit.miles, Unit.acres).toStringAsFixed(2)} acres');
  print(
      '  10000 square meters = ${convertArea(10000, Unit.meters, Unit.kilometers).toStringAsFixed(2)} square kilometers');
  print(
      '  5 acres = ${convertArea(5, Unit.acres, Unit.meters).toStringAsFixed(0)} square meters');
}

void angleConversionExamples() {
  print('\n=== Angle Conversion Examples ===\n');

  print('Degrees to Radians:');
  print('  0° = ${degreesToRadians(0).toStringAsFixed(6)} radians');
  print('  90° = ${degreesToRadians(90).toStringAsFixed(6)} radians');
  print('  180° = ${degreesToRadians(180).toStringAsFixed(6)} radians');
  print('  360° = ${degreesToRadians(360).toStringAsFixed(6)} radians');

  print('\nRadians to Degrees:');
  print('  0 radians = ${radiansToDegrees(0).toStringAsFixed(2)}°');
  print('  π/2 radians = ${radiansToDegrees(pi / 2).toStringAsFixed(2)}°');
  print('  π radians = ${radiansToDegrees(pi).toStringAsFixed(2)}°');
  print('  2π radians = ${radiansToDegrees(2 * pi).toStringAsFixed(2)}°');
}

void bearingToAzimuthExamples() {
  print('\n=== Bearing to Azimuth Examples ===\n');
  print(
      'The bearingToAzimuth function converts any bearing angle to a standard azimuth:');

  final bearings = [-45.0, 0.0, 90.0, 180.0, 270.0, 360.0, 395.0, -170.0];

  print('\nBearing → Azimuth conversions:');
  for (final bearing in bearings) {
    final azimuth = bearingToAzimuth(bearing);
    print('  $bearing° → $azimuth°');
  }
}

void roundingExamples() {
  print('\n=== Rounding Function Examples ===\n');

  final numbers = [3.14159265359, 0.123456789, 42.999999, -8.54321];

  print('Rounding to different precision levels:');
  for (final num in numbers) {
    print('\nOriginal: $num');
    print('  0 decimals: ${round(num, 0)}');
    print('  2 decimals: ${round(num, 2)}');
    print('  4 decimals: ${round(num, 4)}');
    print('  6 decimals: ${round(num, 6)}');
  }

  print('\nPractical usage examples:');
  final coordinate = [151.2093, -33.8688];
  print('  Original coordinate: ${coordinate[0]}, ${coordinate[1]}');
  print(
      '  Rounded coordinate: ${round(coordinate[0], 4)}, ${round(coordinate[1], 4)}');

  final distance = 1234.5678;
  print('  Original distance: $distance meters');
  print('  Rounded distance: ${round(distance, 0)} meters');
}

void coordinateSystemConversionExamples() {
  print('\n=== Coordinate System Conversion Examples ===\n');
  print('Converting between WGS84 (lon/lat) and Web Mercator (EPSG:3857).');

  final locations = [
    {'name': 'New York City', 'lng': -74.006, 'lat': 40.7128},
    {'name': 'Sydney', 'lng': 151.2093, 'lat': -33.8688},
    {'name': 'Tokyo', 'lng': 139.6917, 'lat': 35.6895},
    {'name': 'London', 'lng': -0.1278, 'lat': 51.5074},
  ];

  print('\nConverting well-known locations:');
  for (final location in locations) {
    final lng = location['lng'] as double;
    final lat = location['lat'] as double;

    final wgs84Feature = Feature(
      geometry: Point(coordinates: Position(lng, lat)),
    );

    final mercatorFeature = geoToMercator(wgs84Feature) as Feature<Point>;
    final mx = mercatorFeature.geometry!.coordinates.lng;
    final my = mercatorFeature.geometry!.coordinates.lat;

    print('\n  ${location['name']}:');
    print('  • WGS84 (lon/lat):  [$lng, $lat]');
    print('  • Mercator (x,y):   [${round(mx, 2)}, ${round(my, 2)}]');
  }

  print('\nRound-trip conversion demonstration:');
  final sydneyFeature = Feature(
    geometry: Point(coordinates: Position(151.2093, -33.8688)),
  );

  final mercatorFeature = geoToMercator(sydneyFeature) as Feature<Point>;
  final mx = mercatorFeature.geometry!.coordinates.lng;
  final my = mercatorFeature.geometry!.coordinates.lat;
  print('  Original WGS84:  [151.2093, -33.8688]');
  print('  → Web Mercator:  [${round(mx, 2)}, ${round(my, 2)}]');

  final backFeature = geoToWgs84(mercatorFeature) as Feature<Point>;
  final rlng = backFeature.geometry!.coordinates.lng;
  final rlat = backFeature.geometry!.coordinates.lat;
  print('  → Back to WGS84: [${round(rlng, 6)}, ${round(rlat, 6)}]');

  final lonDiff = (151.2093 - rlng.toDouble()).abs();
  final latDiff = (-33.8688 - rlat.toDouble()).abs();
  print(
      '  Difference: [${lonDiff.toStringAsFixed(10)}°, ${latDiff.toStringAsFixed(10)}°]');

  print('\nPractical uses of coordinate conversions:');
  print(
      '  • Web mapping: Converting between geographic (WGS84) and projection coordinates (Mercator)');
  print(
      '  • Visual representation: Web Mercator is the standard for most web mapping applications');
}
