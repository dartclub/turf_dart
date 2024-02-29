import 'dart:math';

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

/// Earth Radius used with the Harvesine formula and approximates using a spherical (non-ellipsoid) Earth.
const earthRadius = 6371008.8;

/// Unit of measurement factors using a spherical (non-ellipsoid) earth radius.
/// Keys are the name of the unit, values are the number of that unit in a single radian
const factors = <Unit, num>{
  Unit.centimeters: earthRadius * 100,
  Unit.degrees: earthRadius / 111325,
  Unit.feet: earthRadius * 3.28084,
  Unit.inches: earthRadius * 39.370,
  Unit.kilometers: earthRadius / 1000,
  Unit.meters: earthRadius,
  Unit.miles: earthRadius / 1609.344,
  Unit.millimeters: earthRadius * 1000,
  Unit.nauticalmiles: earthRadius / 1852,
  Unit.radians: 1,
  Unit.yards: earthRadius / 1.0936,
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

const double epsilon =
    2.220446049250313e-16; // Equivalent to Number.EPSILON in JavaScript

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
/// Valid units: miles, nauticalmiles, inches, yards, meters, metres, kilometers, centimeters, feet
num radiansToLength(num radians, [Unit unit = Unit.kilometers]) {
  var factor = factors[unit];
  if (factor == null) {
    throw Exception("$unit units is invalid");
  }
  return radians * factor;
}

/// Convert a distance measurement (assuming a spherical Earth) from a real-world unit into radians
/// Valid units: miles, nauticalmiles, inches, yards, meters, metres, kilometers, centimeters, feet
num lengthToRadians(num distance, [Unit unit = Unit.kilometers]) {
  num? factor = factors[unit];
  if (factor == null) {
    throw Exception("$unit units is invalid");
  }
  return distance / factor;
}

/// Convert a distance measurement (assuming a spherical Earth) from a real-world unit into degrees
/// Valid units: miles, nauticalmiles, inches, yards, meters, metres, centimeters, kilometres, feet
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
/// Valid units: miles, nauticalmiles, inches, yards, meters, metres, kilometers, centimeters, feet
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
/// Valid units: kilometers, kilometres, meters, metres, centimetres, millimeters, acres, miles, yards, feet, inches, hectares
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

/// Calculate the orientation of three points (a, b, c) in 2D space.
///
/// Parameters:
///   ax (double): X-coordinate of point a.
///   ay (double): Y-coordinate of point a.
///   bx (double): X-coordinate of point b.
///   by (double): Y-coordinate of point b.
///   cx (double): X-coordinate of point c.
///   cy (double): Y-coordinate of point c.
///
/// Returns:
///   double: The orientation value:
///     - Negative if points a, b, c are in counterclockwise order.
///     - Possitive if points a, b, c are in clockwise order.
///     - Zero if points a, b, c are collinear.
///
/// Note:
///   The orientation of three points is determined by the sign of the cross product
///   (bx - ax) * (cy - ay) - (by - ay) * (cx - ax). This value is twice the signed
///   area of the triangle formed by the points (a, b, c). The sign indicates the
///   direction of the rotation formed by the points.
double orient2d(
    double ax, double ay, double bx, double by, double cx, double cy) {
  return (by - ay) * (cx - bx) - (cy - by) * (bx - ax);
}
