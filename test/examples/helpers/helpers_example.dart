import 'dart:math';
import 'package:turf/turf.dart';

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
  
  // Example 1: Convert distances from one unit to another
  print('Distance Conversions:');
  print('  10 kilometers = ${convertLength(10, Unit.kilometers, Unit.miles).toStringAsFixed(2)} miles');
  print('  26.2 miles = ${convertLength(26.2, Unit.miles, Unit.kilometers).toStringAsFixed(2)} kilometers');
  print('  100 meters = ${convertLength(100, Unit.meters, Unit.feet).toStringAsFixed(2)} feet');
  print('  1 nautical mile = ${convertLength(1, Unit.nauticalmiles, Unit.kilometers).toStringAsFixed(2)} kilometers');
  
  // Example 2: Convert from radians to real-world units
  print('\nRadians to Length:');
  final oneRadian = 1.0;
  print('  1 radian = ${radiansToLength(oneRadian, Unit.kilometers).toStringAsFixed(2)} kilometers');
  print('  1 radian = ${radiansToLength(oneRadian, Unit.miles).toStringAsFixed(2)} miles');
  print('  1 radian = ${radiansToLength(oneRadian, Unit.meters).toStringAsFixed(2)} meters');
  
  // Example 3: Convert from real-world units to radians
  print('\nLength to Radians:');
  print('  100 kilometers = ${lengthToRadians(100, Unit.kilometers).toStringAsFixed(6)} radians');
  print('  100 miles = ${lengthToRadians(100, Unit.miles).toStringAsFixed(6)} radians');
  
  // Example 4: Convert from real-world units to degrees
  print('\nLength to Degrees:');
  print('  100 kilometers = ${lengthToDegrees(100, Unit.kilometers).toStringAsFixed(2)} degrees');
  print('  100 miles = ${lengthToDegrees(100, Unit.miles).toStringAsFixed(2)} degrees');
  
  // Example 5: Convert areas from one unit to another
  print('\nArea Conversions:');
  print('  1 square kilometer = ${convertArea(1, Unit.kilometers, Unit.meters).toStringAsFixed(0)} square meters');
  print('  1 square mile = ${convertArea(1, Unit.miles, Unit.acres).toStringAsFixed(2)} acres');
  print('  10000 square meters = ${convertArea(10000, Unit.meters, Unit.kilometers).toStringAsFixed(2)} square kilometers');
  print('  5 acres = ${convertArea(5, Unit.acres, Unit.meters).toStringAsFixed(0)} square meters');
}

void angleConversionExamples() {
  print('\n=== Angle Conversion Examples ===\n');
  
  // Example 1: Convert degrees to radians
  print('Degrees to Radians:');
  print('  0° = ${degreesToRadians(0).toStringAsFixed(6)} radians');
  print('  90° = ${degreesToRadians(90).toStringAsFixed(6)} radians');
  print('  180° = ${degreesToRadians(180).toStringAsFixed(6)} radians');
  print('  360° = ${degreesToRadians(360).toStringAsFixed(6)} radians');
  
  // Example 2: Convert radians to degrees
  print('\nRadians to Degrees:');
  print('  0 radians = ${radiansToDegrees(0).toStringAsFixed(2)}°');
  print('  π/2 radians = ${radiansToDegrees(pi/2).toStringAsFixed(2)}°');
  print('  π radians = ${radiansToDegrees(pi).toStringAsFixed(2)}°');
  print('  2π radians = ${radiansToDegrees(2*pi).toStringAsFixed(2)}°');
}

void bearingToAzimuthExamples() {
  print('\n=== Bearing to Azimuth Examples ===\n');
  print('The bearingToAzimuth function converts any bearing angle to a standard azimuth:');
  print('- Azimuth is the angle between 0° and 360° in clockwise direction from north');
  print('- Negative bearings are converted to their positive equivalent');
  
  // Converting various bearings to azimuth
  final bearings = [-45.0, 0.0, 90.0, 180.0, 270.0, 360.0, 395.0, -170.0];
  
  print('\nBearing → Azimuth conversions:');
  for (final bearing in bearings) {
    final azimuth = bearingToAzimuth(bearing);
    print('  $bearing° → $azimuth°');
  }
}

