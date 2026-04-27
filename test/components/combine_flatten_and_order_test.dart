import 'package:geotypes/geotypes.dart';
import 'package:test/test.dart';
import 'package:turf/src/combine.dart';

void main() {
  group('combine: flatten Multi* with simple geometries:', () {
    test('flattens MultiPoint into combined MultiPoint', () {
      final mp = Feature(
        geometry: MultiPoint(
          coordinates: [
            Position.of([0, 0]),
            Position.of([1, 1]),
          ],
        ),
        properties: {'k': 'mp'},
      );
      final pt = Feature(
        geometry: Point(coordinates: Position.of([2, 2])),
        properties: {'k': 'p'},
      );
      final result = combine(FeatureCollection(features: [mp, pt]));
      final coords = (result.features.first.geometry as MultiPoint).coordinates;
      expect(coords.length, 3);
      final collected =
          result.features.first.properties!['collectedProperties'] as List;
      expect(collected.length, 2);
    });

    test('flattens MultiLineString into combined MultiLineString', () {
      final mls = Feature(
        geometry: MultiLineString(
          coordinates: [
            [
              Position.of([0, 0]),
              Position.of([1, 1])
            ],
            [
              Position.of([2, 2]),
              Position.of([3, 3])
            ],
          ],
        ),
        properties: {'id': 'mls'},
      );
      final ls = Feature(
        geometry: LineString(coordinates: [
          Position.of([4, 4]),
          Position.of([5, 5]),
        ]),
        properties: {'id': 'ls'},
      );
      final result = combine(FeatureCollection(features: [mls, ls]));
      final lines =
          (result.features.first.geometry as MultiLineString).coordinates;
      expect(lines.length, 3);
      final collected =
          result.features.first.properties!['collectedProperties'] as List;
      expect(collected.length, 2);
    });

    test('flattens MultiPolygon into combined MultiPolygon', () {
      final ring = [
        Position.of([0, 0]),
        Position.of([1, 0]),
        Position.of([1, 1]),
        Position.of([0, 1]),
        Position.of([0, 0]),
      ];
      final mpoly = Feature(
        geometry: MultiPolygon(
          coordinates: [
            [List<Position>.from(ring)],
          ],
        ),
        properties: {'id': 'mp'},
      );
      final poly = Feature(
        geometry: Polygon(
          coordinates: [
            ring.map((p) => Position(p.lng + 2, p.lat + 2)).toList(),
          ],
        ),
        properties: {'id': 'p'},
      );
      final result = combine(FeatureCollection(features: [mpoly, poly]));
      final polys =
          (result.features.first.geometry as MultiPolygon).coordinates;
      expect(polys.length, 2);
    });
  });

  group('combine: mixed types and ordering (Turf JS):', () {
    test('returns separate Multi* features, sorted by geometry name', () {
      final point = Feature(
        geometry: Point(coordinates: Position.of([0, 0])),
        properties: {'name': 'point'},
      );
      final line = Feature(
        geometry: LineString(coordinates: [
          Position.of([0, 0]),
          Position.of([1, 1]),
        ]),
        properties: {'name': 'line'},
      );

      final collection = FeatureCollection(features: [point, line]);
      final result = combine(collection);

      expect(result.features.length, 2);
      expect(result.features[0].geometry, isA<MultiLineString>());
      expect(result.features[1].geometry, isA<MultiPoint>());
    });

    test(
        'orders MultiLineString, MultiPoint, MultiPolygon regardless of input order',
        () {
      final point = Feature(
        geometry: Point(coordinates: Position.of([0, 0])),
        properties: {},
      );
      final poly = Feature(
        geometry: Polygon(
          coordinates: [
            [
              Position.of([0, 0]),
              Position.of([1, 0]),
              Position.of([1, 1]),
              Position.of([0, 1]),
              Position.of([0, 0]),
            ],
          ],
        ),
        properties: {},
      );
      final line = Feature(
        geometry: LineString(coordinates: [
          Position.of([0, 0]),
          Position.of([1, 1]),
        ]),
        properties: {},
      );
      final result = combine(FeatureCollection(features: [poly, point, line]));
      expect(result.features.length, 3);
      expect(result.features[0].geometry, isA<MultiLineString>());
      expect(result.features[1].geometry, isA<MultiPoint>());
      expect(result.features[2].geometry, isA<MultiPolygon>());
    });
  });
}
