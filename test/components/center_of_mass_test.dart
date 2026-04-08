import 'package:turf/center_of_mass.dart';
import 'package:turf/turf.dart';
import 'package:test/test.dart';

void main() {
  // Test 1: Square centered at (0,0)
  final polygon1 = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position(1, 1),
        Position(1, -1),
        Position(-1, -1),
        Position(-1, 1),
        Position(1, 1)
      ],
    ]),
  );

  final expected1 = Position(0.0, 0.0);

  test('centerOfMass - simple polygon (0,0)', () {
    final result = centerOfMass(polygon1).geometry!.coordinates;
    expect(result.lng, closeTo(expected1.lng, 1e-9));
    expect(result.lat, closeTo(expected1.lat, 1e-9));
  });

  // Test 2: Shifted square
  final polygon2 = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position(2, 3),
        Position(3, 3),
        Position(3, 2),
        Position(2, 2),
        Position(2, 3)
      ],
    ]),
  );

  final expected2 = Position(2.5, 2.5);

  test('centerOfMass - shifted square', () {
    final result = centerOfMass(polygon2).geometry!.coordinates;
    expect(result.lng, closeTo(expected2.lng, 1e-9));
    expect(result.lat, closeTo(expected2.lat, 1e-9));
  });

  // Test 3: Triangle
  final polygon3 = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [Position(43, 21), Position(27, 13), Position(21, 41), Position(43, 21)],
    ]),
  );

  final expected3 = Position(30.333333333333332, 25.0);

  test('centerOfMass - triangle', () {
    final result = centerOfMass(polygon3).geometry!.coordinates;
    expect(result.lng, closeTo(expected3.lng, 1e-9));
    expect(result.lat, closeTo(expected3.lat, 1e-9));
  });

  // Test 4: Degenerate line polygon
  // The polygon has coords: (40,20), (39,20), (40,20)
  // The code averages the first n-1 = 2 unique vertices (excluding closing point):
  // lng = (40 + 39) / 2 = 39.5
  // lat = (20 + 20) / 2 = 20.0
  final polygon4 = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [Position(40, 20), Position(39, 20), Position(40, 20)],
    ]),
  );

  final expected4 = Position(39.5, 20.0);

  test('centerOfMass - degenerate line polygon', () {
    final result = centerOfMass(polygon4).geometry!.coordinates;
    expect(result.lng, closeTo(expected4.lng, 1e-9));
    expect(result.lat, closeTo(expected4.lat, 1e-9));
  });

  // Test 5: MultiPolygon
  // Polygon 1: square from (0,0) to (2,2) -> area = 4, center = (1, 1)
  // Polygon 2: square from (3,3) to (5,5) -> area = 4, center = (4, 4)
  // Area-weighted center: ((1*4 + 4*4) / 8, (1*4 + 4*4) / 8) = (2.5, 2.5)
  final multiPolygon = Feature<MultiPolygon>(
    geometry: MultiPolygon(coordinates: [
      [
        [
          Position(0, 0),
          Position(2, 0),
          Position(2, 2),
          Position(0, 2),
          Position(0, 0)
        ]
      ],
      [
        [
          Position(3, 3),
          Position(5, 3),
          Position(5, 5),
          Position(3, 5),
          Position(3, 3)
        ]
      ]
    ]),
  );

  final expectedMulti = Position(2.5, 2.5);

  test('centerOfMass - multipolygon', () {
    final result = centerOfMass(multiPolygon).geometry!.coordinates;
    expect(result.lng, closeTo(expectedMulti.lng, 1e-9));
    expect(result.lat, closeTo(expectedMulti.lat, 1e-9));
  });

  // Test 6: Single point
  final singlePoint = Feature<Point>(
    geometry: Point(coordinates: Position(7, 9)),
  );

  final expectedPoint = Position(7.0, 9.0);

  test('centerOfMass - single point', () {
    final result = centerOfMass(singlePoint).geometry!.coordinates;
    expect(result.lng, closeTo(expectedPoint.lng, 1e-9));
    expect(result.lat, closeTo(expectedPoint.lat, 1e-9));
  });

  // Test 7: LineString
  final line = Feature<LineString>(
    geometry: LineString(coordinates: [Position(0, 0), Position(4, 0)]),
  );

  final expectedLine = Position(2.0, 0.0);

  test('centerOfMass - single line', () {
    final result = centerOfMass(line).geometry!.coordinates;
    expect(result.lng, closeTo(expectedLine.lng, 1e-9));
    expect(result.lat, closeTo(expectedLine.lat, 1e-9));
  });
}
