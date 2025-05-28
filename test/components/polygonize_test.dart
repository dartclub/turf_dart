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
      expect(polygon.coordinates[0].length, equals(5)); // 5 positions (closing point included)
      
      // Check first and last are the same (closed ring)
      expect(polygon.coordinates[0].first[0], equals(polygon.coordinates[0].last[0]));
      expect(polygon.coordinates[0].first[1], equals(polygon.coordinates[0].last[1]));
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
      expect(polygon.coordinates[0].length, equals(5)); // 5 positions (closing point included)
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
  });
}
