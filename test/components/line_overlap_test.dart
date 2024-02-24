import 'package:turf/line_overlap.dart';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';

import '../context/helper.dart';
import '../context/load_test_cases.dart';
import '../context/matcher.dart' as geo;

void main() {
  group('lineOverlap', () {
    final first = lineString([
      [100, -30],
      [150, -30],
    ]);
    test('inner part', () {
      final second = lineString([
        [110, -30],
        [120, -30],
      ]);
      final expected = featureCollection([second]);

      expect(lineOverlap(first, second), geo.equals(expected));
      expect(lineOverlap(second, first), geo.equals(expected));
    });
    test('start part', () {
      final second = lineString([
        [100, -30],
        [110, -30],
      ]);
      final expected = featureCollection([second]);

      expect(lineOverlap(first, second), geo.equals(expected));
      expect(lineOverlap(second, first), geo.equals(expected));
    });
    test('two inner segments', () {
      final second = lineString([
        [110, -30],
        [120, -30],
        [130, -30],
      ]);
      final expected = featureCollection([second]);

      expect(lineOverlap(first, second), geo.equals(expected));
      expect(lineOverlap(second, first), geo.equals(expected));
    });
    test('multiple segments on the same line', () {
      final first = lineString([
        [0, 1],
        [1, 1],
        [1, 0],
        [2, 0],
        [2, 1],
        [3, 1],
        [3, 0],
        [4, 0],
        [4, 1],
        [4, 0],
      ]);
      final second = lineString([
        [0, 0],
        [6, 0],
      ]);

      final expected = [
        lineString([
          [1, 0],
          [2, 0]
        ]),
        lineString([
          [3, 0],
          [4, 0]
        ]),
      ];

      expect(lineOverlap(first, second), geo.contains(expected));
      expect(lineOverlap(second, first), geo.contains(expected));
    });
    test('partial overlap', () {
      // bug: https://github.com/Turfjs/turf/issues/2580
      final second = lineString([
        [90, -30],
        [110, -30],
      ]);

      final expected = featureCollection([
        lineString([
          [100, -30],
          [110, -30],
        ])
      ]);

      expect(lineOverlap(first, second), geo.equals(expected));
      expect(lineOverlap(second, first), geo.equals(expected));
    });
    test('two separate inner segments', () {
      final second = lineString([
        [140, -30],
        [150, -30],
        [150, -20],
        [100, -20],
        [100, -30],
        [110, -30],
      ]);

      final expected = featureCollection(
        [
          lineString([
            [140, -30],
            [150, -30]
          ]),
          lineString([
            [100, -30],
            [110, -30]
          ]),
        ],
      );

      expect(lineOverlap(first, second), geo.equals(expected));
      expect(lineOverlap(second, first), geo.equals(expected));
    });
    test('validate tolerance', () {
      // bug: https://github.com/Turfjs/turf/issues/2582
      // distance between the lines are 11.x km
      final first = lineString([
        [10.0, 0.1],
        [11.0, 0.1]
      ]);
      final second = lineString([
        [10.0, 0.0],
        [11.0, 0.0]
      ]);

      final expected = featureCollection([second]);

      expect(
        lineOverlap(
          first,
          second,
          tolerance: 12.0,
        ),
        geo.equals(expected),
      );

      expect(
        lineOverlap(
          first,
          second,
          tolerance: 12.0,
          unit: Unit.kilometers,
        ),
        geo.equals(expected),
      );

      expect(
        lineOverlap(
          first,
          second,
          tolerance: 11.0,
          unit: Unit.kilometers,
        ),
        geo.length(0),
      );

      expect(
        lineOverlap(
          first,
          second,
          tolerance: 12.0,
          unit: Unit.meters,
        ),
        geo.length(0),
      );
    });
  });

  group('lineOverlap - examples', () {
    loadTestCases("test/examples/line_overlap", (
      path,
      geoJsonGiven,
      geoJsonExpected,
    ) {
      final first = (geoJsonGiven as FeatureCollection).features[0];
      final second = geoJsonGiven.features[1];
      final expectedCollection = geoJsonExpected as FeatureCollection;

      // The last 2 features are equal to the given input. If there are only 2
      // features in the collection it means, that we expect an empty result.
      // Otherwise the remaining features are expected.
      final expected = expectedCollection.features.length == 2
          ? featureCollection()
          : featureCollection(
              expectedCollection.features
                  .sublist(0, expectedCollection.features.length - 2)
                  .map((e) => Feature(geometry: e.geometry as LineString))
                  .toList(),
            );
      test(path, () {
        final tolerance = first.properties?['tolerance'] ?? 0.0;
        final result = lineOverlap(first, second, tolerance: tolerance);
        expect(result, geo.equals(expected));
      });
    });
  });
}
