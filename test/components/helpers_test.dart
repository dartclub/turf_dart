import 'dart:math';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';

void main() {
  test('radiansToLength', () {
    expect(radiansToLength(1, Unit.radians), equals(1));
    expect(radiansToLength(1, Unit.kilometers), equals(earthRadius / 1000));
    expect(radiansToLength(1, Unit.miles), equals(earthRadius / 1609.344));
  });

  test('lengthToRadians', () {
    expect(lengthToRadians(1, Unit.radians), equals(1));
    expect(lengthToRadians(earthRadius / 1000, Unit.kilometers), equals(1));
    expect(lengthToRadians(earthRadius / 1609.344, Unit.miles), equals(1));
  });

  test('lengthToDegrees', () {
    expect(lengthToDegrees(1, Unit.radians), equals(57.29577951308232));
    expect(lengthToDegrees(100, Unit.kilometers), equals(0.899320363724538));
    expect(lengthToDegrees(10, Unit.miles), equals(0.1447315831437903));
  });

  test('radiansToDegrees', () {
    expect(round(radiansToDegrees(pi / 3), 6), equals(60),
        reason: 'radiance conversion pi/3');
    expect(radiansToDegrees(3.5 * pi), equals(270),
        reason: 'radiance conversion 3.5pi');
    expect(radiansToDegrees(-pi), equals(-180),
        reason: 'radiance conversion -pi');
  });

  test('radiansToDegrees', () {
    expect(degreesToRadians(60), equals(pi / 3),
        reason: 'degrees conversion 60');
    expect(degreesToRadians(270), equals(1.5 * pi),
        reason: 'degrees conversion 270');
    expect(degreesToRadians(-180), equals(-pi),
        reason: 'degrees conversion -180');
  });

  test('bearingToAzimuth', () {
    expect(bearingToAzimuth(40), equals(40));
    expect(bearingToAzimuth(-105), equals(255));
    expect(bearingToAzimuth(410), equals(50));
    expect(bearingToAzimuth(-200), equals(160));
    expect(bearingToAzimuth(-395), equals(325));
  });

  test('round', () {
    expect(round(125.123), equals(125));
    expect(round(123.123, 1), equals(123.1));
    expect(round(123.5), equals(124));

    expect(() => round(34.5, -5), throwsA(isException));
  });

  test('convertLength', () {
    expect(convertLength(1000, Unit.meters), equals(1));
    expect(convertLength(1, Unit.kilometers, Unit.miles),
        equals(0.621371192237334));
    expect(convertLength(1, Unit.miles, Unit.kilometers), equals(1.609344));
    expect(convertLength(1, Unit.nauticalmiles), equals(1.852));
    expect(convertLength(1, Unit.meters, Unit.centimeters),
        equals(100.00000000000001));
  });

  test('convertArea', () {
    expect(convertArea(1000), equals(0.001));
    expect(convertArea(1, Unit.kilometers, Unit.miles), equals(0.386));
    expect(convertArea(1, Unit.miles, Unit.kilometers),
        equals(2.5906735751295336));
    expect(convertArea(1, Unit.meters, Unit.centimeters), equals(10000));
    expect(convertArea(100, Unit.meters, Unit.acres), equals(0.0247105));
    expect(
        convertArea(100, Unit.meters, Unit.yards), equals(119.59900459999999));
    expect(convertArea(100, Unit.meters, Unit.feet), equals(1076.3910417));
    expect(convertArea(100000, Unit.feet), equals(0.009290303999749462));
  });
}
