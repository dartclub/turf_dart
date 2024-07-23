import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/circle.dart';
import 'package:turf/src/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

import '../context/helper.dart';

void main() {
  group(
    'circle',
    () {
      test('circle -- add properties', () {
        final point = Point(coordinates: Position(0, 0));
        final out = circle(point, 10, properties: {'foo': 'bar'});

        final isEqual = out.properties?['foo'] == 'bar';
        expect(isEqual, true);
      });

      Directory inDir = Directory('./test/examples/circle/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              final inSource = file.readAsStringSync();
              final feature = Feature.fromJson(jsonDecode(inSource));
              final properties = feature.properties ?? {};
              final radius = properties['radius'] ?? 5;
              final steps = properties['steps'] ?? 64;
              final unit = properties['units'];

              final C = truncate(circle(feature, radius,
                  properties: {"marker-symbol": "circle"},
                  steps: steps,
                  unit: unit)) as Feature<Polygon>;

              final results = featureCollection([feature, C]);

              Directory outDir = Directory('./test/examples/centroid/out');
              for (var file2 in outDir.listSync(recursive: true)) {
                if (file2 is File &&
                    file2.uri.pathSegments.last == file.uri.pathSegments.last) {
                  var outSource = file2.readAsStringSync();
                  var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
                  Equality eq = Equality();
                  expect(eq.compare(results, outGeom), true);
                }
              }
            },
          );
        }
      }
    },
  );
}