void roundingExamples() {
  print('\n=== Rounding Function Examples ===\n');
  
  // The round function allows precise control over number rounding
  final numbers = [3.14159265359, 0.123456789, 42.999999, -8.54321];
  
  print('Rounding to different precision levels:');
  for (final num in numbers) {
    print('\nOriginal: $num');
    print('  0 decimals: ${round(num, 0)}');
    print('  2 decimals: ${round(num, 2)}');
    print('  4 decimals: ${round(num, 4)}');
    print('  6 decimals: ${round(num, 6)}');
  }
  
  // Practical usage examples
  print('\nPractical usage examples:');
  
  // Example 1: Rounding coordinates for display
  final coordinate = [151.2093, -33.8688]; // Sydney coordinates
  print('  Original coordinate: ${coordinate[0]}, ${coordinate[1]}');
  print('  Rounded coordinate: ${round(coordinate[0], 4)}, ${round(coordinate[1], 4)}');
  
  // Example 2: Rounding distances for human-readable output
  final distance = 1234.5678;
  print('  Original distance: $distance meters');
  print('  Rounded distance: ${round(distance, 0)} meters');
  
  // Example 3: Rounding angles
  final angle = 42.87654321;
  print('  Original angle: $angle degrees');
  print('  Rounded angle: ${round(angle, 1)} degrees');
}

void coordinateSystemConversionExamples() {
  print('\n=== Coordinate System Conversion Examples ===\n');
  print('The turf_dart library provides functions to convert between WGS84 (lon/lat) and');
  print('Web Mercator (EPSG:3857) coordinate systems.');
  
  // Example 1: Convert specific locations
  print('\nConverting well-known locations:');
  
  // Define some well-known locations
  final locations = [
    {'name': 'New York City', 'wgs84': [-74.006, 40.7128]},
    {'name': 'Sydney', 'wgs84': [151.2093, -33.8688]},
    {'name': 'Tokyo', 'wgs84': [139.6917, 35.6895]},
    {'name': 'London', 'wgs84': [-0.1278, 51.5074]}
  ];
  
  for (final location in locations) {
    final wgs84 = location['wgs84'] as List<double>;
    final mercator = toMercator(wgs84);
    
    print('\n  ${location['name']}:');
    print('  • WGS84 (lon/lat): [${wgs84[0]}, ${wgs84[1]}]');
    print('  • Mercator (x,y): [${round(mercator[0], 2)}, ${round(mercator[1], 2)}]');
  }
  
  // Example 2: Round-trip conversion demonstration
  print('\nRound-trip conversion demonstration:');
  
  final sydney = [151.2093, -33.8688];
  print('\n  Original WGS84: $sydney');
  
  // Convert to Web Mercator
  final mercator = toMercator(sydney);
  print('  → Web Mercator: [${round(mercator[0], 2)}, ${round(mercator[1], 2)}]');
  
  // Convert back to WGS84
  final backToWgs84 = toWGS84(mercator);
  print('  → Back to WGS84: [${round(backToWgs84[0], 6)}, ${round(backToWgs84[1], 6)}]');
  
  // Show precision loss
  final lonDiff = (sydney[0] - backToWgs84[0]).abs();
  final latDiff = (sydney[1] - backToWgs84[1]).abs();
  print('  Difference: [${lonDiff.toStringAsFixed(10)}°, ${latDiff.toStringAsFixed(10)}°]');

  // Example 3: Using the unified convertCoordinates function
  print('\nUsing convertCoordinates function:');
  
  final london = [-0.1278, 51.5074];
  print('  Original WGS84: $london');
  
  // Convert to Mercator using the convertCoordinates function
  final londonMercator = convertCoordinates(
    london, 
    CoordinateSystem.wgs84, 
    CoordinateSystem.mercator
  );
  print('  → Web Mercator: [${round(londonMercator[0], 2)}, ${round(londonMercator[1], 2)}]');
  
  // Convert back to WGS84
  final londonBackToWgs84 = convertCoordinates(
    londonMercator, 
    CoordinateSystem.mercator, 
    CoordinateSystem.wgs84
  );
  print('  → Back to WGS84: [${round(londonBackToWgs84[0], 6)}, ${round(londonBackToWgs84[1], 6)}]');
  
  // Example 4: Useful applications of coordinate conversions
  print('\nPractical uses of coordinate conversions:');
  print('  • Web mapping: Converting between geographic (WGS84) and projection coordinates (Mercator)');
  print('  • Distance calculations: Mercator is useful for small areas where distance preservation is important');
  print('  • Visual representation: Web Mercator is the standard for most web mapping applications');
}
