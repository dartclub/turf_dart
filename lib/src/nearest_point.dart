import 'distance.dart';
import 'geojson.dart';

Feature<Point> nearestPoint(
    Feature<Point> targetPoint, FeatureCollection<Point> points) {
  Feature<Point> nearest;
  num minDist = double.infinity;
  num bestFeatureIndex = 0;

  for (var i = 0; i < points.features.length; i++) {
    var distanceToPoint =
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
