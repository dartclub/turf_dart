import 'dart:math';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_point_on_line.dart';

main() {
  // False Fixtures
  test(
    "turf-boolean-point-on-line",
    () {
      var featureCollection = FeatureCollection(
        features: [
          Feature<Point>(
              properties: {},
              geometry: Point(
                  coordinates:
                      Position.of([-75.25737143565107, 39.99673377198139]))),
          Feature(
            properties: {},
            geometry: LineString(
              coordinates: [
                Position.of([-75.2580499870244, 40.00180204907801]),
                Position.of([-75.25676601413157, 39.992211720827044]),
              ],
            ),
          )
        ],
      );

      var options = {"epsilon": 10e-18};

      var feature1 = featureCollection.features[0].geometry;
      var feature2 = featureCollection.features[1].geometry;
      expect(
          booleanPointOnLine(feature1 as Point, feature2 as LineString,
              epsilon: options["epsilon"]),
          equals(false));
      // True Fixtures
      var featureCollection1 = FeatureCollection(features: [
        Feature(
            properties: {}, geometry: Point(coordinates: Position.of([2, 2]))),
        Feature(
          properties: {},
          geometry: LineString(
            coordinates: [
              Position.of([0, 0]),
              Position.of([3, 3]),
              Position.of([38.3203125, 5.965753671065536])
            ],
          ),
        )
      ]);

      feature1 = featureCollection1.features[0].geometry;
      feature2 = featureCollection1.features[1].geometry;
      expect(
          booleanPointOnLine(feature1 as Point, feature2 as LineString,
              epsilon: options["epsilon"]),
          equals(true));
    },
  );
}
