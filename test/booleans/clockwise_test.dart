import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_clockwise.dart';

void main() {
  group(
    'clockwise',
    () {
      test(
        'simple LineString',
        () {
          var list = <Position>[
            Position.of([10, 10]),
            Position.of([11, 10]),
            Position.of([12, 10]),
            Position.of([13, 10]),
          ];
          expect(booleanClockwise(LineString(coordinates: list)), true);
        },
      );

      var inDir = Directory('./test/examples/booleans/clockwise/true');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(file.path, () {
            // True Fixtures
            var inSource = file.readAsStringSync();
            dynamic json = jsonDecode(inSource);
            var inGeom = GeoJSONObject.fromJson(json);
            var feature0 = (inGeom as FeatureCollection).features[0];

            expect(booleanClockwise(feature0.geometry as LineString), true);
          });
        }
      }

      var inDir1 = Directory('./test/examples/booleans/clockwise/false');
      for (var file in inDir1.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              // True Fixtures
              var inSource = file.readAsStringSync();
              dynamic json = jsonDecode(inSource);
              var inGeom = GeoJSONObject.fromJson(json);
              var feature0 = (inGeom as FeatureCollection).features[0];
              expect(booleanClockwise(feature0.geometry as LineString), false);
            },
          );
        }
      }
    },
  );
}
