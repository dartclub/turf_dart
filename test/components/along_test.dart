import 'package:test/test.dart';
import 'package:turf/along.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/length.dart';

void main() {
  test('along - negative distance along', () {
    final resolvedStartPoint = along(line, -100, Unit.meters);
    expect(resolvedStartPoint, isNotNull);
    expect(resolvedStartPoint!.coordinates, equals(start));
  });
  test('along - to start point', () {
    final resolvedStartPoint = along(line, 0, Unit.meters);
    expect(resolvedStartPoint, isNotNull);
    expect(resolvedStartPoint!.coordinates, equals(start));
  });
  test('along - to point between start and via', () {
    final startToViaDistance = distance(
        Point(coordinates: start), Point(coordinates: via), Unit.meters);
    expect(startToViaDistance, isNotNull);
    expect(startToViaDistance.round(), equals(57));
    final resolvedViaPoint = along(line, startToViaDistance / 2, Unit.meters);
    expect(resolvedViaPoint, isNotNull);
    expect(resolvedViaPoint!.coordinates.lat.toStringAsFixed(6), equals('55.709028'));
    expect(resolvedViaPoint.coordinates.lng.toStringAsFixed(6), equals('13.185096'));
  });
  test('along - to via point', () {
    final startToViaDistance = distance(
        Point(coordinates: start), Point(coordinates: via), Unit.meters);
    expect(startToViaDistance, isNotNull);
    expect(startToViaDistance.round(), equals(57));
    final resolvedViaPoint = along(line, startToViaDistance, Unit.meters);
    expect(resolvedViaPoint, isNotNull);
    expect(resolvedViaPoint!.coordinates, equals(via));
  });
  test('along - to point between via and end', () {
    final startToViaDistance = distance(
        Point(coordinates: start), Point(coordinates: via), Unit.meters);
    final viaToEndDistance = distance(
        Point(coordinates: via), Point(coordinates: end), Unit.meters);
    expect(startToViaDistance, isNotNull);
    expect(startToViaDistance.round(), equals(57));
    expect(viaToEndDistance, isNotNull);
    expect(viaToEndDistance.round(), equals(198));
    final resolvedViaPoint = along(line, startToViaDistance + viaToEndDistance / 2, Unit.meters);
    expect(resolvedViaPoint, isNotNull);
    expect(resolvedViaPoint!.coordinates.lat.toStringAsFixed(6), equals('55.708330'));
    expect(resolvedViaPoint.coordinates.lng.toStringAsFixed(6), equals('13.186555'));
  });
  test('along - to end point', () {
    final len = length(line, Unit.meters);
    expect(len, isNotNull);
    expect(len!.round(), equals(254));
    final resolvedEndPoint = along(line, len, Unit.meters);
    expect(resolvedEndPoint, isNotNull);
    expect(resolvedEndPoint!.coordinates, equals(end));
  });
  test('along - beyond end point', () {
    final len = length(line, Unit.meters);
    expect(len, isNotNull);
    expect(len!.round(), equals(254));
    final resolvedEndPoint = along(line, len + 100, Unit.meters);
    expect(resolvedEndPoint, isNotNull);
    expect(resolvedEndPoint!.coordinates, equals(end));
  });
}

final start = Position.named(
  lat: 55.7090430186194,
  lng: 13.184645393920405,
);
final via = Position.named(
  lat: 55.70901279569489,
  lng: 13.185546616182755,
);
final end = Position.named(
  lat: 55.70764669578079,
  lng: 13.187563637197076,
);
final line = LineString(
  coordinates: [
    start,
    via,
    end,
  ],
);
