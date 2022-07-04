import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_disjoint.dart';

main() {
  group(
    'boolean_crosses',
    () {
      var inDir = Directory('./test/examples/booleans/disjoint/true');
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
              var result = booleanDisjoint(feature1, feature2);
              expect(result, true);
            },
          );
          // False Fixtures
          var inDir1 = Directory('./test/examples/booleans/disjoint/false');
          for (var file in inDir1.listSync(recursive: true)) {
            if (file is File && file.path.endsWith('.geojson')) {
              test(
                file.path,
                () {
                  // True Fixtures
                  var inSource = file.readAsStringSync();
                  var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));

                  var feature1 = (inGeom as FeatureCollection).features[0];
                  var feature2 = inGeom.features[1];
                  var result = booleanDisjoint(feature1, feature2);

                  expect(result, false);
                },
              );
            }
          }
        }
      }
    },
  );
}
