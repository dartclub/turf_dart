import 'package:test/test.dart';
import 'package:turf/along.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/length.dart';
import 'package:turf/src/line_slice.dart';

void main() {
  test('lineSlice - exact points', () {
    final slice = lineSlice(startFeature, viaFeature, lineFeature);
    expect(slice, isNotNull);
    expect(slice.properties, isNotNull);
    expect(slice.properties!.keys, contains(propName));
    expect(slice.properties![propName], equals(propValue));

    final expectedLineFeature = Feature<LineString>(
      geometry: LineString(coordinates: [start, via]),
    );
    expect(slice.geometry, isNotNull);
    expect(slice.geometry!.coordinates, hasLength(2));
    expect(length(slice).round(), equals(length(expectedLineFeature).round()));
  });
  test('lineSlice - interpolation', () {
    const skipDist = 10;

    final sliceFrom = along(lineFeature, skipDist, Unit.meters);
    expect(sliceFrom, isNotNull);

    final slice = lineSlice(sliceFrom, viaFeature, lineFeature);
    expect(slice, isNotNull);
    expect(slice.properties, isNotNull);
    expect(slice.properties!.keys, contains(propName));
    expect(slice.properties![propName], equals(propValue));

    final expectedLine = Feature<LineString>(
      geometry: LineString(coordinates: [start, via]),
    );
    expect(slice.geometry, isNotNull);
    expect(slice.geometry!.coordinates, hasLength(2));
    expect(
      length(slice, Unit.meters).round(),
      equals(length(expectedLine, Unit.meters).round() - skipDist),
    );

    // Sanity check of test data. No interpolation occurs if start and via are skipDist apart.
    expect(distance(Point(coordinates: start), Point(coordinates: via)).round(),
        isNot(equals(skipDist)));
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
const propName = 'prop1';
const propValue = 1;
final lineFeature = Feature<LineString>(
  geometry: LineString(
    coordinates: [
      start,
      via,
      end,
    ],
  ),
  properties: {
    propName: propValue,
  },
);
final startFeature = Feature<Point>(geometry: Point(coordinates: start));
final viaFeature = Feature<Point>(geometry: Point(coordinates: via));
