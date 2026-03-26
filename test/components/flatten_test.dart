import 'package:test/test.dart';
import 'package:turf/turf.dart';

void main() {
  group('flatten - out', () {
    test('MultiPoint', () {
      final input = Feature<MultiPoint>(
        geometry: MultiPoint(
          coordinates: [
            Position.of([100, 0]),
            Position.of([101, 1])
          ],
        ),
        properties: {'foo': 'bar'},
      );

      final result = flatten(input);

      expect(result, isA<FeatureCollection<GeometryObject>>());
      expect(result.features.length, 2);
      expect(result.features[0].geometry, isA<Point>());
      expect(result.features[1].geometry, isA<Point>());
      expect(result.features[0].properties, equals({'foo': 'bar'}));
      expect(result.features[1].properties, equals({'foo': 'bar'}));
    });

    test('MultiLineString', () {
      final input = Feature<MultiLineString>(
        geometry: MultiLineString(
          coordinates: [
            [
              Position.of([100, 0]),
              Position.of([101, 1])
            ],
            [
              Position.of([102, 2]),
              Position.of([103, 3])
            ],
          ],
        ),
        properties: {'foo': 'bar'},
      );

      final result = flatten(input);

      expect(result.features.length, 2);
      expect(result.features[0].geometry, isA<LineString>());
      expect(result.features[1].geometry, isA<LineString>());
      expect(result.features[0].properties, equals({'foo': 'bar'}));
      expect(result.features[1].properties, equals({'foo': 'bar'}));
    });

    test('MultiPolygon', () {
      final input = Feature<MultiPolygon>(
        geometry: MultiPolygon(
          coordinates: [
            [
              [
                Position.of([102, 2]),
                Position.of([103, 2]),
                Position.of([103, 3]),
                Position.of([102, 3]),
                Position.of([102, 2]),
              ]
            ],
            [
              [
                Position.of([100, 0]),
                Position.of([101, 0]),
                Position.of([101, 1]),
                Position.of([100, 1]),
                Position.of([100, 0]),
              ],
              [
                Position.of([100.2, 0.2]),
                Position.of([100.8, 0.2]),
                Position.of([100.8, 0.8]),
                Position.of([100.2, 0.8]),
                Position.of([100.2, 0.2]),
              ],
            ],
          ],
        ),
        properties: {'foo': 'bar'},
      );

      final result = flatten(input);

      expect(result.features.length, 2);
      expect(result.features[0].geometry, isA<Polygon>());
      expect(result.features[1].geometry, isA<Polygon>());
      expect(result.features[0].properties, equals({'foo': 'bar'}));
      expect(result.features[1].properties, equals({'foo': 'bar'}));
    });

    test('Polygon', () {
      final input = Feature<Polygon>(
        geometry: Polygon(
          coordinates: [
            [
              Position.of([102, 2]),
              Position.of([103, 2]),
              Position.of([103, 3]),
              Position.of([102, 3]),
              Position.of([102, 2]),
            ]
          ],
        ),
        properties: {'foo': 'bar'},
      );

      final result = flatten(input);

      expect(result.features.length, 1);
      expect(result.features[0].geometry, isA<Polygon>());
      expect(result.features[0].properties, equals({'foo': 'bar'}));
    });

    test('GeometryObject', () {
      final input = MultiPolygon(
        coordinates: [
          [
            [
              Position.of([102, 2]),
              Position.of([103, 2]),
              Position.of([103, 3]),
              Position.of([102, 3]),
              Position.of([102, 2]),
            ]
          ],
          [
            [
              Position.of([100, 0]),
              Position.of([101, 0]),
              Position.of([101, 1]),
              Position.of([100, 1]),
              Position.of([100, 0]),
            ],
            [
              Position.of([100.2, 0.2]),
              Position.of([100.8, 0.2]),
              Position.of([100.8, 0.8]),
              Position.of([100.2, 0.8]),
              Position.of([100.2, 0.2]),
            ],
          ],
        ],
      );

      final result = flatten(input);

      expect(result.features.length, 2);
      expect(result.features[0].geometry, isA<Polygon>());
      expect(result.features[1].geometry, isA<Polygon>());
    });

    test('FeatureCollection', () {
      final input = FeatureCollection<GeometryObject>(
        features: [
          Feature<MultiPoint>(
            geometry: MultiPoint(
              coordinates: [
                Position.of([100, 0]),
                Position.of([101, 1])
              ],
            ),
            properties: {'foo': 'bar'},
          ),
          Feature<MultiPolygon>(
            geometry: MultiPolygon(
              coordinates: [
                [
                  [
                    Position.of([102, 2]),
                    Position.of([103, 2]),
                    Position.of([103, 3]),
                    Position.of([102, 3]),
                    Position.of([102, 2]),
                  ]
                ],
                [
                  [
                    Position.of([100, 0]),
                    Position.of([101, 0]),
                    Position.of([101, 1]),
                    Position.of([100, 1]),
                    Position.of([100, 0]),
                  ],
                  [
                    Position.of([100.2, 0.2]),
                    Position.of([100.8, 0.2]),
                    Position.of([100.8, 0.8]),
                    Position.of([100.2, 0.8]),
                    Position.of([100.2, 0.2]),
                  ],
                ],
              ],
            ),
            properties: {'foo': 'bar'},
          ),
          Feature<MultiLineString>(
            geometry: MultiLineString(
              coordinates: [
                [
                  Position.of([100, 0]),
                  Position.of([101, 1])
                ],
                [
                  Position.of([102, 2]),
                  Position.of([103, 3])
                ],
              ],
            ),
            properties: {'foo': 'bar'},
          ),
        ],
      );

      final result = flatten(input);

      expect(result.features.length, 6);
      expect(
          result.features.map((f) => f.geometry.runtimeType),
          equals([
            Point,
            Point,
            Polygon,
            Polygon,
            LineString,
            LineString,
          ]));
      for (final feature in result.features) {
        expect(feature.properties, equals({'foo': 'bar'}));
      }
    });

    test('GeometryCollection is unsupported', () {
      // Is this still unsupported?
      final input = GeometryCollection(geometries: [
        MultiLineString(
          coordinates: [
            [
              Position.of([100, 0]),
              Position.of([101, 1])
            ],
            [
              Position.of([102, 2]),
              Position.of([103, 3])
            ],
          ],
        ),
        MultiPoint(
          coordinates: [
            Position.of([100, 0]),
            Position.of([101, 1])
          ],
        ),
        MultiPolygon(
          coordinates: [
            [
              [
                Position.of([102, 2]),
                Position.of([103, 2]),
                Position.of([103, 3]),
                Position.of([102, 3]),
                Position.of([102, 2]),
              ]
            ],
            [
              [
                Position.of([100, 0]),
                Position.of([101, 0]),
                Position.of([101, 1]),
                Position.of([100, 1]),
                Position.of([100, 0]),
              ],
              [
                Position.of([100.2, 0.2]),
                Position.of([100.8, 0.2]),
                Position.of([100.8, 0.8]),
                Position.of([100.2, 0.8]),
                Position.of([100.2, 0.2]),
              ],
            ],
          ],
        ),
      ]);
      expect(() => flatten(input), throwsArgumentError);
    });
  });

  group('flatten - out', () {
    test('always returns FeatureCollection', () {
      final samples = <GeoJSONObject>[
        Point(coordinates: Position.of([1, 2])),
        MultiPoint(coordinates: [
          Position.of([1, 2]),
          Position.of([3, 4])
        ]),
        Polygon(
          coordinates: [
            [
              Position.of([0, 0]),
              Position.of([1, 0]),
              Position.of([1, 1]),
              Position.of([0, 1]),
              Position.of([0, 0]),
            ]
          ],
        ),
      ];

      for (final sample in samples) {
        expect(flatten(sample), isA<FeatureCollection<GeometryObject>>());
      }
    });

    test('simple geometries', () {
      final simpleInputs = <GeoJSONObject>[
        Point(coordinates: Position.of([1, 2])),
        LineString(
          coordinates: [
            Position.of([1, 2]),
            Position.of([3, 4])
          ],
        ),
        Polygon(
          coordinates: [
            [
              Position.of([0, 0]),
              Position.of([1, 0]),
              Position.of([1, 1]),
              Position.of([0, 1]),
              Position.of([0, 0]),
            ]
          ],
        ),
      ];

      for (final input in simpleInputs) {
        expect(flatten(input).features.length, 1);
      }
    });

    test('non-simple geometries use of other features', () {
      final nonSimpleInputs = <GeoJSONObject>[
        MultiPoint(coordinates: [
          Position.of([1, 2]),
          Position.of([3, 4])
        ]),
        MultiLineString(
          coordinates: [
            [
              Position.of([1, 2]),
              Position.of([3, 4])
            ],
            [
              Position.of([5, 6]),
              Position.of([7, 8])
            ],
          ],
        ),
        MultiPolygon(
          coordinates: [
            [
              [
                Position.of([0, 0]),
                Position.of([1, 0]),
                Position.of([1, 1]),
                Position.of([0, 1]),
                Position.of([0, 0]),
              ]
            ],
            [
              [
                Position.of([10, 10]),
                Position.of([11, 10]),
                Position.of([11, 11]),
                Position.of([10, 11]),
                Position.of([10, 10]),
              ]
            ],
          ],
        ),
      ];

      for (final input in nonSimpleInputs) {
        expect(flatten(input).features.length, greaterThan(1));
      }
    });
  });
}
