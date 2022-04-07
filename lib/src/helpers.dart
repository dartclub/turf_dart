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

const earthRadius = 6371008.8;

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

num round(num value, [num precision = 0]) {
  if (!(precision >= 0)) {
    throw Exception("precision must be a positive number");
  }
  num multiplier = pow(10, precision);
  num result = (value * multiplier);
  return result.round() / multiplier;
}

num radiansToLength(num radians, [Unit unit = Unit.kilometers]) {
  var factor = factors[unit];
  if (factor == null) {
    throw Exception("$unit units is invalid");
  }
  return radians * factor;
}

num lengthToRadians(num distance, [Unit unit = Unit.kilometers]) {
  num? factor = factors[unit];
  if (factor == null) {
    throw Exception("$unit units is invalid");
  }
  return distance / factor;
}

num lengthToDegrees(num distance, [Unit unit = Unit.kilometers]) {
  return radiansToDegrees(lengthToRadians(distance, unit));
}

num bearingToAzimuth(num bearing) {
  num angle = bearing.remainder(360);
  if (angle < 0) {
    angle += 360;
  }
  return angle;
}

num radiansToDegrees(num radians) {
  num degrees = radians.remainder(2 * pi);
  return degrees * 180 / pi;
}

num degreesToRadians(num degrees) {
  num radians = degrees.remainder(360);
  return radians * pi / 180;
}

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

num convertArea(num area, [originalUnit = Unit.meters, finalUnit = Unit.kilometers]) {
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
