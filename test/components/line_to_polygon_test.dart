import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/line_to_polygon.dart';

void main() {
  group(
    'lineToPolygon:',
    () {
      var inDir = Directory('./test/examples/lineToPolygon/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var properties = (inGeom is Feature)
                  ? inGeom.properties ?? {"stroke": "#F0F", "stroke-width": 6}
                  : {"stroke": "#F0F", "stroke-width": 6};
              var results = lineToPolygon(
                inGeom,
                properties: properties,
              );

              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();
              var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));

              if (outGeom is Feature) {
                if (outGeom.geometry is Polygon) {
                  outGeom =
                      Feature<Polygon>(geometry: outGeom.geometry as Polygon);
                } else {
                  outGeom = Feature<MultiPolygon>(
                      geometry: outGeom.geometry as MultiPolygon);
                }
              }
              expect(results, equals(outGeom));
            },
          );
        }
        test(
          'Handles Errors',
          () {
            expect(
                () => lineToPolygon(Point(coordinates: Position.of([10, 5]))),
                throwsA(isA<Exception>()));
            expect(() => lineToPolygon(LineString(coordinates: [])),
                throwsA(isA<Exception>()));
            expect(
                lineToPolygon(
                    LineString(coordinates: [
                      Position.of([10, 5]),
                      Position.of([20, 10]),
                      Position.of([30, 20]),
                    ]),
                    autoComplete: false) is Feature<Polygon>,
                true);
          },
        );
      }
    },
  );
}
