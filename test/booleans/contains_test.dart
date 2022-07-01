import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_contains.dart';

main() {
  group(
    'contains',
    () {
      var inDir = Directory('./test/examples/boolean_contains/test/true');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              // True Fixtures
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));

              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              expect(booleanContains(feature1, feature2), true);
            },
          );
        }
      }

      var inDir1 = Directory('./test/examples/boolean_contains/test/false');
      for (var file in inDir1.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              // False Fixtures
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));

              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              expect(booleanContains(feature1, feature2), false);
            },
          );

          test(
            "turf-boolean-contains -- Geometry Objects",
            () {
              var pt1 =
                  Feature(geometry: Point(coordinates: Position.of([0, 0])));
              var pt2 =
                  Feature(geometry: Point(coordinates: Position.of([0, 0])));

              expect(booleanContains(pt1.geometry!, pt2.geometry!), true);
            },
          );
        }
      }
    },
  );
}
