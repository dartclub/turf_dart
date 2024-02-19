import 'package:test/test.dart';
import 'package:turf/bbox.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/polygon_clipping/utils.dart';

void main() {
  final pt = Feature<Point>(
      geometry: Point(coordinates: Position.named(lat: 102.0, lng: 0.5)));
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
  final fc =
      FeatureCollection(features: [pt, line, poly, multiLine, multiPoly]);

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
      bbox: bbox(Feature<Point>(
          geometry: Point(coordinates: Position.named(lat: 0, lng: 0)))),
    );
    expect(bbox(pt2), equals([0, 0, 0, 0]),
        reason: "uses built-in bbox by default");
    expect(bbox(pt2, recompute: true), [0.5, 102, 0.5, 102],
        reason: "recomputes bbox with recompute option");
  });

  group('is in bbox', () {
    test('outside', () {
      final bbox = BBox.fromPositions(Position(1, 2), Position(5, 6));
      expect(isInBbox(bbox, Position(0, 3)), isFalse);
      expect(isInBbox(bbox, Position(3, 30)), isFalse);
      expect(isInBbox(bbox, Position(3, -30)), isFalse);
      expect(isInBbox(bbox, Position(9, 3)), isFalse);
    });

    test('inside', () {
      final bbox = BBox.fromPositions(Position(1, 2), Position(5, 6));
      expect(isInBbox(bbox, Position(1, 2)), isTrue);
      expect(isInBbox(bbox, Position(5, 6)), isTrue);
      expect(isInBbox(bbox, Position(1, 6)), isTrue);
      expect(isInBbox(bbox, Position(5, 2)), isTrue);
      expect(isInBbox(bbox, Position(3, 4)), isTrue);
    });

    test('barely inside & outside', () {
      final bbox = BBox.fromPositions(Position(1, 0.8), Position(1.2, 6));
      expect(isInBbox(bbox, Position(1.2 - epsilon, 6)), isTrue);
      expect(isInBbox(bbox, Position(1.2 + epsilon, 6)), isFalse);
      expect(isInBbox(bbox, Position(1, 0.8 + epsilon)), isTrue);
      expect(isInBbox(bbox, Position(1, 0.8 - epsilon)), isFalse);
    });
  });

  group('bbox overlap', () {
    final b1 = BBox.fromPositions(Position(4, 4), Position(6, 6));

    group('disjoint - none', () {
      test('above', () {
        final b2 = BBox.fromPositions(Position(7, 7), Position(8, 8));
        expect(getBboxOverlap(b1, b2), isNull);
      });

      test('left', () {
        final b2 = BBox.fromPositions(Position(1, 5), Position(3, 8));
        expect(getBboxOverlap(b1, b2), isNull);
      });

      test('down', () {
        final b2 = BBox.fromPositions(Position(2, 2), Position(3, 3));
        expect(getBboxOverlap(b1, b2), isNull);
      });

      test('right', () {
        final b2 = BBox.fromPositions(Position(12, 1), Position(14, 9));
        expect(getBboxOverlap(b1, b2), isNull);
      });
    });

    group('touching - one point', () {
      test('upper right corner of 1', () {
        final b2 = BBox.fromPositions(Position(6, 6), Position(7, 8));
        expect(getBboxOverlap(b1, b2),
            equals(BBox.fromPositions(Position(6, 6), Position(6, 6))));
      });

      test('upper left corner of 1', () {
        final b2 = BBox.fromPositions(Position(3, 6), Position(4, 8));
        expect(getBboxOverlap(b1, b2),
            equals(BBox.fromPositions(Position(4, 6), Position(4, 6))));
      });

      test('lower left corner of 1', () {
        final b2 = BBox.fromPositions(Position(0, 0), Position(4, 4));
        expect(getBboxOverlap(b1, b2),
            equals(BBox.fromPositions(Position(4, 4), Position(4, 4))));
      });

      test('lower right corner of 1', () {
        final b2 = BBox.fromPositions(Position(6, 0), Position(12, 4));
        expect(getBboxOverlap(b1, b2),
            equals(BBox.fromPositions(Position(6, 4), Position(6, 4))));
      });
    });

    group('overlapping - two points', () {
      group('full overlap', () {
        test('matching bboxes', () {
          expect(getBboxOverlap(b1, b1), equals(b1));
        });

        test('one side & two corners matching', () {
          final b2 = BBox.fromPositions(Position(4, 4), Position(5, 6));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(4, 4), Position(5, 6))));
        });

        test('one corner matching, part of two sides', () {
          final b2 = BBox.fromPositions(Position(5, 4), Position(6, 5));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(5, 4), Position(6, 5))));
        });

        test('part of a side matching, no corners', () {
          final b2 = BBox.fromPositions(Position(4.5, 4.5), Position(5.5, 6));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(4.5, 4.5), Position(5.5, 6))));
        });

        test('completely enclosed - no side or corner matching', () {
          final b2 = BBox.fromPositions(Position(4.5, 5), Position(5.5, 5.5));
          expect(getBboxOverlap(b1, b2), equals(b2));
        });
      });

      group('partial overlap', () {
        test('full side overlap', () {
          final b2 = BBox.fromPositions(Position(3, 4), Position(5, 6));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(4, 4), Position(5, 6))));
        });

        test('partial side overlap', () {
          final b2 = BBox.fromPositions(Position(5, 4.5), Position(7, 5.5));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(5, 4.5), Position(6, 5.5))));
        });

        test('corner overlap', () {
          final b2 = BBox.fromPositions(Position(5, 5), Position(7, 7));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(5, 5), Position(6, 6))));
        });
      });
    });

    group('line bboxes', () {
      group('vertical line & normal', () {
        test('no overlap', () {
          final b2 = BBox.fromPositions(Position(7, 3), Position(7, 6));
          expect(getBboxOverlap(b1, b2), isNull);
        });

        test('point overlap', () {
          final b2 = BBox.fromPositions(Position(6, 0), Position(6, 4));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(6, 4), Position(6, 4))));
        });

        test('line overlap', () {
          final b2 = BBox.fromPositions(Position(5, 0), Position(5, 9));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(5, 4), Position(5, 6))));
        });
      });

      group('horizontal line & normal', () {
        test('no overlap', () {
          final b2 = BBox.fromPositions(Position(3, 7), Position(6, 7));
          expect(getBboxOverlap(b1, b2), isNull);
        });

        test('point overlap', () {
          final b2 = BBox.fromPositions(Position(1, 6), Position(4, 6));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(4, 6), Position(4, 6))));
        });

        test('line overlap', () {
          final b2 = BBox.fromPositions(Position(4, 6), Position(6, 6));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(4, 6), Position(6, 6))));
        });
      });

      group('two vertical lines', () {
        final v1 = BBox.fromPositions(Position(4, 4), Position(4, 6));

        test('no overlap', () {
          final v2 = BBox.fromPositions(Position(4, 7), Position(4, 8));
          expect(getBboxOverlap(v1, v2), isNull);
        });

        test('point overlap', () {
          final v2 = BBox.fromPositions(Position(4, 3), Position(4, 4));
          expect(getBboxOverlap(v1, v2),
              equals(BBox.fromPositions(Position(4, 4), Position(4, 4))));
        });

        test('line overlap', () {
          final v2 = BBox.fromPositions(Position(4, 3), Position(4, 5));
          expect(getBboxOverlap(v1, v2),
              equals(BBox.fromPositions(Position(4, 4), Position(4, 5))));
        });
      });

      group('two horizontal lines', () {
        final h1 = BBox.fromPositions(Position(4, 6), Position(7, 6));

        test('no overlap', () {
          final h2 = BBox.fromPositions(Position(4, 5), Position(7, 5));
          expect(getBboxOverlap(h1, h2), isNull);
        });

        test('point overlap', () {
          final h2 = BBox.fromPositions(Position(7, 6), Position(8, 6));
          expect(getBboxOverlap(h1, h2),
              equals(BBox.fromPositions(Position(7, 6), Position(7, 6))));
        });

        test('line overlap', () {
          final h2 = BBox.fromPositions(Position(4, 6), Position(7, 6));
          expect(getBboxOverlap(h1, h2),
              equals(BBox.fromPositions(Position(4, 6), Position(7, 6))));
        });
      });

      group('horizonal and vertical lines', () {
        test('no overlap', () {
          final h1 = BBox.fromPositions(Position(4, 6), Position(8, 6));
          final v1 = BBox.fromPositions(Position(5, 7), Position(5, 9));
          expect(getBboxOverlap(h1, v1), isNull);
        });

        test('point overlap', () {
          final h1 = BBox.fromPositions(Position(4, 6), Position(8, 6));
          final v1 = BBox.fromPositions(Position(5, 5), Position(5, 9));
          expect(getBboxOverlap(h1, v1),
              equals(BBox.fromPositions(Position(5, 6), Position(5, 6))));
        });
      });

      group('produced line box', () {
        test('horizontal', () {
          final b2 = BBox.fromPositions(Position(4, 6), Position(8, 8));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(4, 6), Position(6, 6))));
        });

        test('vertical', () {
          final b2 = BBox.fromPositions(Position(6, 2), Position(8, 8));
          expect(getBboxOverlap(b1, b2),
              equals(BBox.fromPositions(Position(6, 4), Position(6, 6))));
        });
      });
    });

    group('point bboxes', () {
      group('point & normal', () {
        test('no overlap', () {
          final p = BBox.fromPositions(Position(2, 2), Position(2, 2));
          expect(getBboxOverlap(b1, p), isNull);
        });
        test('point overlap', () {
          final p = BBox.fromPositions(Position(5, 5), Position(5, 5));
          expect(getBboxOverlap(b1, p), equals(p));
        });
      });

      group('point & line', () {
        test('no overlap', () {
          final p = BBox.fromPositions(Position(2, 2), Position(2, 2));
          final l = BBox.fromPositions(Position(4, 6), Position(4, 8));
          expect(getBboxOverlap(l, p), isNull);
        });
        test('point overlap', () {
          final p = BBox.fromPositions(Position(5, 5), Position(5, 5));
          final l = BBox.fromPositions(Position(4, 5), Position(6, 5));
          expect(getBboxOverlap(l, p), equals(p));
        });
      });

      group('point & point', () {
        test('no overlap', () {
          final p1 = BBox.fromPositions(Position(2, 2), Position(2, 2));
          final p2 = BBox.fromPositions(Position(4, 6), Position(4, 6));
          expect(getBboxOverlap(p1, p2), isNull);
        });
        test('point overlap', () {
          final p = BBox.fromPositions(Position(5, 5), Position(5, 5));
          expect(getBboxOverlap(p, p), equals(p));
        });
      });
    });
  });
}
