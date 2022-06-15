import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/src/explode.dart';
import 'package:turf/turf.dart';

main() {
  group(
    'explode in == out',
    () {
      var inDir = Directory('./test/examples/explode/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var inExploded = explode(inGeom);

              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();
              var outGeom =
                  FeatureCollection<Point>.fromJson(jsonDecode(outSource));

              for (var i = 0; i < inExploded.features.length; i++) {
                var input = inExploded.features[i];
                var output = outGeom.features[i];
                expect(input.id, output.id);
                expect(input.properties, equals(output.properties));
                expect(input.geometry, output.geometry);
              }
            },
          );
        }
      }
    },
  );
}
