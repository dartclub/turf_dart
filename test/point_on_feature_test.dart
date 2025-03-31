import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  group('Point On Feature', () {
    // Unit tests for specific scenarios
    test('Point geometry - returns unchanged', () {
      // Input: Point geometry
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

      // Process the feature
      final result = pointOnFeature(feature);

      // Verify result
      expect(result, isNotNull,
          reason: 'Result should not be null');
      expect(result!.geometry, isA<Point>(),
          reason: 'Result should be a Point geometry');
      expect(result.geometry?.coordinates?.toList(), equals([5.0, 10.0]),
          reason: 'Point coordinates should remain unchanged');
      
      // Verify properties are maintained
      expect(result.properties?['name'], equals('Test Point'),
          reason: 'Feature properties should be preserved');
    });

    test('Polygon geometry - computes point within polygon', () {
      // Input: Triangle polygon
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

      // Process the feature
      final result = pointOnFeature(feature);

      // Verify result structure
      expect(result, isNotNull,
          reason: 'Result should not be null');
      expect(result!.geometry, isA<Point>(),
          reason: 'Result should be a Point geometry');
          
      // Verify point is within polygon
      final polygon = feature.geometry as Polygon;
      final pointPosition = Position(
          result.geometry?.coordinates?[0] ?? 0.0, 
          result.geometry?.coordinates?[1] ?? 0.0);
      expect(_pointInPolygon(pointPosition, polygon), isTrue,
          reason: 'Result point should be inside the polygon');
      
      // Verify properties are maintained
      expect(result.properties?['name'], equals('Triangle'),
          reason: 'Feature properties should be preserved');
    });

    test('MultiPolygon geometry - uses first polygon', () {
      // Input: MultiPolygon with two polygons
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

      // Process the feature
      final result = pointOnFeature(feature);

      // Verify result structure
      expect(result, isNotNull,
          reason: 'Result should not be null');
      expect(result!.geometry, isA<Point>(),
          reason: 'Result should be a Point geometry');
          
      // Extract the first polygon from the MultiPolygon
      final coordinates = (jsonData['geometry'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
      final polygonGeometry = {
        'type': 'Polygon',
        'coordinates': coordinates[0]
      };
      final firstPolygon = Polygon.fromJson(polygonGeometry);
      
      // Verify point is within first polygon
      final pointPosition = Position(
          result.geometry?.coordinates?[0] ?? 0.0, 
          result.geometry?.coordinates?[1] ?? 0.0);
      expect(_pointInPolygon(pointPosition, firstPolygon), isTrue,
          reason: 'Result point should be inside the first polygon of the MultiPolygon');
      
      // Verify properties are maintained
      expect(result.properties?['name'], equals('MultiPolygon Example'),
          reason: 'Feature properties should be preserved');
    });
    
    test('LineString geometry - computes midpoint of first segment', () {
      // Input: LineString with multiple segments
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

      // Process the feature
      final result = pointOnFeature(feature);

      // Verify result structure
      expect(result, isNotNull,
          reason: 'Result should not be null');
      expect(result!.geometry, isA<Point>(),
          reason: 'Result should be a Point geometry');
      
      // Calculate the expected midpoint of the first segment
      final coordinates = (jsonData['geometry'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
      final firstSegmentStart = coordinates[0];
      final firstSegmentEnd = coordinates[1];
      
      final expectedX = ((firstSegmentStart[0] as num) + (firstSegmentEnd[0] as num)) / 2;
      final expectedY = ((firstSegmentStart[1] as num) + (firstSegmentEnd[1] as num)) / 2;
      
      // Verify midpoint coordinates
      expect(result.geometry?.coordinates?[0], expectedX,
          reason: 'X coordinate should be the midpoint of the first segment');
      expect(result.geometry?.coordinates?[1], expectedY,
          reason: 'Y coordinate should be the midpoint of the first segment');
      
      // Verify properties are maintained
      expect(result.properties?['name'], equals('Simple Line'),
          reason: 'Feature properties should be preserved');
    });
    
    test('FeatureCollection - returns point on largest feature', () {
      // Input: FeatureCollection with multiple features of different sizes
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

      // Process the FeatureCollection
      final result = pointOnFeature(featureCollection);

      // Verify result structure
      expect(result, isNotNull, 
          reason: 'Result should not be null');
      expect(result!.geometry, isA<Point>(),
          reason: 'Result should be a Point geometry');
      
      // The polygon should be identified as the largest feature
      final polygonFeature = featureCollection.features[2];
      final polygon = polygonFeature.geometry as Polygon;
      
      // Verify point is within the polygon (largest feature)
      final pointPosition = Position(
          result.geometry?.coordinates?[0] ?? 0.0, 
          result.geometry?.coordinates?[1] ?? 0.0);
      expect(_pointInPolygon(pointPosition, polygon), isTrue,
          reason: 'Result point should be inside the largest feature (polygon)');
      
      // Verify properties are from the largest feature
      expect(result.properties?['name'], equals('Large Square'),
          reason: 'Feature properties should be from the largest feature');
    });
    
    // Additional test case for empty FeatureCollection
    test('Empty FeatureCollection returns null', () {
      // Input: FeatureCollection with no features
      const emptyFcJson = '''
      {
        "type": "FeatureCollection",
        "features": []
      }
      ''';
      final jsonData = jsonDecode(emptyFcJson);
      final featureCollection = FeatureCollection.fromJson(jsonData);

      // Process the FeatureCollection
      final result = pointOnFeature(featureCollection);

      // Verify result is null for empty collection
      expect(result, isNull,
          reason: 'Result should be null for empty FeatureCollection');
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
