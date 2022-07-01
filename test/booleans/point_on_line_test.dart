import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_point_on_line.dart';

main() {
  group(
    'pointOnLine',
    () {
      var inDir = Directory('./test/examples/booleans/point_on_line/true');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              // True Fixtures
              var inSource = file.readAsStringSync();
              dynamic json = jsonDecode(inSource);
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              Map<String, dynamic>? properties = json['properties'];
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              var result = booleanPointOnLine(
                  feature1.geometry as Point, feature2.geometry as LineString,
                  epsilon: properties?['epsilon'],
                  ignoreEndVertices: properties?['ignoreEndVertices'] ?? false);
              expect(result, true);
            },
          );
        }
      }
      // False Fixtures
      var inDir1 = Directory('./test/examples/booleans/point_on_line/false');
      for (var file in inDir1.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              dynamic json = jsonDecode(inSource);
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              Map<String, dynamic>? properties = json['properties'];
              var feature1 = (inGeom as FeatureCollection).features[0];
              var feature2 = inGeom.features[1];
              var result = booleanPointOnLine(
                  feature1.geometry as Point, feature2.geometry as LineString,
                  epsilon: properties?['epsilon'],
                  ignoreEndVertices: properties?['ignoreEndVertices'] ?? false);

              expect(result, false);
            },
          );
        }
      }
    },
  );
}
