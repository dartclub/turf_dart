import 'package:benchmark/benchmark.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/meta/cluster.dart';

void main() {
  Point pt = Point(
    coordinates: Position(0, 0),
  );

  List<Point> points = [];
  List<Feature<Point>> pointFeatures = [];

  for (int i = 0; i < 1000; i++) {
    points.add(pt.clone());
    pointFeatures
        .add(Feature(geometry: pt.clone(), properties: {"cluster": 0}));
  }

  FeatureCollection featureCollection = FeatureCollection(
    features: pointFeatures,
  );

  group('cluster', () {
    benchmark('getCluster', () {
      getCluster(featureCollection, '0');
    });

    benchmark('clusterEach', () {
      List clusters = [];
      clusterEach(featureCollection, "cluster",
          (cluster, clusterValue, currentIndex) {
        clusters.add(cluster);
      });
    });
    List clusters = [];
    clusterReduce<int>(featureCollection, "cluster",
        (previousValue, cluster, clusterValue, currentIndex) {
      clusters.add(cluster);
      return previousValue! + cluster!.features.length;
    }, 0);
  });
}
