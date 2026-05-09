import 'dart:math';
import 'package:turf/turf.dart';
import 'package:turf/to_mercator.dart';
import 'package:turf/to_wgs84.dart';

void main() {
  testUnitConversions();
  testAngleConversions();
  testBearingToAzimuth();
  testRounding();
  testCoordinateSystemConversions();
}

void testUnitConversions() {
  print('\n=== Testing Unit Conversions ===\n');

  // Test radiansToLength
  final testRadians = 1.0; // 1 radian
  print('1 radian equals:');
  print('  ${radiansToLength(testRadians, Unit.kilometers)} kilometers');
  print('  ${radiansToLength(testRadians, Unit.miles)} miles');
  print('  ${radiansToLength(testRadians, Unit.meters)} meters');

  // Test lengthToRadians
  final testDistance = 100.0; // 100 units
  print('\n100 units equals:');
  print(
      '  ${lengthToRadians(testDistance, Unit.kilometers)} radians from kilometers');
  print('  ${lengthToRadians(testDistance, Unit.miles)} radians from miles');
  print('  ${lengthToRadians(testDistance, Unit.meters)} radians from meters');

  // Test lengthToDegrees
  print('\n100 units equals:');
  print(
      '  ${lengthToDegrees(testDistance, Unit.kilometers)} degrees from kilometers');
  print('  ${lengthToDegrees(testDistance, Unit.miles)} degrees from miles');

  // Test convertLength
  print('\nLength Conversions:');
  print('  10 km = ${convertLength(10, Unit.kilometers, Unit.miles)} miles');
  print(
      '  10 miles = ${convertLength(10, Unit.miles, Unit.kilometers)} kilometers');
  print(
      '  5000 meters = ${convertLength(5000, Unit.meters, Unit.kilometers)} kilometers');

  // Test convertArea
  print('\nArea Conversions:');
  print(
      '  1 square km = ${convertArea(1, Unit.kilometers, Unit.meters)} square meters');
  print(
      '  5000 square meters = ${convertArea(5000, Unit.meters, Unit.kilometers)} square kilometers');
  print('  1 square mile = ${convertArea(1, Unit.miles, Unit.acres)} acres');
}

void testAngleConversions() {
  print('\n=== Testing Angle Conversions ===\n');

  // Test degreesToRadians
  print('Degrees to Radians:');
  print('  0° = ${degreesToRadians(0)} radians');
  print('  90° = ${degreesToRadians(90)} radians');
  print('  180° = ${degreesToRadians(180)} radians');
  print('  360° = ${degreesToRadians(360)} radians');

  // Test radiansToDegrees
  print('\nRadians to Degrees:');
  print('  0 radians = ${radiansToDegrees(0)}°');
  print('  π/2 radians = ${radiansToDegrees(pi / 2)}°');
  print('  π radians = ${radiansToDegrees(pi)}°');
  print('  2π radians = ${radiansToDegrees(2 * pi)}°');

  // Test conversions back and forth
  final testDegrees = 45.0;
  final radians = degreesToRadians(testDegrees);
  final backToDegrees = radiansToDegrees(radians);
  print('\nRoundtrip Conversion:');
  print('  $testDegrees° → $radians radians → $backToDegrees°');
}

void testBearingToAzimuth() {
  print('\n=== Testing Bearing to Azimuth Conversion ===\n');

  final bearings = [-45.0, 0.0, 45.0, 90.0, 180.0, 270.0, 360.0, 405.0];

  print('Bearing → Azimuth conversions:');
  for (final bearing in bearings) {
    final azimuth = bearingToAzimuth(bearing);
    print('  $bearing° → $azimuth°');
  }
}

void testRounding() {
  print('\n=== Testing Rounding Function ===\n');

  final numbers = [3.14159265359, 0.123456789, 42.999999, -8.54321];

  print('Rounding to different precision levels:');
  for (final num in numbers) {
    print('  Original: $num');
    print('    0 decimals: ${round(num, 0)}');
    print('    2 decimals: ${round(num, 2)}');
    print('    4 decimals: ${round(num, 4)}');
  }
}

void testCoordinateSystemConversions() {
  print('\n=== Testing Coordinate System Conversions ===\n');

  // Test locations for conversion
  final testLocations = [
    {'name': 'Null Island', 'lng': 0.0, 'lat': 0.0},
    {'name': 'New York', 'lng': -74.006, 'lat': 40.7128},
    {'name': 'Sydney', 'lng': 151.2093, 'lat': -33.8688},
    {'name': 'London', 'lng': -0.1278, 'lat': 51.5074},
  ];

  print('WGS84 (lon/lat) ⟺ Web Mercator conversions:');
  for (final location in testLocations) {
    final lng = location['lng'] as double;
    final lat = location['lat'] as double;

    final wgs84Point = Feature(
      geometry: Point(coordinates: Position(lng, lat)),
    );

    final mercatorPoint = geoToMercator(wgs84Point) as Feature<Point>;
    final roundTripPoint = geoToWgs84(mercatorPoint) as Feature<Point>;

    final mx = mercatorPoint.geometry!.coordinates.lng;
    final my = mercatorPoint.geometry!.coordinates.lat;
    final rlng = roundTripPoint.geometry!.coordinates.lng;
    final rlat = roundTripPoint.geometry!.coordinates.lat;

    print('\n  ${location['name']}:');
    print('    WGS84:        [$lng, $lat]');
    print(
        '    Mercator:     [${mx.toStringAsFixed(3)}, ${my.toStringAsFixed(3)}]');
    print(
        '    Back to WGS84:[${rlng.toStringAsFixed(8)}, ${rlat.toStringAsFixed(8)}]');

    final lonDiff = (lng - rlng.toDouble()).abs();
    final latDiff = (lat - rlat.toDouble()).abs();
    print(
        '    Roundtrip difference: [${lonDiff.toStringAsFixed(8)}°, ${latDiff.toStringAsFixed(8)}°]');
  }
}
