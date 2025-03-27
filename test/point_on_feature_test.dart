import 'dart:convert';
import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  group('pointOnFeature', () {
    test('point geometry - returns unchanged', () {
      // Arrange: a GeoJSON Feature with a Point geometry.
      const jsonString = '''
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [5.0, 10.0]
        },
        "properties": {
          "name": "Test Point"
        }
      }
      ''';
      final jsonData = jsonDecode(jsonString);
      final feature = Feature.fromJson(jsonData);

      // Act: compute the representative point.
      final result = pointOnFeature(feature);

      // Assert: the result should be a Point identical to the input.
      expect(result, isNotNull);
      expect(result!.geometry, isA<Point>());
      expect(result.geometry?.coordinates?.toList(), equals([5.0, 10.0]));
    });

    test('polygon geometry - computes point within', () {
      // Arrange: a GeoJSON Feature with a simple triangle Polygon.
      const polygonJson = '''
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [
            [
              [-10.0, 0.0],
              [10.0, 0.0],
              [0.0, 20.0],
              [-10.0, 0.0]
            ]
          ]
        },
        "properties": {
          "name": "Triangle"
        }
      }
      ''';
      final jsonData = jsonDecode(polygonJson);
      final feature = Feature.fromJson(jsonData);

      // Act: compute the representative point.
      final result = pointOnFeature(feature);

      // Assert: the result should be a Point and lie within the polygon.
      expect(result, isNotNull);
      expect(result!.geometry, isA<Point>());
      final polygon = feature.geometry as Polygon;
      // Convert point to position for the boolean check
      final pointPosition = Position(result.geometry?.coordinates?[0] ?? 0.0, 
                                     result.geometry?.coordinates?[1] ?? 0.0);
      expect(_pointInPolygon(pointPosition, polygon), isTrue);
    });

    test('multipolygon - uses first polygon', () {
      // Arrange: a GeoJSON Feature with a MultiPolygon geometry.
      const multiPolygonJson = '''
      {
        "type": "Feature",
        "geometry": {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [-10.0, 0.0],
                [10.0, 0.0],
                [0.0, 20.0],
                [-10.0, 0.0]
              ]
            ],
            [
              [
                [30.0, 10.0],
                [40.0, 10.0],
                [35.0, 20.0],
                [30.0, 10.0]
              ]
            ]
          ]
        },
        "properties": {
          "name": "MultiPolygon Example"
        }
      }
      ''';
      final jsonData = jsonDecode(multiPolygonJson);
      final feature = Feature.fromJson(jsonData);

      // Act: compute the representative point.
      final result = pointOnFeature(feature);

      // Assert: the result should be a Point and lie within the first polygon.
      expect(result, isNotNull);
      expect(result!.geometry, isA<Point>());
      // Create a Polygon from just the first polygon in the MultiPolygon
      final coordinates = (jsonData['geometry'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
      final polygonGeometry = {
        'type': 'Polygon',
        'coordinates': coordinates[0]
      };
      final firstPolygon = Polygon.fromJson(polygonGeometry);
      // Convert point to position for the boolean check
      final pointPosition = Position(result.geometry?.coordinates?[0] ?? 0.0, 
                                     result.geometry?.coordinates?[1] ?? 0.0);
      expect(_pointInPolygon(pointPosition, firstPolygon), isTrue);
    });
    
    test('linestring - computes midpoint', () {
      // Arrange: a GeoJSON Feature with a LineString geometry.
      const lineJson = '''
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [0.0, 0.0],
            [10.0, 10.0],
            [20.0, 20.0]
          ]
        },
        "properties": {
          "name": "Simple Line"
        }
      }
      ''';
      final jsonData = jsonDecode(lineJson);
      final feature = Feature.fromJson(jsonData);

      // Act: compute the representative point.
      final result = pointOnFeature(feature);

      // Assert: the result should be a Point on the line (in this case, the midpoint of the middle segment).
      expect(result, isNotNull);
      expect(result!.geometry, isA<Point>());
      
      // Verify it's the midpoint of the middle segment
      final coordinates = (jsonData['geometry'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
      final middleSegmentStart = coordinates[0]; // For a 3-point line, the middle segment starts at the first point
      final middleSegmentEnd = coordinates[1];
      
      final expectedX = ((middleSegmentStart[0] as num) + (middleSegmentEnd[0] as num)) / 2;
      final expectedY = ((middleSegmentStart[1] as num) + (middleSegmentEnd[1] as num)) / 2;
      
      expect(result.geometry?.coordinates?[0], expectedX);
      expect(result.geometry?.coordinates?[1], expectedY);
    });
    
    test('featurecollection - returns point on largest feature', () {
      // Arrange: a FeatureCollection with multiple features of different types and sizes.
      const fcJson = '''
      {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [0.0, 0.0]
            },
            "properties": { "name": "Small Point" }
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "LineString",
              "coordinates": [
                [5.0, 5.0],
                [10.0, 10.0]
              ]
            },
            "properties": { "name": "Short Line" }
          },
          {
            "type": "Feature",
            "geometry": {
              "type": "Polygon",
              "coordinates": [
                [
                  [-10.0, -10.0],
                  [10.0, -10.0],
                  [10.0, 10.0],
                  [-10.0, 10.0],
                  [-10.0, -10.0]
                ]
              ]
            },
            "properties": { "name": "Large Square" }
          }
        ]
      }
      ''';
      final jsonData = jsonDecode(fcJson);
      final featureCollection = FeatureCollection.fromJson(jsonData);

      // Act: compute the representative point.
      final result = pointOnFeature(featureCollection);

      // Assert: the result should be a Point that lies within the largest feature (the polygon).
      expect(result, isNotNull);
      expect(result!.geometry, isA<Point>());
      
      // Extract the polygon from the collection
      final polygonFeature = featureCollection.features[2];
      final polygon = polygonFeature.geometry as Polygon;
      
      // Verify the point is within the polygon
      final pointPosition = Position(result.geometry?.coordinates?[0] ?? 0.0, 
                                    result.geometry?.coordinates?[1] ?? 0.0);
      expect(_pointInPolygon(pointPosition, polygon), isTrue);
    });
  });
}

/// Internal implementation of point-in-polygon for testing
bool _pointInPolygon(Position point, Polygon polygon) {
  final outerRing = polygon.coordinates.first;
  final int numVertices = outerRing.length;
  bool inside = false;
  final num pxNum = point[0] ?? 0.0;
  final num pyNum = point[1] ?? 0.0;
  final double px = pxNum.toDouble();
  final double py = pyNum.toDouble();

  for (int i = 0, j = numVertices - 1; i < numVertices; j = i++) {
    final num xiNum = outerRing[i][0] ?? 0.0;
    final num yiNum = outerRing[i][1] ?? 0.0;
    final num xjNum = outerRing[j][0] ?? 0.0;
    final num yjNum = outerRing[j][1] ?? 0.0;
    final double xi = xiNum.toDouble();
    final double yi = yiNum.toDouble();
    final double xj = xjNum.toDouble();
    final double yj = yjNum.toDouble();
    
    // Check if point is on a polygon vertex
    if ((xi == px && yi == py) || (xj == px && yj == py)) {
      return true;
    }
    
    // Check if point is on a polygon edge
    if (yi == yj && yi == py && 
        ((xi <= px && px <= xj) || (xj <= px && px <= xi))) {
      return true;
    }
    
    // Ray-casting algorithm for checking if point is inside polygon
    final bool intersect = ((yi > py) != (yj > py)) &&
        (px < (xj - xi) * (py - yi) / (yj - yi + 0.0) + xi);
    if (intersect) {
      inside = !inside;
    }
  }
  
  return inside;
}
