import 'dart:convert';
import 'dart:io';

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:turf/polygon_to_line.dart';
import 'package:turf/turf.dart';

void main() {
  group(
    'polygonToLine',
    () {
      var inDir = Directory('./test/examples/polygonToLine/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var results = polygonToLine(inGeom);

              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();
              var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
              if (results is FeatureCollection) {
                expect(outGeom is FeatureCollection, true);
                for (var i = 0; i < results.features.length; i++) {
                  expect(results.features[i],
                      equals((outGeom as FeatureCollection).features[i]));
                  expect(
                    (results.features[i].geometry as GeometryType).coordinates,
                    equals((outGeom.features[i].geometry as GeometryType)
                        .coordinates),
                  );
                  expect(
                    results.features[i].properties,
                    equals(outGeom.features[i].properties),
                  );
                }
              } else if (results is Feature) {
                expect(outGeom is Feature, true);
                expect((outGeom as Feature).properties,
                    equals(results.properties));
                expect((results.geometry as GeometryType).type,
                    equals((outGeom.geometry)?.type));
                expect((results.geometry as GeometryType).coordinates,
                    equals((outGeom.geometry as GeometryType).coordinates));
              }
            },
          );
          test(
            "handles error",
            () {
              // Handle Errors
              expect(
                  () => polygonToLine(Point(coordinates: Position.of([10, 5]))),
                  throwsA(isA<Exception>()));
              expect(() => polygonToLine(Polygon(coordinates: [])),
                  throwsA(isA<RangeError>()));
            },
          );
        }
      }
    },
  );
}
