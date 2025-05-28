import 'package:test/test.dart';
import 'package:turf/helpers.dart';

import 'package:turf/src/points_within_polygon.dart';

void main() {
  group('pointsWithinPolygon — Point', () {
    test('single point in single polygon', () {
      final poly = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(0, 0),
            Position(0, 100),
            Position(100, 100),
            Position(100, 0),
            Position(0, 0),
          ]
        ]),
      );

      final pt = Feature<Point>(
        geometry: Point(coordinates: Position(50, 50)),
      );

      final counted = pointsWithinPolygon(
        FeatureCollection<Point>(features: [pt]),
        FeatureCollection<Polygon>(features: [poly]),
      );

      expect(counted, isA<FeatureCollection>());
      expect(counted.features.length, equals(1));
    });

    test('multiple points & multiple polygons', () {
      final poly1 = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(0, 0),
            Position(10, 0),
            Position(10, 10),
            Position(0, 10),
            Position(0, 0),
          ]
        ]),
      );
      final poly2 = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(10, 0),
            Position(20, 10),
            Position(20, 20),
            Position(20, 0),
            Position(10, 0),
          ]
        ]),
      );
      final polys = FeatureCollection<Polygon>(features: [poly1, poly2]);

      final pts = FeatureCollection<Point>(features: [
        Feature<Point>(
            geometry: Point(coordinates: Position(1, 1)),
            properties: {'population': 500}),
        Feature<Point>(
            geometry: Point(coordinates: Position(1, 3)),
            properties: {'population': 400}),
        Feature<Point>(
            geometry: Point(coordinates: Position(14, 2)),
            properties: {'population': 600}),
        Feature<Point>(
            geometry: Point(coordinates: Position(13, 1)),
            properties: {'population': 500}),
        Feature<Point>(
            geometry: Point(coordinates: Position(19, 7)),
            properties: {'population': 200}),
        Feature<Point>(
            geometry: Point(coordinates: Position(100, 7)),
            properties: {'population': 200}),
      ]);

      final counted = pointsWithinPolygon(pts, polys);

      expect(counted, isA<FeatureCollection>());
      expect(counted.features.length, equals(5));
    });
  });

  group('pointsWithinPolygon — MultiPoint', () {
    test('single multipoint', () {
      final poly = FeatureCollection<Polygon>(features: [
        Feature<Polygon>(
          geometry: Polygon(coordinates: [
            [
              Position(0, 0),
              Position(0, 100),
              Position(100, 100),
              Position(100, 0),
              Position(0, 0)
            ]
          ]),
        )
      ]);

      final mptInside = Feature<MultiPoint>(
        geometry: MultiPoint(coordinates: [Position(50, 50)]),
      );
      final mptOutside = Feature<MultiPoint>(
        geometry: MultiPoint(coordinates: [Position(150, 150)]),
      );
      final mptMixed = Feature<MultiPoint>(
        geometry: MultiPoint(coordinates: [Position(50, 50), Position(150, 150)]),
      );

      // inside
      final within = pointsWithinPolygon(mptInside, poly);
      expect(within.features.length, equals(1));
      expect((within.features.first.geometry! as MultiPoint).coordinates.length, equals(1));

      // feature-collection wrapper
      final withinFC =
          pointsWithinPolygon(FeatureCollection<MultiPoint>(features: [mptInside]), poly);
      expect(withinFC.features.length, equals(1));

      // outside
      final notWithin = pointsWithinPolygon(mptOutside, poly);
      expect(notWithin.features, isEmpty);

      // mixed
      final partWithin = pointsWithinPolygon(mptMixed, poly);
      expect((partWithin.features.first.geometry! as MultiPoint).coordinates.length, equals(1));
      expect(
        (partWithin.features.first.geometry! as MultiPoint).coordinates.first,
        equals(mptMixed.geometry!.coordinates.first),
      );
    });

    test('multiple multipoints & polygons', () {
      final poly1 = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(0, 0),
            Position(0, 100),
            Position(100, 100),
            Position(100, 0),
            Position(0, 0)
          ]
        ]),
      );
      final poly2 = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(10, 0),
            Position(20, 10),
            Position(20, 20),
            Position(20, 0),
            Position(10, 0)
          ]
        ]),
      );

      final mpt1 =
          Feature<MultiPoint>(geometry: MultiPoint(coordinates: [Position(50, 50)]));
      final mpt2 =
          Feature<MultiPoint>(geometry: MultiPoint(coordinates: [Position(150, 150)]));
      final mpt3 = Feature<MultiPoint>(
        geometry: MultiPoint(coordinates: [Position(50, 50), Position(150, 150)]),
      );

      final result = pointsWithinPolygon(
        FeatureCollection<MultiPoint>(features: [mpt1, mpt2, mpt3]),
        FeatureCollection<Polygon>(features: [poly1, poly2]),
      );

      expect(result.features.length, equals(2));
    });
  });

  group('pointsWithinPolygon — mixed Point & MultiPoint', () {
    test('mixed inputs', () {
      final poly = FeatureCollection<Polygon>(features: [
        Feature<Polygon>(
          geometry: Polygon(coordinates: [
            [
              Position(0, 0),
              Position(0, 100),
              Position(100, 100),
              Position(100, 0),
              Position(0, 0)
            ]
          ]),
        )
      ]);

      final pt = Feature<Point>(geometry: Point(coordinates: Position(50, 50)));
      final mptInside =
          Feature<MultiPoint>(geometry: MultiPoint(coordinates: [Position(50, 50)]));
      final mptOutside =
          Feature<MultiPoint>(geometry: MultiPoint(coordinates: [Position(150, 150)]));

      final counted = pointsWithinPolygon(
        FeatureCollection(    // dynamic FC so we can mix types
          features: [pt, mptInside, mptOutside],
        ),
        poly,
      );

      expect(counted.features.length, equals(2));
      expect(counted.features[0].geometry, isA<Point>());
      expect(counted.features[1].geometry, isA<MultiPoint>());
    });
  });

  group('pointsWithinPolygon — extras & edge-cases', () {
    test('works with raw Geometry or single Feature inputs', () {
      final pts = FeatureCollection<Point>(features: [
        Feature<Point>(geometry: Point(coordinates: Position(-46.6318, -23.5523))),
        Feature<Point>(geometry: Point(coordinates: Position(-46.6246, -23.5325))),
        Feature<Point>(geometry: Point(coordinates: Position(-46.6062, -23.5513))),
        Feature<Point>(geometry: Point(coordinates: Position(-46.663, -23.554))),
        Feature<Point>(geometry: Point(coordinates: Position(-46.643, -23.557))),
      ]);

      final searchWithin = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(-46.653, -23.543),
            Position(-46.634, -23.5346),
            Position(-46.613, -23.543),
            Position(-46.614, -23.559),
            Position(-46.631, -23.567),
            Position(-46.653, -23.56),
            Position(-46.653, -23.543),
          ]
        ]),
      );

      expect(pointsWithinPolygon(pts, searchWithin), isNotNull);
      expect(pointsWithinPolygon(pts.features.first, searchWithin), isNotNull);
      expect(pointsWithinPolygon(pts, searchWithin.geometry!), isNotNull);
    });

    test('no duplicates when a point is inside ≥2 polygons', () {
      final poly1 = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(0, 0),
            Position(10, 0),
            Position(10, 10),
            Position(0, 10),
            Position(0, 0),
          ]
        ]),
      );
      final poly2 = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(0, 0),
            Position(10, 0),
            Position(10, 10),
            Position(0, 10),
            Position(0, 0),
          ]
        ]),
      );
      final pt = Feature<Point>(geometry: Point(coordinates: Position(5, 5)));

      final counted = pointsWithinPolygon(
        FeatureCollection<Point>(features: [pt]),
        FeatureCollection<Polygon>(features: [poly1, poly2]),
      );

      expect(counted.features.length, equals(1));
    });

    test('preserves properties on output multipoints', () {
      final poly = FeatureCollection<Polygon>(features: [
        Feature<Polygon>(
          geometry: Polygon(coordinates: [
            [
              Position(0, 0),
              Position(0, 100),
              Position(100, 100),
              Position(100, 0),
              Position(0, 0)
            ]
          ]),
        )
      ]);

      final mpt = Feature<MultiPoint>(
        geometry: MultiPoint(coordinates: [Position(50, 50), Position(150, 150)]),
        properties: {'prop': 'yes'},
      );

      final out = pointsWithinPolygon(mpt, poly);

      expect(out.features.length, equals(1));
      expect(out.features.first.properties, containsPair('prop', 'yes'));
    });
  });
}
