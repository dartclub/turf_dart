import 'package:test/test.dart';
import 'package:turf/turf.dart'; 
import 'package:turf/dbscan.dart'; 

void main() {
  group('DBSCAN clustering', () {
    test('clusters points correctly', () {
      // Create some sample points that form two clusters
      final points = FeatureCollection<Point>(features: [
        Feature<Point>(geometry: Point(coordinates: Position(0, 0))),
        Feature<Point>(geometry: Point(coordinates: Position(0.1, 0.1))),
        Feature<Point>(geometry: Point(coordinates: Position(0.2, 0.2))),
        Feature<Point>(geometry: Point(coordinates: Position(5, 5))),
        Feature<Point>(geometry: Point(coordinates: Position(5.1, 5.1))),
      ]);

      // Run dbscan with parameters:
      // maxClusterLength = 10 clusters max
      // minPoints = 2 points needed to form a cluster
      // maxRadius = 20000 meters (~20 km)
      final clustered = dbscan(points, 10, 2, 20000);

      // Check clusters assigned:
      final clusters = clustered.features.map((f) => f.properties['cluster']).toList();

      // Points 0,1,2 should have same cluster id (0)
      expect(clusters[0], equals(0));
      expect(clusters[1], equals(0));
      expect(clusters[2], equals(0));

      // Points 3,4 should have same cluster id (1)
      expect(clusters[3], equals(1));
      expect(clusters[4], equals(1));
    });

    test('noise points are marked with null cluster', () {
      // Points spaced far apart, no clusters
      final points = FeatureCollection<Point>(features: [
        Feature<Point>(geometry: Point(coordinates: Position(0, 0))),
        Feature<Point>(geometry: Point(coordinates: Position(10, 10))),
      ]);

      final clustered = dbscan(points, 10, 2, 1000); // maxRadius only 1 km

      // Both points should be noise (cluster == null)
      for (final feature in clustered.features) {
        expect(feature.properties['cluster'], isNull);
      }
    });

    test('throws error if minPoints <= 0', () {
      final points = FeatureCollection<Point>(features: [
        Feature<Point>(geometry: Point(coordinates: Position(0, 0))),
      ]);

      expect(() => dbscan(points, 10, 0, 1000), throwsArgumentError);
    });

    test('throws error if maxRadius < 0', () {
      final points = FeatureCollection<Point>(features: [
        Feature<Point>(geometry: Point(coordinates: Position(0, 0))),
      ]);

      expect(() => dbscan(points, 10, 1, -10), throwsArgumentError);
    });
  });
}