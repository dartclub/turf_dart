import 'package:turf/src/line_segment.dart';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';

main() {
  Feature<MultiLineString> multiline = Feature<MultiLineString>(
    geometry: MultiLineString(
      coordinates: [
        [
          Position.of([5, 5]),
          Position.of([6, 6]),
          Position.of([9, 9])
        ],
        [
          Position.of([7, 7]),
          Position.of([8, 8]),
        ],
      ],
    ),
  );

  Feature<MultiPoint> multiPoint = Feature<MultiPoint>(
      geometry: MultiPoint(
    coordinates: [
      Position.of([0, 0]),
      Position.of([1, 1]),
    ],
  ));

  MultiPoint multiPoint1 = MultiPoint(coordinates: []);

  LineString lineString = LineString(
    coordinates: [Position(1, 1), Position(2, 2), Position(3, 3)],
  );

  Feature<Polygon> poly = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position.of([0, 0]),
        Position.of([1, 1]),
        Position.of([0, 1]),
        Position.of([0, 0]),
      ],
    ]),
  );

  Feature<Polygon> poly1 = Feature<Polygon>(
    geometry: Polygon(coordinates: [
      [
        Position.of([0, 0]),
        Position.of([2, 2]),
        Position.of([0, 1]),
        Position.of([0, 0]),
      ],
      [
        Position.of([0, 0]),
        Position.of([1, 1]),
        Position.of([0, 1]),
        Position.of([0, 0]),
      ],
    ]),
  );
  Feature<GeometryCollection> geomCollection1 = Feature<GeometryCollection>(
    geometry: GeometryCollection(
      geometries: [
        multiPoint1, // should throw
        lineString,
      ],
    ),
  );
  test("lineSegment -- GeometryColletion", () {
    // Multipoint gets ignored
    expect(lineSegment(multiPoint1).features.isEmpty, true);

    // Feature<MultiPoint> passed to lineSegment produces and empty FeatureCollection<LineString>
    FeatureCollection<LineString> results = lineSegment(multiPoint);
    expect(results.features.isEmpty, true);

    // LineString with multiple coordinates passed to the lineSegment will
    // produce a FeatureCollection<LineString> with segmented LineStrings
    var lineStringResult = lineSegment(lineString);
    expect(lineStringResult.features.length, 2);
    expect(lineStringResult.features.first.geometry!.coordinates[0],
        Position(1, 1));

    // A more complex object
    var geomCollectionResult = lineSegment(geomCollection1);
    expect(geomCollectionResult.features.length, 2);

    // MultiLines
    var multiLineResults = lineSegment(multiline);
    expect(multiLineResults.features.length, 3);

    // Polygon
    var polygonResult = lineSegment(poly);
    expect(polygonResult.features.length, 3);
  });

  test("segmentEach polygon combineGeometries == true", () {
    var resultCombined = lineSegment(poly1, combineGeometries: true);
    var resultNotCombined = lineSegment(poly1);
    expect(resultCombined.features.length, 7);
    expect(resultNotCombined.features.length, 6);
    expect(resultCombined.features[3].geometry!.coordinates.first,
        Position.of([0, 0]));
    expect(resultCombined.features[3].geometry!.coordinates[1],
        Position.of([0, 0]));
    expect(resultNotCombined.features.first.id, 0);
    expect(resultNotCombined.features.last.id, 5);
    expect(resultCombined.features.last.id, 6);
    expect(resultCombined.features.first.id, 0);
  });
}
