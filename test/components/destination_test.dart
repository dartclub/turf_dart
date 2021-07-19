import 'package:test/test.dart';
import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

void main() {
  num defaultBearing = 180;
  num defaultDistance = 100;

  test('destination', () {
    var start = Position.named(
      lat: -33.4312226,
      lng: -70.5920118,
    );
    var end = Position.named(
      lat: -33.5149429,
      lng: -70.8961298,
    );
    var dist = distanceRaw(start, end);
    var bearing = bearingRaw(start, end);
    var newEnd = destinationRaw(start, dist, bearing).toSigned();

    var newDist = distanceRaw(start, newEnd);

    expect(dist.toStringAsFixed(8), newDist.toStringAsFixed(8));
    expect(end.lng!.toStringAsFixed(8), newEnd.lng!.toStringAsFixed(8));
    expect(end.lat!.toStringAsFixed(8), newEnd.lat!.toStringAsFixed(8));
  });

  test('point bearing 0', () {
    num testBearing = 0;
    var testDistance = defaultDistance;
    var testStart = Point(
      coordinates: Position.named(
        lng: -75,
        lat: 38.10096062273525,
      ),
    );
    var testEnd = Point(
      coordinates: Position.named(
        lng: -75,
        lat: 39.000281,
      ),
    );
    var actualEnd = destination(testStart, testDistance, testBearing);
    expect(actualEnd.coordinates.lat!.toStringAsFixed(6),
        equals(testEnd.coordinates.lat!.toStringAsFixed(6)),
        reason: 'Destination latitude is incorrect');
    expect(actualEnd.coordinates.lng!.toStringAsFixed(6),
        equals(testEnd.coordinates.lng!.toStringAsFixed(6)),
        reason: 'Destination longitude is incorrect');
  });

  test('point bearing 90', () {
    num testBearing = 90;
    var testDistance = defaultDistance;
    var testStart = Point(
      coordinates: Position.named(
        lng: -75,
        lat: 39,
      ),
    );
    var testEnd = Point(
      coordinates: Position.named(
        lng: -73.842853,
        lat: 38.994285,
      ),
    );
    var actualEnd = destination(testStart, testDistance, testBearing);
    expect(actualEnd.coordinates.lat!.toStringAsFixed(6),
        equals(testEnd.coordinates.lat!.toStringAsFixed(6)),
        reason: 'Destination latitude is incorrect');
    expect(actualEnd.coordinates.lng!.toStringAsFixed(6),
        equals(testEnd.coordinates.lng!.toStringAsFixed(6)),
        reason: 'Destination longitude is incorrect');
  });

  test('point bearing 180', () {
    var testBearing = defaultBearing;
    var testDistance = defaultDistance;
    var testStart = Point(
      coordinates: Position.named(
        lng: -75,
        lat: 39,
      ),
    );
    var testEnd = Point(
      coordinates: Position.named(
        lng: -75,
        lat: 38.10068,
      ),
    );
    var actualEnd = destination(testStart, testDistance, testBearing);
    expect(actualEnd.coordinates.lat!.toStringAsFixed(6),
        equals(testEnd.coordinates.lat!.toStringAsFixed(6)),
        reason: 'Destination latitude is incorrect');
    expect(actualEnd.coordinates.lng!.toStringAsFixed(6),
        equals(testEnd.coordinates.lng!.toStringAsFixed(6)),
        reason: 'Destination longitude is incorrect');
  });

  test('point 5000 km away bearing 90', () {
    num testBearing = 90;
    num testDistanceKm = 5000;
    var testStart = Point(
      coordinates: Position.named(
        lng: -75,
        lat: 39,
      ),
    );
    var testEnd = Point(
      coordinates: Position.named(
        lng: -22.885356,
        lat: 26.440011,
      ),
    );
    var actualEnd =
        destination(testStart, testDistanceKm, testBearing, Unit.kilometers);
    expect(actualEnd.coordinates.lat!.toStringAsFixed(6),
        equals(testEnd.coordinates.lat!.toStringAsFixed(6)),
        reason: 'Destination latitude is incorrect');
    expect(actualEnd.coordinates.lng!.toStringAsFixed(6),
        equals(testEnd.coordinates.lng!.toStringAsFixed(6)),
        reason: 'Destination longitude is incorrect');
  });

  test('point 5000 miles away bearing 90', () {
    num testBearing = 90;
    num testDistanceMiles = 5000;
    var testStart = Point(
      coordinates: Position.named(
        lng: -75,
        lat: 39,
      ),
    );
    var testEnd = Point(
      coordinates: Position.named(
        lng: 1.123703,
        lat: 10.990466,
      ),
    );
    var actualEnd =
        destination(testStart, testDistanceMiles, testBearing, Unit.miles);
    expect(actualEnd.coordinates.lat!.toStringAsFixed(6),
        equals(testEnd.coordinates.lat!.toStringAsFixed(6)),
        reason: 'Destination latitude is incorrect');
    expect(actualEnd.coordinates.lng!.toStringAsFixed(6),
        equals(testEnd.coordinates.lng!.toStringAsFixed(6)),
        reason: 'Destination longitude is incorrect');
  });
}
