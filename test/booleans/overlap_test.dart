import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_overlap.dart';

main() {
  group(
    'boolean-overlap',
    () {
      test("turf-boolean-overlap-trues", () {
        // True Fixtures
        Directory dir = Directory('./test/examples/booleans/overlap/true');
        for (var file in dir.listSync(recursive: true)) {
          if (file is File && file.path.endsWith('.geojson')) {
            var inSource = file.readAsStringSync();
            var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
            var feature1 = (inGeom as FeatureCollection).features[0];
            var feature2 = inGeom.features[1];
            var result = booleanOverlap(feature1, feature2);
            expect(result, true);
          }
        }
      });
      test(
        "turf-boolean-overlap - falses",
        () {
          // True Fixtures
          Directory dir1 = Directory('./test/examples/booleans/overlap/false');
          for (var file in dir1.listSync(recursive: true)) {
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              var result = booleanOverlap(feature1, feature2);
              expect(result, false);
            }
          }
        },
      );

      var pt = Point(coordinates: Position.of([9, 50]));
      var line1 = LineString(
        coordinates: [
          Position.of([7, 50]),
          Position.of([8, 50]),
          Position.of([9, 50]),
        ],
      );
      var line2 = LineString(
        coordinates: [
          Position.of([8, 50]),
          Position.of([9, 50]),
          Position.of([10, 50]),
        ],
      );
      var poly1 = Polygon(
        coordinates: [
          [
            Position.of([8.5, 50]),
            Position.of([9.5, 50]),
            Position.of([9.5, 49]),
            Position.of([8.5, 49]),
            Position.of([8.5, 50]),
          ],
        ],
      );
      var poly2 = Polygon(
        coordinates: [
          [
            Position.of([8, 50]),
            Position.of([9, 50]),
            Position.of([9, 49]),
            Position.of([8, 49]),
            Position.of([8, 50]),
          ],
        ],
      );
      var poly3 = Polygon(
        coordinates: [
          [
            Position.of([10, 50]),
            Position.of([10.5, 50]),
            Position.of([10.5, 49]),
            Position.of([10, 49]),
            Position.of([10, 50]),
          ],
        ],
      );
      var multiline1 = MultiLineString(
        coordinates: [
          [
            Position.of([8, 50]),
            Position.of([9, 50]),
            Position.of([7, 50]),
          ],
        ],
      );
      var multipoly1 = MultiPolygon(
        coordinates: [
          [
            [
              Position.of([8.5, 50]),
              Position.of([9.5, 50]),
              Position.of([9.5, 49]),
              Position.of([8.5, 49]),
              Position.of([8.5, 50]),
            ],
          ],
        ],
      );

      test(
        "turf-boolean-overlap -- geometries",
        () {
          expect(booleanOverlap(line1, line2), true);
          expect(booleanOverlap(poly1, poly2), true);
          var z = booleanOverlap(poly1, poly3);
          expect(z, isFalse);
        },
      );

      test(
        "turf-boolean-overlap -- throws",
        () {
          // t.throws(() => overlap(null, line1), /feature1 is required/, 'missing feature1');
          // t.throws(() => overlap(line1, null), /feature2 is required/, 'missing feature2');

//'different types',
          expect(
              () => booleanOverlap(
                    poly1,
                    line1,
                  ),
              throwsA(isA<Exception>()));
// "geometry not supported"

          expect(() => booleanOverlap(pt, pt), throwsA(isA<Exception>()));
          //  "supports line and multiline comparison"
          var x = booleanOverlap(line1, multiline1);
          expect(() => booleanOverlap(line1, multiline1), x);
          var y = booleanOverlap(poly1, multipoly1);
          expect(() => booleanOverlap(poly1, multipoly1), y);
        },
      );
    },
  );
}
