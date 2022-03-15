import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';

main() {
  LineString line1 = LineString(coordinates: [Position(1, 2), Position(3, 4)]);
  var feature1 =
      Feature<Point>(geometry: Point(coordinates: Position(1, 2, 3)));
  test("invariant -- getCoord", () {
    expect(() => getCoord(line1), throwsA(isA<Exception>()));
    expect(() => getCoord(null), throwsA(isA<Exception>()));
    expect(() => getCoord(false), throwsA(isA<Exception>()));
    expect(getCoord(feature1.geometry), Position(1, 2, 3));
    expect(getCoord(feature1), Position(1, 2, 3));
    expect(getCoord(feature1.geometry!.coordinates), Position(1, 2, 3));
  });

  test("invariant -- getCoords", () {
    var feature2 = Feature<LineString>(geometry: line1);
    var polygon = Polygon(coordinates: [
      [
        Position(119.32, -8.7),
        Position(119.55, -8.69),
        Position(119.51, -8.54),
        Position(119.32, -8.7)
      ]
    ]);
    expect(() => getCoords(null), throwsA(isA<Exception>()));
    expect(
        getCoords([
          Position.of([119.32, -8.7]),
          Position.of([119.55, -8.69]),
          Position.of([119.51, -8.54]),
          Position.of([119.32, -8.7])
        ]),
        equals([
          Position.of([119.32, -8.7]),
          Position.of([119.55, -8.69]),
          Position.of([119.51, -8.54]),
          Position.of([119.32, -8.7])
        ]));
    expect(() => getCoords(feature1), throwsA(isA<Exception>()));
    expect(getCoords(feature2), equals([Position(1, 2), Position(3, 4)]));
    expect(
        getCoords(polygon),
        equals([
          [
            Position(119.32, -8.7),
            Position(119.55, -8.69),
            Position(119.51, -8.54),
            Position(119.32, -8.7)
          ]
        ]));
    expect(getCoords(line1), [Position(1, 2), Position(3, 4)]);
  });
}
