import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_intersect.dart';

// main() {
  var featureCollection = FeatureCollection(features: [
    Feature(
        properties: {"fill": "#ff0000"},
        geometry: MultiPolygon(coordinates: [
          [
            [
              Position.of([122.6953125, -19.186677697957833]),
              Position.of([128.759765625, -19.186677697957833]),
              Position.of([128.759765625, -15.28418511407642]),
              Position.of([122.6953125, -15.28418511407642]),
              Position.of([122.6953125, -19.186677697957833])
            ]
          ],
          [
            [
              Position.of([123.74999999999999, -25.918526162075153]),
              Position.of([130.25390625, -25.918526162075153]),
              Position.of([130.25390625, -20.715015145512087]),
              Position.of([123.74999999999999, -20.715015145512087]),
              Position.of([123.74999999999999, -25.918526162075153]),
            ]
          ]
        ])),
    Feature(
        properties: {"fill": "#0000ff"},
        geometry: Polygon(coordinates: [
          [
            Position.of([119.20166015624999, -22.776181505086495]),
            Position.of([125.09033203124999, -22.776181505086495]),
            Position.of([125.09033203124999, -18.417078658661257]),
            Position.of([119.20166015624999, -18.417078658661257]),
            Position.of([119.20166015624999, -22.776181505086495])
          ]
        ]))
  ]);

  var featureCollection1 = FeatureCollection(features: [
    Feature(
        properties: {"fill": "#ff0000"},
        geometry: MultiPolygon(coordinates: [
          [
            [
              Position.of([122.6953125, -19.186677697957833]),
              Position.of([128.759765625, -19.186677697957833]),
              Position.of([128.759765625, -15.28418511407642]),
              Position.of([122.6953125, -15.28418511407642]),
              Position.of([122.6953125, -19.186677697957833])
            ]
          ],
          [
            [
              Position.of([123.74999999999999, -25.918526162075153]),
              Position.of([130.25390625, -25.918526162075153]),
              Position.of([130.25390625, -20.715015145512087]),
              Position.of([123.74999999999999, -20.715015145512087]),
              Position.of([123.74999999999999, -25.918526162075153])
            ]
          ]
        ])),
    Feature(
        properties: {"fill": "#0000ff"},
        geometry: Polygon(coordinates: [
          [
            Position.of([116.98242187499999, -24.647017162630352]),
            Position.of([122.87109375, -24.647017162630352]),
            Position.of([122.87109375, -20.34462694382967]),
            Position.of([116.98242187499999, -20.34462694382967]),
            Position.of([116.98242187499999, -24.647017162630352])
          ]
        ]))
  ]);
  test("turf-boolean-intersects", () {
    // True Fixtures

    var feature1 = featureCollection.features[0];
    var feature2 = featureCollection.features[1];

    expect(booleanIntersects(feature1, feature2), equals(true));

    // False Fixtures
    var feature3 = featureCollection1.features[0];
    var feature4 = featureCollection1.features[1];
    expect(booleanIntersects(feature3, feature4), equals(false));
  });
}
