import 'package:test/test.dart';
import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';

main() {
  final pt = point(Position.named(lat: 102.0, lng: 0.5));
  final line = lineString([
    Position.named(lat: 102.0, lng: -10.0),
    Position.named(lat: 103.0, lng: 1.0),
    Position.named(lat: 104.0, lng: 0.0),
    Position.named(lat: 130.0, lng: 4.0),
  ]);
  final poly = polygon([
    [
      Position.named(lat: 101.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 1.0),
      Position.named(lat: 100.0, lng: 1.0),
      Position.named(lat: 100.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 0.0),
    ],
  ]);
  final multiLine = multiLineString([
    [
      Position.named(lat: 100.0, lng: 0.0),
      Position.named(lat: 101.0, lng: 1.0),
    ],
    [
      Position.named(lat: 102.0, lng: 2.0),
      Position.named(lat: 103.0, lng: 3.0),
    ],
  ]);
  final multiPoly = multiPolygon([
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
  ]);
  final fc = featureCollection(<Feature>[pt, line, poly, multiLine, multiPoly]);

  test("bbox", () {
    // FeatureCollection
    final fcBBox = bbox(fc);
    expect(fcBBox, equals([100, -10, 130, 4]), reason: "featureCollection");

    // Point
    final ptBBox = bbox(pt);
    expect(ptBBox, equals([102, 0.5, 102, 0.5]), reason: "point");

    // // Line
    final lineBBox = bbox(line);
    expect(lineBBox, equals([102, -10, 130, 4]), reason: "lineString");

    // // Polygon
    final polyExtent = bbox(poly);
    expect(polyExtent, equals([100, 0, 101, 1]), reason: "polygon");

    // // MultiLineString
    final multiLineBBox = bbox(multiLine);
    expect(multiLineBBox, equals([100, 0, 103, 3]), reason: "multiLineString");

    // // MultiPolygon
    final multiPolyBBox = bbox(multiPoly);
    expect(multiPolyBBox, equals([100, 0, 103, 3]), reason: "multiPolygon");

    final pt2 = point(pt.geometry!.coordinates, options: {'bbox': bbox(point(Position.named(lat: 0, lng: 0)))});
    expect(bbox(pt2), equals([0, 0, 0, 0]), reason: "uses built-in bbox by default");
    expect(bbox(pt2, recompute: true), [102, 0.5, 102, 0.5], reason: "recomputes bbox with recompute option");
  });
}
