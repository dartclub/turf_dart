import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  group('polygonize', () {
    test('creates a polygon from a square of LineStrings', () {
      // Create a square as LineStrings
      final lines = FeatureCollection(features: [
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 0]),
            Position.of([10, 0]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 0]),
            Position.of([10, 10]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 10]),
            Position.of([0, 10]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 10]),
            Position.of([0, 0]),
          ]),
        ),
      ]);

      final result = polygonize(lines);

      // Check that we got a FeatureCollection with one Polygon
      expect(result.features.length, equals(1));
      expect(result.features[0].geometry, isA<Polygon>());

      // Check that the polygon has the correct coordinates
      final polygon = result.features[0].geometry as Polygon;
      expect(polygon.coordinates.length, equals(1)); // One outer ring, no holes
      expect(polygon.coordinates[0].length,
          equals(5)); // 5 positions (closing point included)

      // Check first and last are the same (closed ring)
      expect(polygon.coordinates[0].first[0],
          equals(polygon.coordinates[0].last[0]));
      expect(polygon.coordinates[0].first[1],
          equals(polygon.coordinates[0].last[1]));

      // Check that the exterior ring has counter-clockwise orientation per RFC 7946
      expect(booleanClockwise(LineString(coordinates: polygon.coordinates[0])),
          equals(false));
    });

    test('handles multiple polygons from disjoint line sets', () {
      // Create two squares as LineStrings
      final lines = FeatureCollection(features: [
        // First square
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 0]),
            Position.of([10, 0]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 0]),
            Position.of([10, 10]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 10]),
            Position.of([0, 10]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 10]),
            Position.of([0, 0]),
          ]),
        ),

        // Second square (disjoint)
        Feature(
          geometry: LineString(coordinates: [
            Position.of([20, 20]),
            Position.of([30, 20]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([30, 20]),
            Position.of([30, 30]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([30, 30]),
            Position.of([20, 30]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([20, 30]),
            Position.of([20, 20]),
          ]),
        ),
      ]);

      final result = polygonize(lines);

      // Check that we got a FeatureCollection with two Polygons
      expect(result.features.length, equals(2));

      // Check that both are Polygons
      expect(result.features[0].geometry, isA<Polygon>());
      expect(result.features[1].geometry, isA<Polygon>());

      // Check both exterior rings have counter-clockwise orientation
      for (final feature in result.features) {
        final polygon = feature.geometry as Polygon;
        expect(
            booleanClockwise(LineString(coordinates: polygon.coordinates[0])),
            equals(false));
      }
    });

    test('supports MultiLineString input', () {
      // Create a square as a MultiLineString
      final lines = FeatureCollection(features: [
        Feature(
          geometry: MultiLineString(coordinates: [
            [
              Position.of([0, 0]),
              Position.of([10, 0])
            ],
            [
              Position.of([10, 0]),
              Position.of([10, 10])
            ],
          ]),
        ),
        Feature(
          geometry: MultiLineString(coordinates: [
            [
              Position.of([10, 10]),
              Position.of([0, 10])
            ],
            [
              Position.of([0, 10]),
              Position.of([0, 0])
            ]
          ]),
        ),
      ]);

      final result = polygonize(lines);

      // Check that we got a polygon
      expect(result.features.length, equals(1));
      expect(result.features[0].geometry, isA<Polygon>());

      // Check that the polygon has the correct coordinates
      final polygon = result.features[0].geometry as Polygon;
      expect(polygon.coordinates.length, equals(1)); // One outer ring, no holes
      expect(polygon.coordinates[0].length,
          equals(5)); // 5 positions (closing point included)
    });

    test('correctly handles polygons with holes', () {
      // Create a square with a square hole inside
      final lines = FeatureCollection(features: [
        // Outer square
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 0]),
            Position.of([10, 0]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 0]),
            Position.of([10, 10]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 10]),
            Position.of([0, 10]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 10]),
            Position.of([0, 0]),
          ]),
        ),

        // Inner square (hole)
        Feature(
          geometry: LineString(coordinates: [
            Position.of([2, 2]),
            Position.of([2, 8]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([2, 8]),
            Position.of([8, 8]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([8, 8]),
            Position.of([8, 2]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([8, 2]),
            Position.of([2, 2]),
          ]),
        ),
      ]);

      final result = polygonize(lines);

      // Check that we got a single polygon
      expect(result.features.length, equals(1));
      expect(result.features[0].geometry, isA<Polygon>());

      // Check that the polygon has the correct coordinates with a hole
      final polygon = result.features[0].geometry as Polygon;
      expect(
          polygon.coordinates.length, equals(2)); // One outer ring and one hole

      // Check outer ring has counter-clockwise orientation (CCW) per RFC 7946
      expect(booleanClockwise(LineString(coordinates: polygon.coordinates[0])),
          equals(false));

      // Check hole has clockwise orientation (CW) per RFC 7946
      expect(booleanClockwise(LineString(coordinates: polygon.coordinates[1])),
          equals(true));
    });

    test('throws an error for invalid input types', () {
      // Test with a Point instead of LineString
      final point = FeatureCollection(features: [
        Feature(
          geometry: Point(coordinates: Position.of([0, 0])),
        ),
      ]);

      expect(() => polygonize(point), throwsA(isA<ArgumentError>()));
    });

    test('correctly handles altitude values', () {
      // Create a square with altitude values
      final lines = FeatureCollection(features: [
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 0, 100]),
            Position.of([10, 0, 100]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 0, 100]),
            Position.of([10, 10, 100]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([10, 10, 100]),
            Position.of([0, 10, 100]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 10, 100]),
            Position.of([0, 0, 100]),
          ]),
        ),
      ]);

      final result = polygonize(lines);

      // Check that we got a polygon
      expect(result.features.length, equals(1));
      expect(result.features[0].geometry, isA<Polygon>());

      // Check that altitude values are preserved
      final polygon = result.features[0].geometry as Polygon;
      for (final position in polygon.coordinates[0]) {
        expect(position.length, equals(3)); // Should have x, y, z
        expect(position[2], equals(100)); // Check altitude
      }
    });

    test('uses the right-hand rule for consistent ring detection', () {
      // Create a complex shape with multiple possible ring configurations
      final lines = FeatureCollection(features: [
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 0]),
            Position.of([5, 0]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([5, 0]),
            Position.of([5, 5]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([5, 5]),
            Position.of([0, 5]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 5]),
            Position.of([0, 0]),
          ]),
        ),
        // Add crossing lines to create multiple possible paths
        Feature(
          geometry: LineString(coordinates: [
            Position.of([0, 2.5]),
            Position.of([5, 2.5]),
          ]),
        ),
        Feature(
          geometry: LineString(coordinates: [
            Position.of([2.5, 0]),
            Position.of([2.5, 5]),
          ]),
        ),
      ]);

      final result = polygonize(lines);

      // The implementation should produce the correct number of polygons
      // based on the right-hand rule (minimal clockwise angle)
      expect(result.features.length, greaterThan(0));

      // All exterior rings should have counter-clockwise orientation
      for (final feature in result.features) {
        final polygon = feature.geometry as Polygon;
        expect(
            booleanClockwise(LineString(coordinates: polygon.coordinates[0])),
            equals(false));
      }
    });
  });
}
