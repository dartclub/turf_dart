import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_crosses.dart';

main() {
  group(
    'boolean_crosses',
    () {
      // True Fixtures
      var inDir = Directory('./test/examples/booleans/crosses/true');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              expect(
                  booleanCrosses(feature1.geometry!, feature2.geometry!), true);
            },
          );
        }
      }
      // False Fixtures
      var inDir1 = Directory('./test/examples/booleans/crosses/false');
      for (var file in inDir1.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              expect(booleanCrosses(feature1.geometry!, feature2.geometry!),
                  isFalse);
            },
          );
        }
      }
    },
  );
}
