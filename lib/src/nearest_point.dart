import 'distance.dart';
import 'geojson.dart';

Feature<Point> nearestPoint(
    Feature<Point> targetPoint, FeatureCollection<Point> points) {
  Feature<Point> nearest;
  num minDist = double.infinity;
  num bestFeatureIndex = 0;

  for (int i = 0; i < points.features.length; i++) {
    num distanceToPoint =
        distance(targetPoint.geometry, points.features[i].geometry);
    if (distanceToPoint < minDist) {
      bestFeatureIndex = i;
      minDist = distanceToPoint;
    }
  }

  // TODO implement clone function -> Feature<Point>.clone(old) instead of formJson toJson

  nearest = Feature<Point>.fromJson(points.features[bestFeatureIndex].toJson());
  nearest.properties['featureIndex'] = bestFeatureIndex;
  nearest.properties['distanceToPoint'] = minDist;
  return nearest;
}
