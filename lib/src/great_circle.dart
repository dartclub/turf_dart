import 'dart:math' as math;
import 'package:turf/turf.dart';
import 'helpers.dart';

/// Calculates the great circle route between two points on a sphere 
/// 
/// Useful link: https://en.wikipedia.org/wiki/Great-circle_distance
 
List<List<double>> greatCircle(
  dynamic start,
  dynamic end,
  { 
    Map <String, dynamic> properties = const {},
    int npoints = 100, // npoints = number of intermediate points less one (e.g if you want 5 intermediate points, set npoints = 6)
    int offset = 10
  }) {
    if (start.length != 2 || end.length != 2) {
      /// Coordinate checking 
      throw ArgumentError("Both start and end coordinates should have two values - a latitude and lnggitude");
    }

    // If start and end points are the same, 
    if (start[0] == end[0] && start[1] == end[1]) {
      return List.generate(npoints, (_) => [start[0], start[1]]);
    }
    
    
    List<List<double>> line = [];

    num lng1 = degreesToRadians(start[0]);
    num lat1 = degreesToRadians(start[1]);
    num lng2 = degreesToRadians(end[0]);
    num lat2 = degreesToRadians(end[1]);
    
    // Harvesine formula 
    for (int i = 0; i <= npoints; i++) {
    double f = i / npoints;
    double delta = 2 *
        math.asin(math.sqrt(math.pow(math.sin((lat2 - lat1) / 2), 2) +
            math.cos(lat1) * math.cos(lat2) * math.pow(math.sin((lng2 - lng1) / 2), 2)));
    double A = math.sin((1 - f) * delta) / math.sin(delta);
    double B = math.sin(f * delta) / math.sin(delta);
    double x = A * math.cos(lat1) * math.cos(lng1) + B * math.cos(lat2) * math.cos(lng2);
    double y = A * math.cos(lat1) * math.sin(lng1) + B * math.cos(lat2) * math.sin(lng2);
    double z = A * math.sin(lat1) + B * math.sin(lat2);

    double lat = math.atan2(z, math.sqrt(x * x + y * y));
    double lng = math.atan2(y, x);

    List<double> point = [radiansToDegrees(lng).toDouble().roundToDouble(), radiansToDegrees(lat).toDouble().roundToDouble()]; 
    line.add(point);
    }
    /// Check for multilinestring if path crosses anti-meridian
    bool crossAntiMeridian = (start[0] - end[0]).abs() > 180;

    /// If it crossed antimeridian, we need to split our lines
    if (crossAntiMeridian) {
      List<List<double>> multiLine = [];
      List<List<double>> currentLine = [];

      for (var point in line) {
        if ((point[0] - line[0][0]).abs() > 180) {
          multiLine.addAll(currentLine);
          currentLine = [];
        }
        currentLine.add(point);
      }
      multiLine.addAll(currentLine);
      return multiLine;
    }
    return line;
}