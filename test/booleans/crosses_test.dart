import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_crosses.dart';

main() {
  test("turf-boolean-crosses", () {
    // True Fixtures
    var featureCollection = FeatureCollection(features: [
      Feature(
          properties: {},
          geometry: MultiPoint(coordinates: [
            Position.of([3, 3]),
            Position.of([1, 1])
          ])),
      Feature(
          properties: {},
          geometry: Polygon(coordinates: [
            [
              Position.of([0, 2]),
              Position.of([2, 2]),
              Position.of([2, 0]),
              Position.of([0, 0]),
              Position.of([0, 2])
            ]
          ]))
    ]);

    var feature1 = featureCollection.features[0];
    var feature2 = featureCollection.features[1];
    expect(
        booleanCrosses(feature1.geometry!, feature2.geometry!), equals(true));

    // False Fixtures
    var featureCollection1 = FeatureCollection(features: [
      Feature(
          properties: {},
          geometry: MultiPoint(coordinates: [
            Position.of([3, 3]),
            Position.of([1, 1])
          ])),
      Feature(
          properties: {},
          geometry: Polygon(coordinates: [
            [
              Position.of([0, 2]),
              Position.of([2, 2]),
              Position.of([2, 0]),
              Position.of([0, 0]),
              Position.of([0, 2])
            ]
          ]))
    ]);

    feature1 = featureCollection1.features[0];
    feature2 = featureCollection1.features[1];
    expect(
        booleanCrosses(feature1.geometry!, feature2.geometry!), equals(false));
  });
}
