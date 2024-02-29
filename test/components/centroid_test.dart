import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/turf.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group(
    'centroid',
    () {
      test('centroid -- add properties', () {
        final line = Feature<LineString>(
            geometry:
                LineString(coordinates: [Position(0, 0), Position(1, 1)]));
        final out = centroid(line, properties: {'foo': 'bar'});

        final isEqual = out.properties?['foo'] == 'bar';
        expect(isEqual, true);
      });

      Directory inDir = Directory('./test/examples/centroid/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var feature = GeoJSONObject.fromJson(jsonDecode(inSource));

              final centered = centroid(
                feature,
                properties: {"marker-symbol": "circle"},
              );

              final result =
                  FeatureCollection<GeometryObject>(features: [centered]);
              featureEach(
                feature,
                (currentFeature, featureIndex) =>
                    result.features.add(currentFeature),
              );

              Directory outDir = Directory('./test/examples/centroid/out');
              for (var file2 in outDir.listSync(recursive: true)) {
                if (file2 is File &&
                    file2.uri.pathSegments.last == file.uri.pathSegments.last) {
                  var outSource = file2.readAsStringSync();
                  var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
                  Equality eq = Equality();
                  expect(eq.compare(result, outGeom), true);
                }
              }
            },
          );
        }
      }
    },
  );
}
