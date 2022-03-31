import 'dart:math';

import 'package:turf/helpers.dart';
import 'package:test/test.dart';
import 'package:turf/src/clusters.dart';

final properties = {"foo": "bar", "cluster": 0};
final geojson = FeatureCollection(features: [
  Feature(
      geometry: Point(coordinates: Position.of([0, 0])),
      properties: {"cluster": 0, "foo": "null"}),
  Feature(
      geometry: Point(coordinates: Position.of([2, 4])),
      properties: {"cluster": 1, "foo": "bar"}),
  Feature(
      geometry: Point(coordinates: Position.of([3, 6])),
      properties: {"cluster": 1}),
  Feature(
      geometry: Point(coordinates: Position.of([5, 1])),
      properties: {"0": "foo"}),
  Feature(
      geometry: Point(coordinates: Position.of([4, 2])),
      properties: {"bar": "foo"}),
  Feature(geometry: Point(coordinates: Position.of([2, 4])), properties: {}),
  Feature(geometry: Point(coordinates: Position.of([4, 3])), properties: null),
]);

main() {
  test("clusters -- getCluster", () {
    expect(getCluster(geojson, '0').features.length, 1);
    expect(() => getCluster(geojson, 1), throwsA(isA<Exception>()));
    expect(getCluster(geojson, "bar").features.length, 1);
    expect(getCluster(geojson, "cluster").features.length, 3);
    expect(getCluster(geojson, {"cluster": 1}).features.length, 2);
    expect(getCluster(geojson, {"cluster": 0}).features.length, 1);
    expect(
        getCluster(geojson, [
          "cluster",
          {"foo": "bar"}
        ]).features.length,
        1);
    expect(getCluster(geojson, ["cluster", "foo"]).features.length, 2);
    expect(getCluster(geojson, ["cluster"]).features.length, 3);
  });

  test("clusters -- clusterEach", () {
    List clusters = [];
    int total = 0;
    clusterEach(geojson, "cluster", (cluster, clusterValue, currentIndex) {
      total += cluster!.features.length;
      clusters.add(cluster);
      expect(cluster.features.isNotEmpty, true);
    });
    expect(total, 3);
    expect(clusters.length, 2);
  });

  test("clusters -- clusterReduce", () {
    List clusters = [];
    var total = clusterReduce<int>(geojson, "cluster",
        (previousValue, cluster, clusterValue, currentIndex) {
      clusters.add(cluster);
      return previousValue! + cluster!.features.length;
    }, 0);
    expect(total, 3);
    expect(clusters.length, 2);
  });

  test("applyFilter", () {
    expect(applyFilter(properties, ["cluster"]), isTrue);
    expect(applyFilter(properties, {"cluster": 1}), isFalse);
    expect(applyFilter(properties, {"cluster": 0}), isTrue);
    expect(applyFilter(null, {"cluster": 0}), isFalse);
  });

  test("filterProperties", () {
    expect(filterProperties(properties, ["cluster"]), equals({"cluster": 0}));
    expect(filterProperties(properties, []), equals({}));
    expect(filterProperties(properties, null), equals({}));
  });

  test("propertiesContainsFilter", () {
    expect(propertiesContainsFilter(properties, {"cluster": 0}), isTrue);
    expect(propertiesContainsFilter(properties, {"cluster": 1}), isFalse);
    expect(propertiesContainsFilter(properties, {"bar": "foo"}), isFalse);
  });

  test("propertiesContainsFilter", () {
    expect(
        createBins(geojson, "cluster"),
        equals({
          0: [0],
          1: [1, 2]
        }));
  });
}
