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
      
      expect(result!.geometry?.coordinates?.toList(), equals([5.0, 10.0]));
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
      
      expect(result, isNotNull);
      expect(result!.geometry, isA<Point>());
      
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
      
      expect(result, isNotNull);
      
      // Check if point is within first polygon's bounds
      final coords = result!.geometry!.coordinates!;
      expect(coords[0], greaterThanOrEqualTo(-10.0));
      expect(coords[0], lessThanOrEqualTo(10.0));
      expect(coords[1], greaterThanOrEqualTo(0.0));
      expect(coords[1], lessThanOrEqualTo(20.0));
    });
    
    test('LineString - computes midpoint of first segment', () {
      // Create a LineString with multiple segments
      final lineString = Feature<LineString>(
        geometry: LineString(coordinates: [
          Position(0.0, 0.0),
          Position(10.0, 10.0),
          Position(20.0, 20.0)
        ]),
      );
      
      final result = pointOnFeature(lineString);
      
      expect(result, isNotNull);
      expect(result!.geometry!.coordinates!.toList(), equals([5.0, 5.0]));
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
      
      expect(result, isNotNull);
      
      // Check if point is within polygon bounds
      final coords = result!.geometry!.coordinates!;
      expect(coords[0], greaterThanOrEqualTo(-10.0));
      expect(coords[0], lessThanOrEqualTo(10.0));
      expect(coords[1], greaterThanOrEqualTo(-10.0));
      expect(coords[1], lessThanOrEqualTo(10.0));
    });
    
    test('Empty FeatureCollection returns null', () {
      final emptyFC = FeatureCollection<GeometryObject>(features: []);
      final result = pointOnFeature(emptyFC);
      expect(result, isNull);
    });
  });
}
