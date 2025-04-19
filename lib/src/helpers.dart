import 'dart:math';
import 'package:geotypes/geotypes.dart';

enum Unit {
  meters,
  millimeters,
  centimeters,
  kilometers,
  acres,
  miles,
  nauticalmiles,
  inches,
  yards,
  feet,
  radians,
  degrees,
}

enum Grid {
  point,
  square,
  hex,
  triangle,
}

enum Corner {
  nw,
  ne,
  se,
  sw,
  center,
  centroid,
}

/// Whether to calculate the distance based on geodesic (spheroid) or
/// planar (flat) method.
enum DistanceGeometry {
  /// Calculations will be made on a 2D plane, NOT taking into account the
  /// earth curvature.
  planar,

  /// Calculate the distance with geodesic (spheroid) equations. It will take
  /// into account the earth as a sphere.
  geodesic,
}

/// Earth Radius used with the Harvesine formula and approximates using a spherical (non-ellipsoid) Earth.
const earthRadius = 6371008.8;

/// Maximum extent of the Web Mercator projection in meters
const double mercatorLimit = 20037508.34;

/// Earth radius in meters used for coordinate system conversions
const double conversionEarthRadius = 6378137.0;

/// Coordinate reference systems for spatial data
enum CoordinateSystem {
  /// WGS84 geographic coordinates (longitude/latitude)
  wgs84,
  
  /// Web Mercator projection (EPSG:3857)
  mercator,
}

/// Coordinate system conversion constants
const coordSystemConstants = {
  'mercatorLimit': mercatorLimit,
  'earthRadius': conversionEarthRadius,
};

/// Unit of measurement factors using a spherical (non-ellipsoid) earth radius.
/// Keys are the name of the unit, values are the number of that unit in a single radian
const factors = <Unit, num>{
  Unit.centimeters: earthRadius * 100,
  Unit.degrees: earthRadius / 111325,
  Unit.feet: earthRadius * 3.28084,
  Unit.inches: earthRadius * 39.3701,
  Unit.kilometers: earthRadius / 1000,
  Unit.meters: earthRadius,
  Unit.miles: earthRadius / 1609.344,
  Unit.millimeters: earthRadius * 1000,
  Unit.nauticalmiles: earthRadius / 1852,
  Unit.radians: 1,
  Unit.yards: earthRadius * 1.0936,
};

const unitsFactors = <Unit, num>{
  Unit.centimeters: 100,
  Unit.degrees: 1 / 111325,
  Unit.feet: 3.28084,
  Unit.inches: 39.370,
  Unit.kilometers: 1 / 1000,
  Unit.meters: 1,
  Unit.miles: 1 / 1609.344,
  Unit.millimeters: 1000,
  Unit.nauticalmiles: 1 / 1852,
  Unit.radians: 1 / earthRadius,
  Unit.yards: 1 / 1.0936,
};

/// Area of measurement factors based on 1 square meter.
const areaFactors = <Unit, num>{
  Unit.acres: 0.000247105,
  Unit.centimeters: 10000,
  Unit.feet: 10.763910417,
  Unit.inches: 1550.003100006,
  Unit.kilometers: 0.000001,
  Unit.meters: 1,
  Unit.miles: 3.86e-7,
  Unit.millimeters: 1000000,
  Unit.yards: 1.195990046,
};

/// Round number to precision
num round(num value, [num precision = 0]) {
  if (!(precision >= 0)) {
    throw Exception("precision must be a positive number");
  }
  num multiplier = pow(10, precision);
  num result = (value * multiplier);
  return result.round() / multiplier;
}

/// Convert a distance measurement (assuming a spherical Earth) from radians to a more friendly unit.
/// Valid units: [Unit.miles], [Unit.nauticalmiles], [Unit.inches], [Unit.yards], [Unit.meters], 
/// [Unit.kilometers], [Unit.centimeters], [Unit.feet]
num radiansToLength(num radians, [Unit unit = Unit.kilometers]) {
  final factor = factors[unit];
  if (factor == null) {
    throw Exception("$unit units is invalid");
  }
  return radians * factor;
}

/// Convert a distance measurement (assuming a spherical Earth) from a real-world unit into radians
/// Valid units: [Unit.miles], [Unit.nauticalmiles], [Unit.inches], [Unit.yards], [Unit.meters], 
/// [Unit.kilometers], [Unit.centimeters], [Unit.feet]
num lengthToRadians(num distance, [Unit unit = Unit.kilometers]) {
  num? factor = factors[unit];
  if (factor == null) {
    throw Exception("$unit units is invalid");
  }
  return distance / factor;
}

/// Convert a distance measurement (assuming a spherical Earth) from a real-world unit into degrees
/// Valid units: [Unit.miles], [Unit.nauticalmiles], [Unit.inches], [Unit.yards], [Unit.meters], 
/// [Unit.centimeters], [Unit.kilometers], [Unit.feet]
num lengthToDegrees(num distance, [Unit unit = Unit.kilometers]) {
  return radiansToDegrees(lengthToRadians(distance, unit));
}

