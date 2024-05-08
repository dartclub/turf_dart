import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/boolean.dart';

void main() {
  group(
    'boolean-overlap',
    () {
      test(
        "turf-boolean-overlap-trues",
        () {
          // True Fixtures
          Directory dir = Directory('./test/examples/booleans/touches/true');
          for (var file in dir.listSync(recursive: true)) {
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              var result = booleanTouches(feature1, feature2);
              expect(result, true);
            }
          }
        },
      );

      test(
        "turf-boolean-overlap-false",
        () {
          // True Fixtures
          Directory dir = Directory('./test/examples/booleans/touches/false');
          for (var file in dir.listSync(recursive: true)) {
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              var result = booleanTouches(feature1, feature2);
              expect(result, false);
            }
          }
        },
      );
    },
  );
}
