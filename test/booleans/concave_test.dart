import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_concave.dart';

void main() {
  group(
    'concave',
    () {
      var inDir = Directory('./test/examples/booleans/concave/true');

      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              // True Fixtures
              var inSource = file.readAsStringSync();
              var json = jsonDecode(inSource);
              var inGeom = GeoJSONObject.fromJson(json);
              var feature = (inGeom as FeatureCollection).features[0];
              expect(booleanConcave(feature.geometry as Polygon), true);
            },
          );
        }
      }

      var inDir1 = Directory('./test/examples/booleans/concave/false');
      for (var file in inDir1.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              // False Fixtures
              var inSource = file.readAsStringSync();
              var json = jsonDecode(inSource);
              var inGeom = GeoJSONObject.fromJson(json);
              var feature = (inGeom as FeatureCollection).features[0];
              expect(booleanConcave(feature.geometry as Polygon), false);
            },
          );
        }
      }
    },
  );
}
