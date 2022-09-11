import 'package:test/test.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/midpoint.dart';

void checkLatLngInRange(Point result) {
  bool _lngRange(num lng) => lng >= -180 && lng <= 180;
  bool _latRange(num lat) => lat >= -90 && lat <= 90;

  expect(_lngRange(result.coordinates.lng), true,
      reason: 'Longitude of ${result.coordinates.lng} out of range');
  expect(_latRange(result.coordinates.lat), true,
      reason: 'Latitude of ${result.coordinates.lat} out of range');
}

void main() {
  test('simple midpoint', () {
    Position result = midpointRaw(
      Position.named(
        lat: -33.4312226,
        lng: -70.5920118,
      ),
      Position.named(
        lat: -33.5149429,
        lng: -70.8961298,
      ),
    );
    checkLatLngInRange(Point(coordinates: result.toSigned()));
  });

  test('midpoint -- horizontal equator', () {
    Point pt1 = Point(
      coordinates: Position.named(
        lng: 0,
        lat: 0,
      ),
    );
    Point pt2 = Point(
      coordinates: Position.named(
        lng: 10,
        lat: 0,
      ),
    );
    Point result = midpoint(pt1, pt2);

    checkLatLngInRange(result);
    expect(distance(pt1, result).toStringAsFixed(6),
        equals(distance(pt2, result).toStringAsFixed(6)));
  });

  test('midpoint -- vertical from equator', () {
    Point pt1 = Point(
      coordinates: Position.named(
        lng: 0,
        lat: 0,
      ),
    );
    Point pt2 = Point(
      coordinates: Position.named(
        lng: 0,
        lat: 10,
      ),
    );

    Point result = midpoint(pt1, pt2);

    checkLatLngInRange(result);
    expect(distance(pt1, result).toStringAsFixed(6),
        equals(distance(pt2, result).toStringAsFixed(6)));
  });

  test('midpoint -- vertical to equator', () {
    Point pt1 = Point(
      coordinates: Position.named(
        lng: 0,
        lat: 10,
      ),
    );
    Point pt2 = Point(
      coordinates: Position.named(
        lng: 0,
        lat: 0,
      ),
    );

    Point result = midpoint(pt1, pt2);

    checkLatLngInRange(result);
    expect(distance(pt1, result).toStringAsFixed(6),
        equals(distance(pt2, result).toStringAsFixed(6)));
  });

  test('midpoint -- diagonal back over equator', () {
    Point pt1 = Point(
      coordinates: Position.named(
        lng: -1,
        lat: 10,
      ),
    );
    Point pt2 = Point(
      coordinates: Position.named(
        lng: 1,
        lat: -1,
      ),
    );

    Point result = midpoint(pt1, pt2);

    checkLatLngInRange(result);
    expect(distance(pt1, result).toStringAsFixed(6),
        equals(distance(pt2, result).toStringAsFixed(6)));
  });

  test('midpoint -- diagonal forward over equator', () {
    Position pt1 = Position.named(
      lng: -5,
      lat: -1,
    );
    Position pt2 = Position.named(
      lng: 5,
      lat: 10,
    );

    Position result = midpointRaw(pt1, pt2);

    checkLatLngInRange(Point(coordinates: result.toSigned()));
    expect(distanceRaw(pt1, result).toStringAsFixed(6),
        equals(distanceRaw(pt2, result).toStringAsFixed(6)));
  });

  test('midpoint -- long distance', () {
    Point pt1 = Point(
      coordinates: Position.named(
        lng: 22.5,
        lat: 21.94304553343818,
      ),
    );
    Point pt2 = Point(
      coordinates: Position.named(
        lng: 92.10937499999999,
        lat: 46.800059446787316,
      ),
    );

    Point result = midpoint(pt1, pt2);

    checkLatLngInRange(result);
    expect(distance(pt1, result).toStringAsFixed(6),
        equals(distance(pt2, result).toStringAsFixed(6)));
  });
}
