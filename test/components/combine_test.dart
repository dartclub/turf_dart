import 'package:geotypes/geotypes.dart';
import 'package:test/test.dart';
import 'package:turf/src/combine.dart';

/// Shorter combine tests: empty input, skips, properties, serialization.
/// Bulk geometry: `combine_geometry_test.dart`. Flatten / order: `combine_flatten_and_order_test.dart`.
void main() {
  group('combine:', () {
    group('empty and unsupported:', () {
      test('empty collection yields empty FeatureCollection', () {
        final collection = FeatureCollection<Point>(features: []);
        final result = combine(collection);
        expect(result.features, isEmpty);
      });

      test('skips GeometryCollection features', () {
        final geomCollection = Feature(
          geometry: GeometryCollection(geometries: [
            Point(coordinates: Position.of([0, 0])),
            LineString(coordinates: [
              Position.of([0, 0]),
              Position.of([1, 1]),
            ]),
          ]),
          properties: {'name': 'geomCollection'},
        );

        final collection =
            FeatureCollection(features: [geomCollection, geomCollection]);
        final result = combine(collection);
        expect(result.features, isEmpty);
      });

      test('skips features with null geometry', () {
        final noGeom =
            Feature<Point>(geometry: null, properties: {'skip': true});
        final point = Feature(
          geometry: Point(coordinates: Position.of([1, 1])),
          properties: {'keep': true},
        );
        final result = combine(FeatureCollection(features: [noGeom, point]));
        expect(result.features.length, 1);
        final collected =
            result.features.first.properties!['collectedProperties'] as List;
        expect(collected, [
          {'keep': true}
        ]);
      });

      test('point plus unsupported yields only MultiPoint', () {
        final geomCollection = Feature(
          geometry: GeometryCollection(geometries: [
            Point(coordinates: Position.of([99, 99])),
          ]),
          properties: {'ignored': true},
        );
        final point = Feature(
          geometry: Point(coordinates: Position.of([0, 0])),
          properties: {'ok': true},
        );
        final result =
            combine(FeatureCollection(features: [geomCollection, point]));
        expect(result.features.length, 1);
        expect(result.features.first.geometry, isA<MultiPoint>());
      });
    });

    group('collectedProperties:', () {
      test('lists each source feature properties in order', () {
        final point1 = Feature(
          geometry: Point(coordinates: Position.of([0, 0])),
          properties: {'name': 'point1', 'value': 42},
        );
        final point2 = Feature(
          geometry: Point(coordinates: Position.of([1, 1])),
          properties: {'name': 'point2', 'otherValue': 'test'},
        );

        final collection = FeatureCollection(features: [point1, point2]);
        final result = combine(collection);

        final collected =
            result.features.first.properties!['collectedProperties'] as List;
        expect(collected.length, 2);
        expect(collected[0], {'name': 'point1', 'value': 42});
        expect(collected[1], {'name': 'point2', 'otherValue': 'test'});
      });

      test('includes null when feature properties are null', () {
        final a = Feature(
          geometry: Point(coordinates: Position.of([0, 0])),
          properties: null,
        );
        final b = Feature(
          geometry: Point(coordinates: Position.of([1, 1])),
          properties: {'x': 1},
        );
        final collected = combine(FeatureCollection(features: [a, b]))
            .features
            .first
            .properties!['collectedProperties'] as List;
        expect(collected.length, 2);
        expect(collected[0], isNull);
        expect(collected[1], {'x': 1});
      });
    });

    group('round-trip GeoJSON:', () {
      test('output serializes like Turf combine', () {
        final point1 = Feature(
          geometry: Point(coordinates: Position.of([0, 0])),
          properties: {'name': 'a'},
        );
        final result = combine(FeatureCollection(features: [point1]));
        final json = result.toJson();
        expect(json['type'], 'FeatureCollection');
        expect((json['features'] as List).length, 1);
        final f = (json['features'] as List).first as Map<String, dynamic>;
        expect(f['geometry']?['type'], 'MultiPoint');
        expect(f['properties']?['collectedProperties'], isA<List>());
      });
    });
  });
}
