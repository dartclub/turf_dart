import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/polygon_clipping/geom_in.dart';

void main() {
  group('RingIn', () {
    test('create exterior ring', () {
      final List<Position> ringGeomIn = [
        Position(0, 0),
        Position(1, 0),
        Position(1, 1),
      ];
      final Position expectedPt1 = Position(0, 0);
      final Position expectedPt2 = Position(1, 0);
      final Position expectedPt3 = Position(1, 1);
      final PolyIn poly = PolyIn(
        Polygon(coordinates: [ringGeomIn]),
        null,
      );
      final ring = RingIn(
        ringGeomIn,
        poly: poly,
        isExterior: true,
      );
      poly.exteriorRing = ring;

      expect(ring.poly, equals(poly), reason: "ring.poly self reference");
      expect(ring.isExterior, isTrue, reason: "ring.isExterior");
      expect(ring.segments.length, equals(3), reason: "ring.segments.length");
      expect(ring.getSweepEvents().length, equals(6),
          reason: "ring.getSweepEvents().length");

      expect(ring.segments[0].leftSE.point, equals(expectedPt1),
          reason: "ring.segments[0].leftSE.point");
      expect(ring.segments[0].rightSE.point, equals(expectedPt2),
          reason: "ring.segments[0].rightSE.point");
      expect(ring.segments[1].leftSE.point, equals(expectedPt2),
          reason: "ring.segments[1].leftSE.point");
      expect(ring.segments[1].rightSE.point, equals(expectedPt3),
          reason: "ring.segments[1].rightSE.point");
      expect(ring.segments[2].leftSE.point, equals(expectedPt1),
          reason: "ring.segments[2].leftSE.point");
      expect(ring.segments[2].rightSE.point, equals(expectedPt3),
          reason: "ring.segments[2].rightSE.point");
    });

    test('create an interior ring', () {
      final ring = RingIn(
        [
          Position(0, 0),
          Position(1, 1),
          Position(1, 0),
        ],
        isExterior: false,
      );
      expect(ring.isExterior, isFalse);
    });

    test('bounding box construction', () {
      final ring = RingIn([
        Position(0, 0),
        Position(1, 1),
        Position(0, 1),
        Position(0, 0),
      ], isExterior: true);

      expect(ring.bbox.position1, equals(Position(0, 0)));
      expect(ring.bbox.position2, equals(Position(1, 1)));
    });
  });

  group('PolyIn', () {
    test('creation', () {
      final MultiPolyIn multiPoly = MultiPolyIn(
        MultiPolygon(coordinates: [
          [
            [
              Position(0, 0),
              Position(10, 0),
              Position(10, 10),
              Position(0, 10),
            ],
            [
              Position(0, 0),
              Position(1, 1),
              Position(1, 0),
            ],
            [
              Position(2, 2),
              Position(2, 3),
              Position(3, 3),
              Position(3, 2),
            ]
          ],
          [
            [
              Position(0, 0),
              Position(1, 1),
              Position(0, 1),
              Position(0, 0),
            ],
            [
              Position(0, 0),
              Position(4, 0),
              Position(4, 9),
            ],
            [
              Position(2, 2),
              Position(3, 3),
              Position(3, 2),
            ]
          ]
        ]),
        false,
      );

      final poly = PolyIn(
          Polygon(
            coordinates: [
              [
                Position(0, 0),
                Position(10, 0),
                Position(10, 10),
                Position(0, 10),
              ],
              [
                Position(0, 0),
                Position(1, 1),
                Position(1, 0),
              ],
              [
                Position(2, 2),
                Position(2, 3),
                Position(3, 3),
                Position(3, 2),
              ],
            ],
          ),
          multiPoly);

      expect(poly.multiPoly, equals(multiPoly));
      expect(poly.exteriorRing.segments.length, equals(4));
      expect(poly.interiorRings.length, equals(2));
      expect(poly.interiorRings[0].segments.length, equals(3));
      expect(poly.interiorRings[1].segments.length, equals(4));
      expect(poly.getSweepEvents().length, equals(22));
    });
    test('bbox construction', () {
      final multiPoly = MultiPolyIn(
        MultiPolygon(coordinates: [
          [
            [
              Position(0, 0),
              Position(1, 1),
              Position(0, 1),
            ],
          ],
          [
            [
              Position(0, 0),
              Position(4, 0),
              Position(4, 9),
            ],
            [
              Position(2, 2),
              Position(3, 3),
              Position(3, 2),
            ],
          ],
        ]),
        false,
      );

      final poly = PolyIn(
        Polygon(
          coordinates: [
            [
              Position(0, 0),
              Position(10, 0),
              Position(10, 10),
              Position(0, 10),
            ],
            [
              Position(0, 0),
              Position(1, 1),
              Position(1, 0),
            ],
            [
              Position(2, 2),
              Position(2, 3),
              Position(3, 11),
              Position(3, 2),
            ],
          ],
        ),
        multiPoly,
      );

      expect(poly.bbox.position1, equals(Position(0, 0)));
      expect(poly.bbox.position2, equals(Position(10, 11)));
    });
  });

  group('MultiPolyIn', () {
    test('creation with multipoly', () {
      final multipoly = MultiPolyIn(
        MultiPolygon(coordinates: [
          [
            [
              Position(0, 0),
              Position(1, 1),
              Position(0, 1),
            ],
          ],
          [
            [
              Position(0, 0),
              Position(4, 0),
              Position(4, 9),
            ],
            [
              Position(2, 2),
              Position(3, 3),
              Position(3, 2),
            ],
          ],
        ]),
        true,
      );

      expect(multipoly.polys.length, equals(2),
          reason: "multipoly.polys.length");
      expect(multipoly.getSweepEvents().length, equals(18),
          reason: "multipoly.getSweepEvents().length");
    });

    test('creation with poly', () {
      final multipoly = MultiPolyIn(
        MultiPolygon(coordinates: [
          [
            [
              Position(0, 0),
              Position(1, 1),
              Position(0, 1),
              Position(0, 0),
            ],
          ],
        ]),
        true,
      );

      expect(multipoly.polys.length, equals(1),
          reason: "multipoly.polys.length");
      expect(multipoly.getSweepEvents().length, equals(6),
          reason: "multipoly.getSweepEvents().length");
    });

    ///Clipper lib does not support elevation because it's creating new points at intersections and can not assume the elevation at those generated points.
    test('third or more coordinates are ignored', () {
      final multipoly = MultiPolyIn(
        MultiPolygon(coordinates: [
          [
            [
              Position(0, 0, 42),
              Position(1, 1, 128),
              Position(0, 1, 84),
              Position(0, 0, 42),
            ],
          ],
        ]),
        true,
      );

      expect(multipoly.polys.length, equals(1),
          reason: "multipoly.polys.length");
      expect(multipoly.getSweepEvents().length, equals(6),
          reason: "multipoly.getSweepEvents().length");
    });
  });
}
