import 'distance.dart';
import 'geojson.dart';

/// Takes a reference [Point] and a FeatureCollection of Features
/// with Point geometries and returns the
/// point from the FeatureCollection closest to the reference. This calculation
/// is geodesic. For example:
///
/// ```dart
/// var targetPoint = Point(coordinates: Position(-75.943, 39.984));
/// Feature feature =
///    Feature(geometry: targetPoint, properties: {"marker-color": "#0F0"});
/// FeatureCollection points = FeatureCollection(features: [
///   Feature(geometry: Point(coordinates: Position(-75.343, 39.984))),
///   Feature(geometry: Point(coordinates: Position(-75.443, 39.984))),
///   Feature(geometry: Point(coordinates: Position(-75.543, 39.984))),
///   Feature(geometry: Point(coordinates: Position(-75.643, 39.984))),
/// ]);
///
/// var nearest = nearestPoint(targetPoint, points);
///
/// //addToMap
/// var addToMap = [targetPoint, points, nearest];
/// nearest.properties['marker-color'] = '#F00';
/// ```

Feature<Point> nearestPoint(
    Feature<Point> targetPoint, FeatureCollection<Point> points) {
  Feature<Point> nearest;
  num minDist = double.infinity;
  num bestFeatureIndex = 0;

  for (int i = 0; i < points.features.length; i++) {
    num distanceToPoint =
        distance(targetPoint.geometry!, points.features[i].geometry!);
    if (distanceToPoint < minDist) {
      bestFeatureIndex = i;
      minDist = distanceToPoint;
    }
  }

  nearest = points.features[bestFeatureIndex as int].clone();
  nearest.properties!['featureIndex'] = bestFeatureIndex;
  nearest.properties!['distanceToPoint'] = minDist;
  return nearest;
}
