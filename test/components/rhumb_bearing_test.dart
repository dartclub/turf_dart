import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/rhumb_bearing.dart';

main() {
  group(
    '',
    () {
      Directory inDir = Directory('./test/examples/rhumb_bearing/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));

              var start = (inGeom as FeatureCollection).features[0];
              var end = inGeom.features[1];
              var initialBearing =
                  rhumbBearing(start.geometry as Point, end.geometry as Point);
              var finalBearing = rhumbBearing(
                  start.geometry as Point, end.geometry as Point,
                  kFinal: true);
              var result = {
                "initialBearing": initialBearing,
                "finalBearing": finalBearing,
              };
              Directory outDir = Directory('./test/examples/rhumb_bearing/out');

              for (var file in outDir.listSync(recursive: true)) {
                if (file is File && file.path.endsWith('.json')) {
                  var outSource = jsonDecode(file.readAsStringSync());
                  // expect(result, outSource);
                }
              }
            },
          );
        }
      }
    },
  );
}