/// Converts any bearing angle from the north line direction (positive clockwise)
/// and returns an angle between 0-360 degrees (positive clockwise), 0 being the north line
num bearingToAzimuth(num bearing) {
  num angle = bearing.remainder(360);
  if (angle < 0) {
    angle += 360;
  }
  return angle;
}

/// Converts an angle in radians to degrees
num radiansToDegrees(num radians) {
  num degrees = radians.remainder(2 * pi);
  return degrees * 180 / pi;
}

/// Converts an angle in degrees to radians
num degreesToRadians(num degrees) {
  num radians = degrees.remainder(360);
  return radians * pi / 180;
}

/// Converts a length to the requested unit.
/// Valid units: [Unit.miles], [Unit.nauticalmiles], [Unit.inches], [Unit.yards], [Unit.meters], 
/// [Unit.kilometers], [Unit.centimeters], [Unit.feet]
num convertLength(
  num length, [
  Unit originalUnit = Unit.kilometers,
  Unit finalUnit = Unit.kilometers,
]) {
  if (length < 0) {
    throw Exception("length must be a positive number");
  }
  return radiansToLength(lengthToRadians(length, originalUnit), finalUnit);
}

/// Converts a area to the requested unit.
/// Valid units: [Unit.kilometers], [Unit.meters], [Unit.centimeters], [Unit.millimeters], [Unit.acres], 
/// [Unit.miles], [Unit.yards], [Unit.feet], [Unit.inches]
num convertArea(num area,
    [originalUnit = Unit.meters, finalUnit = Unit.kilometers]) {
  if (area < 0) {
    throw Exception("area must be a positive number");
  }

  num? startFactor = areaFactors[originalUnit];
  if (startFactor == null) {
    throw Exception("invalid original units");
  }

  num? finalFactor = areaFactors[finalUnit];
  if (finalFactor == null) {
    throw Exception("invalid final units");
  }

  return (area / startFactor) * finalFactor;
}


/// Converts coordinates from one system to another.
///
/// Valid systems: [CoordinateSystem.wgs84], [CoordinateSystem.mercator]
/// Returns: [Position] in the target system
Position convertCoordinates(
  Position coord, 
  CoordinateSystem fromSystem, 
  CoordinateSystem toSystem
) {
  if (fromSystem == toSystem) {
    return coord;
  }
  
  if (fromSystem == CoordinateSystem.wgs84 && toSystem == CoordinateSystem.mercator) {
    return toMercator(coord);
  } else if (fromSystem == CoordinateSystem.mercator && toSystem == CoordinateSystem.wgs84) {
    return toWGS84(coord);
  } else {
    throw ArgumentError("Unsupported coordinate system conversion from ${fromSystem.runtimeType} to ${toSystem.runtimeType}");
  }
}

/// Converts a WGS84 coordinate to Web Mercator.
///
/// Valid inputs: [Position] with [longitude, latitude]
/// Returns: [Position] with [x, y] coordinates in meters
Position toMercator(Position coord) {
  // Use the earth radius constant for consistency
  
  // Clamp latitude to avoid infinite values near the poles
  final longitude = coord[0]?.toDouble() ?? 0.0;
  final latitude = max(min(coord[1]?.toDouble() ?? 0.0, 89.99), -89.99);
  
  // Convert longitude to x coordinate
  final x = longitude * (conversionEarthRadius * pi / 180.0);
  
  // Convert latitude to y coordinate
  final latRad = latitude * (pi / 180.0);
  final y = log(tan((pi / 4) + (latRad / 2))) * conversionEarthRadius;
  
  // Clamp to valid Mercator bounds
  final clampedX = max(min(x, mercatorLimit), -mercatorLimit);
  final clampedY = max(min(y, mercatorLimit), -mercatorLimit);
  
  // Preserve altitude if present
  final alt = coord.length > 2 ? coord[2] : null;
  
  return Position.of(alt != null ? [clampedX, clampedY, alt] : [clampedX, clampedY]);
}

/// Converts a Web Mercator coordinate to WGS84.
///
/// Valid inputs: [Position] with [x, y] in meters
/// Returns: [Position] with [longitude, latitude] coordinates
Position toWGS84(Position coord) {
  // Use the earth radius constant for consistency
  
  // Clamp inputs to valid range
  final x = max(min(coord[0]?.toDouble() ?? 0.0, mercatorLimit), -mercatorLimit);
  final y = max(min(coord[1]?.toDouble() ?? 0.0, mercatorLimit), -mercatorLimit);
  
  // Convert x to longitude
  final longitude = x / (conversionEarthRadius * pi / 180.0);
  
  // Convert y to latitude
  final latRad = 2 * atan(exp(y / conversionEarthRadius)) - (pi / 2);
  final latitude = latRad * (180.0 / pi);
  
  // Clamp latitude to valid range
  final clampedLatitude = max(min(latitude, 90.0), -90.0);
  
  // Preserve altitude if present
  final alt = coord.length > 2 ? coord[2] : null;
  
  return Position.of(alt != null ? [longitude, clampedLatitude, alt] : [longitude, clampedLatitude]);
}
