import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/src/booleans/boolean_parallel.dart';
import 'package:turf/turf.dart';

void main() {
  group(
    'boolean-overlap',
    () {
      test(
        "turf-boolean-overlap-trues",
        () {
          // True Fixtures
          Directory dir = Directory('./test/examples/booleans/parallel/true');
          for (var file in dir.listSync(recursive: true)) {
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              var result = booleanParallel(feature1.geometry as LineString,
                  feature2.geometry as LineString);
              expect(result, true);
            }
          }
        },
      );

      test(
        "turf-boolean-overlap-falses",
        () {
          // True Fixtures
          Directory dir = Directory('./test/examples/booleans/parallel/false');
          for (var file in dir.listSync(recursive: true)) {
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              var result = booleanParallel(feature1.geometry as LineString,
                  feature2.geometry as LineString);
              expect(result, false);
            }
          }
        },
      );
    },
  );
}
