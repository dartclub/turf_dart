import 'package:test/test.dart';
import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';

main() {
  final pt = Feature<Point>(geometry: Point(coordinates: Position.named(lat: 102.0, lng: 0.5)));
  final line = Feature<LineString>(
      geometry: LineString(coordinates: [
    Position.named(lat: 102.0, lng: -10.0),
    Position.named(lat: 103.0, lng: 1.0),
    Position.named(lat: 104.0, lng: 0.0),
    Position.named(lat: 130.0, lng: 4.0),
  ]));
  final poly = Feature<Polygon>(
      geometry: Polygon(coordinates: [
    [
      Position.named(lat: 101.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 1.0),
      Position.named(lat: 100.0, lng: 1.0),
      Position.named(lat: 100.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 0.0),
    ],
  ]));
  final multiLine = Feature<MultiLineString>(
      geometry: MultiLineString(coordinates: [
    [
      Position.named(lat: 100.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 1.0),
    ],
    [
      Position.named(lat: 102.0, lng: 2.0),
      Position.named(lat: 103.0, lng: 3.0),
    ],
  ]));
  final multiPoly = Feature<MultiPolygon>(
      geometry: MultiPolygon(coordinates: [
    [
      [
        Position.named(lat: 102.0, lng: 2.0),
        Position.named(lat: 103.0, lng: 2.0),
        Position.named(lat: 103.0, lng: 3.0),
        Position.named(lat: 102.0, lng: 3.0),
        Position.named(lat: 102.0, lng: 2.0),
      ],
    ],
    [
      [
        Position.named(lat: 100.0, lng: 0.0),
        Position.named(lat: 101.0, lng: 0.0),
        Position.named(lat: 101.0, lng: 1.0),
        Position.named(lat: 100.0, lng: 1.0),
        Position.named(lat: 100.0, lng: 0.0),
      ],
      [
        Position.named(lat: 100.2, lng: 0.2),
        Position.named(lat: 100.8, lng: 0.2),
        Position.named(lat: 100.8, lng: 0.8),
        Position.named(lat: 100.2, lng: 0.8),
        Position.named(lat: 100.2, lng: 0.2),
      ],
    ],
  ]));
  final fc = FeatureCollection(features: [pt, line, poly, multiLine, multiPoly]);

  test("bbox", () {
    // FeatureCollection
    final fcBBox = bbox(fc);
    expect(fcBBox, equals([-10, 100, 4, 130]), reason: "featureCollection");

    // Point
    final ptBBox = bbox(pt);
    expect(ptBBox, equals([0.5, 102, 0.5, 102]), reason: "point");

    // // Line
    final lineBBox = bbox(line);
    expect(lineBBox, equals([-10, 102, 4, 130]), reason: "lineString");

    // // Polygon
    final polyExtent = bbox(poly);
    expect(polyExtent, equals([0, 100, 1, 101]), reason: "polygon");

    // // MultiLineString
    final multiLineBBox = bbox(multiLine);
    expect(multiLineBBox, equals([0, 100, 3, 103]), reason: "multiLineString");

    // // MultiPolygon
    final multiPolyBBox = bbox(multiPoly);
    expect(multiPolyBBox, equals([0, 100, 3, 103]), reason: "multiPolygon");

    final pt2 = Feature<Point>(
      geometry: Point(coordinates: Position.named(lat: 102.0, lng: 0.5)),
      bbox: bbox(Feature<Point>(geometry: Point(coordinates: Position.named(lat: 0, lng: 0)))),
    );
    expect(bbox(pt2), equals([0, 0, 0, 0]), reason: "uses built-in bbox by default");
    expect(bbox(pt2, recompute: true), [0.5, 102, 0.5, 102], reason: "recomputes bbox with recompute option");
  });
}
