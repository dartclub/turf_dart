import 'dart:convert';

import 'package:geotypes/geotypes.dart';
import 'package:test/test.dart';
import 'package:turf/src/combine.dart';

void main() {
  group('combine:', () {
    // Geometry-based tests
    group('geometry transformations:', () {
      test('combines multiple points to a MultiPoint', () {
        final point1 = Feature(
          geometry: Point(coordinates: Position.of([0, 0])),
          properties: {'name': 'point1'},
        );
        final point2 = Feature(
          geometry: Point(coordinates: Position.of([1, 1])),
          properties: {'name': 'point2'},
        );
        final point3 = Feature(
          geometry: Point(coordinates: Position.of([2, 2, 10])), // With altitude
          properties: {'name': 'point3'},
        );

        final collection = FeatureCollection(features: [point1, point2, point3]);
        final result = combine(collection);

        expect(result.geometry, isA<MultiPoint>());
        expect((result.geometry as MultiPoint).coordinates.length, 3);
        // Check altitude preservation
        expect((result.geometry as MultiPoint).coordinates[2].length, 3);
        expect((result.geometry as MultiPoint).coordinates[2][2], 10);
      });

      test('combines multiple linestrings to a MultiLineString', () {
        final line1 = Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 0]),
            Position.of([1, 1]),
          ]),
          properties: {'name': 'line1'},
        );
        final line2 = Feature(
          geometry: LineString(coordinates: [
            Position.of([2, 2]),
            Position.of([3, 3]),
          ]),
          properties: {'name': 'line2'},
        );
        final line3 = Feature(
          geometry: LineString(coordinates: [
            Position.of([4, 4, 10]), // With altitude
            Position.of([5, 5, 15]), // With altitude
          ]),
          properties: {'name': 'line3'},
        );

        final collection = FeatureCollection(features: [line1, line2, line3]);
        final result = combine(collection);

        expect(result.geometry, isA<MultiLineString>());
        expect((result.geometry as MultiLineString).coordinates.length, 3);
        // Check altitude preservation
        expect((result.geometry as MultiLineString).coordinates[2][0].length, 3);
        expect((result.geometry as MultiLineString).coordinates[2][0][2], 10);
        expect((result.geometry as MultiLineString).coordinates[2][1][2], 15);
      });

      test('combines multiple polygons to a MultiPolygon', () {
        final poly1 = Feature(
          geometry: Polygon(coordinates: [
            [
              Position.of([0, 0]),
              Position.of([1, 0]),
              Position.of([1, 1]),
              Position.of([0, 1]),
              Position.of([0, 0]),
            ]
          ]),
          properties: {'name': 'poly1'},
        );
        final poly2 = Feature(
          geometry: Polygon(coordinates: [
            [
              Position.of([2, 2]),
              Position.of([3, 2]),
              Position.of([3, 3]),
              Position.of([2, 3]),
              Position.of([2, 2]),
            ]
          ]),
          properties: {'name': 'poly2'},
        );
        final poly3 = Feature(
          geometry: Polygon(coordinates: [
            [
              Position.of([4, 4, 10]), // With altitude
              Position.of([5, 4, 10]),
              Position.of([5, 5, 10]),
              Position.of([4, 5, 10]),
              Position.of([4, 4, 10]),
            ]
          ]),
          properties: {'name': 'poly3'},
        );

        final collection = FeatureCollection(features: [poly1, poly2, poly3]);
        final result = combine(collection);

        expect(result.geometry, isA<MultiPolygon>());
        expect((result.geometry as MultiPolygon).coordinates.length, 3);
        // Check altitude preservation
        expect((result.geometry as MultiPolygon).coordinates[2][0][0].length, 3);
        expect((result.geometry as MultiPolygon).coordinates[2][0][0][2], 10);
      });

      test('preserves negative or high-altitude z-values', () {
        // Test for extreme altitude values (negative and high)
        final point1 = Feature(
          geometry: Point(coordinates: Position.of([0, 0, -9999.5])), // Deep negative altitude
          properties: {'name': 'deep_point'},
        );
        final point2 = Feature(
          geometry: Point(coordinates: Position.of([1, 1, 9999.5])), // High positive altitude
          properties: {'name': 'high_point'},
        );

        final collection = FeatureCollection(features: [point1, point2]);
        final result = combine(collection);

        expect(result.geometry, isA<MultiPoint>());
        expect((result.geometry as MultiPoint).coordinates.length, 2);
        
        // Check extreme altitude preservation
        expect((result.geometry as MultiPoint).coordinates[0].length, 3);
        expect((result.geometry as MultiPoint).coordinates[0][2], -9999.5);
        expect((result.geometry as MultiPoint).coordinates[1].length, 3);
        expect((result.geometry as MultiPoint).coordinates[1][2], 9999.5);
      });
    });

    // Error tests
    group('validation and errors:', () {
      test('throws error on mixed geometry types', () {
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
        expect(() => combine(collection), throwsA(isA<ArgumentError>()));
      });

      test('throws error on empty collection', () {
        final collection = FeatureCollection<Point>(features: []);
        expect(() => combine(collection), throwsA(isA<ArgumentError>()));
      });

      test('throws error on unsupported geometry types (validation test)', () {
        // This is a validation test - GeometryCollection is not claimed to be
        // supported by combine(), which only works with Point, LineString, and Polygon.
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

        final collection = FeatureCollection(features: [geomCollection, geomCollection]);
        expect(() => combine(collection), throwsA(isA<ArgumentError>()));
      });
    });

    // Property handling tests
    group('property handling:', () {
      test('has empty properties by default', () {
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

        // By default, properties should be empty
        expect(result.properties, isEmpty);
      });

      test('preserves properties from first feature when mergeProperties=true', () {
        final point1 = Feature(
          geometry: Point(coordinates: Position.of([0, 0])),
          properties: {'name': 'point1', 'value': 42},
        );
        final point2 = Feature(
          geometry: Point(coordinates: Position.of([1, 1])),
          properties: {'name': 'point2', 'otherValue': 'test'},
        );

        final collection = FeatureCollection(features: [point1, point2]);
        final result = combine(collection, mergeProperties: true);

        // When mergeProperties is true, copies properties from first feature only
        expect(result.properties!['name'], 'point1');
        expect(result.properties!['value'], 42);
        expect(result.properties!.containsKey('otherValue'), isFalse);
      });
    });

    // GeoJSON otherMembers tests
    group('GeoJSON compliance:', () {
      test('preserves otherMembers in output', () {
        // Create a source feature with otherMembers by parsing from JSON
        final jsonStr = '''{
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [0, 0]
          },
          "properties": {"name": "point1"},
          "customField": "custom value",
          "metaData": {"source": "test"}
        }''';

        final sourceFeature = Feature<Point>.fromJson(jsonDecode(jsonStr));
        
        // Create a feature collection with this feature
        final collection = FeatureCollection(features: [sourceFeature]);
        
        // Combine (which should use the same feature as the source for the result)
        final result = combine(collection, mergeProperties: true);
        
        // Convert to JSON and check for preservation of otherMembers
        final resultJson = result.toJson();
        
        // Verify the otherMembers exist in the result
        expect(resultJson.containsKey('customField'), isTrue);
        expect(resultJson['customField'], 'custom value');
        expect(resultJson.containsKey('metaData'), isTrue);
        expect(resultJson['metaData']?['source'], 'test');
      });
    });
  });
}
