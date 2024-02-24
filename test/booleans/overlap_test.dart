import 'package:test/test.dart';
import 'package:turf/src/booleans/boolean_helper.dart';
import 'package:turf/src/booleans/boolean_overlap.dart';
import 'package:turf/src/geojson.dart';

import '../context/helper.dart';
import '../context/load_test_cases.dart';

void main() {
  group('booleanOverlap', () {
    final pt = point([9, 50]);
    final multiPoint1 = multiPoint([
      [9, 50],
      [10, 50],
    ]);
    final multiPoint2 = multiPoint([
      [9, 50],
      [10, 100],
    ]);
    final line1 = lineString([
      [7, 50],
      [8, 50],
      [9, 50],
    ]);
    final line2 = lineString([
      [8, 50],
      [9, 50],
      [10, 50],
    ]);
    final poly1 = polygon([
      [
        [8.5, 50],
        [9.5, 50],
        [9.5, 49],
        [8.5, 49],
        [8.5, 50],
      ],
    ]);
    final poly2 = polygon([
      [
        [8, 50],
        [9, 50],
        [9, 49],
        [8, 49],
        [8, 50],
      ],
    ]);
    final poly3 = polygon([
      [
        [10, 50],
        [10.5, 50],
        [10.5, 49],
        [10, 49],
        [10, 50],
      ],
    ]);
    final multiline1 = multiLineString([
      [
        [7, 50],
        [8, 50],
        [9, 50],
      ],
    ]);
    final multipoly1 = multiPolygon([
      [
        [
          [8.5, 50],
          [9.5, 50],
          [9.5, 49],
          [8.5, 49],
          [8.5, 50],
        ],
      ],
    ]);

    test('supported geometries', () {
      // points
      expect(
        () => booleanOverlap(pt, pt),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(pt, multiPoint1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(pt, line1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(pt, multiline1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(pt, poly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(pt, multipoly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );

      // multiPoints
      expect(
        () => booleanOverlap(multiPoint1, multiPoint1),
        returnsNormally,
      );
      expect(
        () => booleanOverlap(multiPoint1, line1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(multiPoint1, multiline1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(multiPoint1, poly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(multiPoint1, multipoly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );

      // lines
      expect(
        () => booleanOverlap(line1, line1),
        returnsNormally,
      );
      expect(
        () => booleanOverlap(line1, multiline1),
        returnsNormally,
      );
      expect(
        () => booleanOverlap(line1, poly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );

      expect(
        () => booleanOverlap(line1, multipoly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );

      // multiline
      expect(
        () => booleanOverlap(multiline1, multiline1),
        returnsNormally,
      );
      expect(
        () => booleanOverlap(multiline1, poly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );
      expect(
        () => booleanOverlap(multiline1, multipoly1),
        throwsA(isA<GeometryCombinationNotSupported>()),
      );

      // polygons
      expect(
        () => booleanOverlap(poly1, poly1),
        returnsNormally,
      );
      expect(
        () => booleanOverlap(poly1, multipoly1),
        returnsNormally,
      );

      // multiPolygons
      expect(
        () => booleanOverlap(multipoly1, multipoly1),
        returnsNormally,
      );
    });

    test('equal geometries return false', () {
      expect(booleanOverlap(multiPoint1, multiPoint1), false);
      expect(booleanOverlap(line1, line1), false);
      expect(booleanOverlap(multiline1, multiline1), false);

      expect(booleanOverlap(poly1, poly1), false);
      expect(booleanOverlap(multipoly1, multipoly1), false);
    });

    test('overlapping geometries', () {
      expect(booleanOverlap(multiPoint1, multiPoint2), true);
      expect(booleanOverlap(line1, line2), true);
      expect(booleanOverlap(poly1, poly2), true);
      expect(booleanOverlap(poly1, poly3), false);
    });
  });

  group('booleanOverlap - examples', () {
    loadBooleanTestCases('test/examples/booleans/overlap', (
      path,
      geoJsonGiven,
      expected,
    ) {
      final first = (geoJsonGiven as FeatureCollection).features[0];
      final second = geoJsonGiven.features[1];
      test(path, () {
        expect(booleanOverlap(first, second), expected, reason: path);
      });
    });
  });
}
