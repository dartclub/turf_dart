import 'dart:convert';
import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  group('Point On Feature', () {
    test('Point geometry - returns unchanged', () {
      // Create a Point feature
      final point = Feature(
          geometry: Point(coordinates: Position(5.0, 10.0)),
          properties: {'name': 'Test Point'});
          
      final result = pointOnFeature(point);
      
      expect(result.geometry!.coordinates!.toList(), equals([5.0, 10.0]));
    });

    test('Polygon geometry - returns point inside polygon', () {
      // Create a triangle polygon
      final polygon = Feature<Polygon>(
        geometry: Polygon(coordinates: [
          [
            Position(-10.0, 0.0),
            Position(10.0, 0.0),
            Position(0.0, 20.0),
            Position(-10.0, 0.0)
          ]
        ]),
      );
      
      final result = pointOnFeature(polygon);
      
      expect(result.geometry, isA<Point>());
      
      // Simple check that result is within bounding box of polygon
      final coords = result.geometry!.coordinates!;
      expect(coords[0], greaterThanOrEqualTo(-10.0));
      expect(coords[0], lessThanOrEqualTo(10.0));
      expect(coords[1], greaterThanOrEqualTo(0.0));
      expect(coords[1], lessThanOrEqualTo(20.0));
    });

    test('MultiPolygon - uses first polygon', () {
      // Create a MultiPolygon with two polygons
      final multiPolygon = Feature<MultiPolygon>(
        geometry: MultiPolygon(coordinates: [
          [
            [
              Position(-10.0, 0.0),
              Position(10.0, 0.0),
              Position(0.0, 20.0),
              Position(-10.0, 0.0)
            ]
          ],
          [
            [
              Position(30.0, 10.0),
              Position(40.0, 10.0),
              Position(35.0, 20.0),
              Position(30.0, 10.0)
            ]
          ]
        ]),
      );
      
      final result = pointOnFeature(multiPolygon);
      
      // Check if point is within first polygon's bounds
      final coords = result.geometry!.coordinates!;
      expect(coords[0], greaterThanOrEqualTo(-10.0));
      expect(coords[0], lessThanOrEqualTo(10.0));
      expect(coords[1], greaterThanOrEqualTo(0.0));
      expect(coords[1], lessThanOrEqualTo(20.0));
    });
    
    test('LineString - computes midpoint of first segment using geodesic calculation', () {
      // Create a LineString with multiple segments
      final lineString = Feature<LineString>(
        geometry: LineString(coordinates: [
          Position(0.0, 0.0),
          Position(10.0, 10.0),
          Position(20.0, 20.0)
        ]),
      );
      
      final result = pointOnFeature(lineString);
      
      // The geodesic midpoint is calculated differently than arithmetic midpoint
      // Check that it returns a point (exact coordinates will vary based on the geodesic calculation)
      expect(result.geometry, isA<Point>());
      
      final coords = result.geometry!.coordinates!;
      // Verify coordinates are near the expected midpoint region
      expect(coords[0], closeTo(5.0, 1.0)); // Allow some deviation due to geodesic calculation
      expect(coords[1], closeTo(5.0, 1.0)); // Allow some deviation due to geodesic calculation
    });
    
    test('FeatureCollection - returns point on largest feature', () {
      // Create a FeatureCollection with a point and polygon
      final fc = FeatureCollection<GeometryObject>(features: [
        Feature(geometry: Point(coordinates: Position(0.0, 0.0))),
        Feature<Polygon>(
          geometry: Polygon(coordinates: [
            [
              Position(-10.0, -10.0),
              Position(10.0, -10.0),
              Position(10.0, 10.0),
              Position(-10.0, 10.0),
              Position(-10.0, -10.0),
            ]
          ]),
        )
      ]);
      
      final result = pointOnFeature(fc);
      
      // Check if point is within polygon bounds
      final coords = result.geometry!.coordinates!;
      expect(coords[0], greaterThanOrEqualTo(-10.0));
      expect(coords[0], lessThanOrEqualTo(10.0));
      expect(coords[1], greaterThanOrEqualTo(-10.0));
      expect(coords[1], lessThanOrEqualTo(10.0));
    });
    
    test('Empty FeatureCollection throws ArgumentError', () {
      final emptyFC = FeatureCollection<GeometryObject>(features: []);
      expect(() => pointOnFeature(emptyFC), 
        throwsA(isA<ArgumentError>().having(
          (e) => e.message, 
          'message', 
          'Cannot compute point on empty FeatureCollection'
        ))
      );
    });
  });
}
