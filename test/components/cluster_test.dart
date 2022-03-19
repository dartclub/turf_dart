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
    expect(getCluster(geojson, 0).features.length, 1);
    expect(getCluster(geojson, 1).features.length, 0);
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
    const clusters = [];
    int total = 0;
    clusterEach(geojson, "cluster", (cluster, clusterValue, currentIndex) {
      total += cluster!.features.length;
      clusters.add(cluster);
      expect(cluster.features.isNotEmpty, true);
    });
    expect(total, 3);
    expect(clusters.length, 2);
  });

/*
test("clusters -- clusterReduce", (t) => {
  const clusters = [];
  const total = clusterReduce(
    geojson,
    "cluster",
    (previousValue, cluster) => {
      clusters.push(cluster);
      return previousValue + cluster.features.length;
    },
    0
  );
  t.equal(total, 3);
  t.equal(clusters.length, 2);
  t.end();
});

test("clusters.utils -- applyFilter", (t) => {
  t.true(applyFilter(properties, "cluster"));
  t.true(applyFilter(properties, ["cluster"]));
  t.false(applyFilter(properties, { cluster: 1 }));
  t.true(applyFilter(properties, { cluster: 0 }));
  t.false(applyFilter(undefined, { cluster: 0 }));
  t.end();
});

test("clusters.utils -- filterProperties", (t) => {
  t.deepEqual(filterProperties(properties, ["cluster"]), { cluster: 0 });
  t.deepEqual(filterProperties(properties, []), {});
  t.deepEqual(filterProperties(properties, undefined), {});
  t.end();
});

test("clusters.utils -- propertiesContainsFilter", (t) => {
  t.deepEqual(propertiesContainsFilter(properties, { cluster: 0 }), true);
  t.deepEqual(propertiesContainsFilter(properties, { cluster: 1 }), false);
  t.deepEqual(propertiesContainsFilter(properties, { bar: "foo" }), false);
  t.end();
});

test("clusters.utils -- propertiesContainsFilter", (t) => {
  t.deepEqual(createBins(geojson, "cluster"), { 0: [0], 1: [1, 2] });
  t.end();
});
*/
}
