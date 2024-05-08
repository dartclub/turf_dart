import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group(
    'truncate',
    () {
      var inDir = Directory('./test/examples/truncate/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          var inSource = file.readAsStringSync();
          var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
          Map<String, dynamic> json = jsonDecode(inSource);
          var coordinates = json['properties']?['coordinates'];
          var precision = json['properties']?['precision'];

          var outDir = Directory('./test/examples/truncate/out');
          for (var file2 in outDir.listSync(recursive: true)) {
            if (file2 is File &&
                file2.path.endsWith('.geojson') &&
                file2.uri.pathSegments.last == file.uri.pathSegments.last) {
              test(
                file2.path,
                () {
                  var outSource = file2.readAsStringSync();
                  var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
                  Equality eq = Equality();
                  expect(
                      eq.compare(
                          truncate(inGeom,
                              coordinates: coordinates ?? 3,
                              precision: precision ?? 6),
                          outGeom),
                      true);
                },
              );
            }
          }
        }
      }

      test(
        "turf-truncate - precision & coordinates",
        () {
          Equality eq = Equality();
          // "precision 3"
          expect(
              eq.compare(
                truncate(
                    Point(coordinates: Position.of([50.1234567, 40.1234567])),
                    precision: 3),
                Point(coordinates: Position.of([50.123, 40.123])),
              ),
              true);
          // "precision 0"
          expect(
              eq.compare(
                  truncate(
                      Point(coordinates: Position.of([50.1234567, 40.1234567])),
                      precision: 0),
                  Point(coordinates: Position.of([50, 40]))),
              true);
          // "coordinates default to 3"
          expect(
              eq.compare(
                  truncate(Point(coordinates: Position.of([50, 40, 1100])),
                      precision: 6),
                  Point(coordinates: Position.of([50, 40, 1100]))),
              true);
          // "coordinates 2"
          expect(
              eq.compare(
                truncate(Point(coordinates: Position.of([50, 40, 1100])),
                    precision: 6, coordinates: 2),
                Point(coordinates: Position.of([50, 40])),
              ),
              true);
        },
      );

      test(
        "turf-truncate - prevent input mutation",
        () {
          var pt = Point(coordinates: Position.of([120.123, 40.123, 3000]));
          Point ptBefore = pt.clone();
          Point afterPoint = truncate(pt, precision: 0) as Point;
          // "does not mutate input"
          expect(
              (ptBefore.coordinates.lat == afterPoint.coordinates.lat &&
                  ptBefore.coordinates.lng == afterPoint.coordinates.lng &&
                  ptBefore.coordinates.alt == afterPoint.coordinates.alt),
              false);

          // "does mutate input"
          truncate(pt, precision: 0, coordinates: 2, mutate: true);
          Equality eq = Equality();
          expect(
              eq.compare(pt, Point(coordinates: Position.of([120, 40]))), true);
        },
      );
    },
  );
}
