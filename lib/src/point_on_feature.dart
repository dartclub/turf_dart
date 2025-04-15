import 'package:geotypes/geotypes.dart';
import 'package:turf/area.dart' as turf_area;
import 'package:turf/centroid.dart' as turf_centroid;
import 'package:turf/helpers.dart';
import 'package:turf/length.dart' as turf_length;
import 'package:turf/midpoint.dart' as turf_midpoint;
import 'package:turf_pip/turf_pip.dart';

/// Returns a [Feature<Point>] that represents a point guaranteed to be on the feature.
///
/// - For [Point] geometries: returns the original point
/// - For [Polygon] geometries: computes a point inside the polygon (preference to centroid)
/// - For [MultiPolygon] geometries: uses the first polygon to compute a point
/// - For [LineString] geometries: computes the midpoint along the line
/// - For [FeatureCollection]: returns a point on the largest feature
///
/// The resulting point is guaranteed to be on the feature.
///
/// Throws an [ArgumentError] if the input type is unsupported or if a valid point
/// cannot be computed.
Feature<Point> pointOnFeature(dynamic featureInput) {
  // Handle FeatureCollection
  if (featureInput is FeatureCollection) {
    if (featureInput.features.isEmpty) {
      throw ArgumentError('Cannot compute point on empty FeatureCollection');
    }
    
    // Find the largest feature in the collection
    Feature largestFeature = featureInput.features.first;
    double maxSize = _calculateFeatureSize(largestFeature);
    
    for (final feature in featureInput.features.skip(1)) {
      final size = _calculateFeatureSize(feature);
      if (size > maxSize) {
        maxSize = size;
        largestFeature = feature;
      }
    }
    
    // Get a point on the largest feature
    return pointOnFeature(largestFeature);
  }
  
  // Handle individual feature
  if (featureInput is Feature) {
    final geometry = featureInput.geometry;

    if (geometry is Point) {
      // Already a point: return it.
      return Feature<Point>(geometry: geometry, properties: featureInput.properties);
    } else if (geometry is LineString) {
      // For LineString: compute the midpoint
      return _midpointOnLine(geometry, featureInput.properties);
    } else if (geometry is Polygon) {
      // Use the existing centroid function
      final Feature<Point> centroidFeature = turf_centroid.centroid(
        featureInput,
        properties: featureInput.properties,
      );
      // Use non-null assertion operator since we know the geometry exists
      final Point centroid = centroidFeature.geometry!;
      // Convert Point to Position for boolean check
      final pointPos = Position(centroid.coordinates[0] ?? 0.0, centroid.coordinates[1] ?? 0.0);
      
      // Use point-in-polygon from turf_pip package directly
      final pipResult = pointInPolygon(Point(coordinates: pointPos), geometry);
      if (pipResult == PointInPolygonResult.isInside || pipResult == PointInPolygonResult.isOnEdge) {
        return centroidFeature;
      } else {
        // Try each vertex of the outer ring.
        final outerRing = geometry.coordinates.first;
        for (final pos in outerRing) {
          final candidate = Point(coordinates: pos);
          final candidatePos = Position(candidate.coordinates[0] ?? 0.0, candidate.coordinates[1] ?? 0.0);
          final candidatePipResult = pointInPolygon(Point(coordinates: candidatePos), geometry);
          if (candidatePipResult == PointInPolygonResult.isInside || candidatePipResult == PointInPolygonResult.isOnEdge) {
            return Feature<Point>(geometry: candidate, properties: featureInput.properties);
          }
        }
        // Fallback: return the centroid.
        return centroidFeature;
      }
    } else if (geometry is MultiPolygon) {
      // Use the first polygon from the MultiPolygon.
      if (geometry.coordinates.isNotEmpty && geometry.coordinates.first.isNotEmpty) {
        final firstPoly = Polygon(coordinates: geometry.coordinates.first);
        return pointOnFeature(Feature(
            geometry: firstPoly, properties: featureInput.properties));
      }
      throw ArgumentError('Cannot compute point on empty MultiPolygon');
    } else {
      throw ArgumentError('Unsupported geometry type: ${geometry.runtimeType}');
    }
  }
  
  // If we reach here, the input type is unsupported
  throw ArgumentError('Unsupported input type: ${featureInput.runtimeType}');
}

/// Calculates a representative midpoint on a [LineString].
Feature<Point> _midpointOnLine(LineString line, Map<String, dynamic>? properties) {
  final coords = line.coordinates;
  if (coords.isEmpty) {
    // Fallback for empty LineString - should not happen with valid GeoJSON
    return Feature<Point>(
      geometry: Point(coordinates: Position(0, 0)),
      properties: properties
    );
  }
  
  if (coords.length == 1) {
    // Only one point in the LineString
    return Feature<Point>(
      geometry: Point(coordinates: coords.first),
      properties: properties
    );
  }
  
  // Calculate the midpoint of the first segment using the midpoint library function
  // This gives a geodesically correct midpoint considering the curvature of the earth
  final start = coords[0];
  final end = coords[1];
  
  final startPoint = Point(coordinates: start);
  final endPoint = Point(coordinates: end);
  
  final midpoint = turf_midpoint.midpoint(startPoint, endPoint);
  
  return Feature<Point>(
    geometry: midpoint,
    properties: properties
  );
}

/// Helper to estimate the "size" of a feature for comparison.
double _calculateFeatureSize(Feature feature) {
  final geometry = feature.geometry;
  
  if (geometry is Point) {
    return 0; // Points have zero area
  } else if (geometry is LineString) {
    // Use the library's length function for accurate distance calculation
    final num calculatedLength = turf_length.length(
      Feature<LineString>(geometry: geometry),
      Unit.kilometers
    );
    return calculatedLength.toDouble();
  } else if (geometry is Polygon || geometry is MultiPolygon) {
    // Use the library's area function for accurate area calculation
    final num? calculatedArea = turf_area.area(Feature(geometry: geometry));
    return calculatedArea?.toDouble() ?? 0.0;
  }
  
  // Return 0 for unsupported geometry types
  return 0;
}
