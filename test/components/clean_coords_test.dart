import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/clean_coords.dart';
import 'package:turf/src/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group(
    'cleanCoords',
    () {
      var inDir = Directory('./test/examples/cleanCoords/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              Feature results = cleanCoords(inGeom);
              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();
              var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
              Equality eq = Equality();
              expect(eq.compare(results, outGeom), true);
            },
          );
        }
      }

      test(
        "turf-clean-coords -- extras",
        () {
          expect(
              ((cleanCoords(Point(coordinates: Position.of([0, 0])))).geometry!
                      as GeometryType)
                  .coordinates
                  .length,
              2);
          expect(
              (cleanCoords(LineString(
                coordinates: [
                  Position.of([0, 0]),
                  Position.of([1, 1]),
                  Position.of([2, 2]),
                ],
              )).geometry! as GeometryType)
                  .coordinates
                  .length,
              2);
          expect(
              ((cleanCoords(Polygon(
                coordinates: [
                  [
                    Position.of([0, 0]),
                    Position.of([1, 1]),
                    Position.of([2, 2]),
                    Position.of([0, 2]),
                    Position.of([0, 0]),
                  ],
                ],
              ))).geometry! as GeometryType)
                  .coordinates[0]
                  .length,
              4);
          expect(
            ((cleanCoords(MultiPoint(
              coordinates: [
                Position.of([0, 0]),
                Position.of([0, 0]),
                Position.of([2, 2]),
              ],
            ))).geometry! as GeometryType)
                .coordinates
                .length,
            2,
          );
        },
      );

      test(
        "turf-clean-coords -- truncate",
        () {
          expect(
            (cleanCoords(truncate(
                        LineString(
                          coordinates: [
                            Position.of([0, 0]),
                            Position.of([1.1, 1.123]),
                            Position.of([2.12, 2.32]),
                            Position.of([3, 3]),
                          ],
                        ),
                        precision: 0))
                    .geometry! as GeometryType)
                .coordinates
                .length,
            2,
          );
        },
      );

      test(
        "turf-clean-coords -- prevent input mutation",
        () {
          var line = LineString(
            coordinates: [
              Position.of([0, 0]),
              Position.of([1, 1]),
              Position.of([2, 2]),
            ],
          );
          var lineBefore = line.clone();
          cleanCoords(line);
          Equality eq = Equality();
          expect(eq.compare(line, lineBefore), true);

          var multiPoly = MultiPolygon(
            coordinates: [
              [
                [
                  Position.of([0, 0]),
                  Position.of([1, 1]),
                  Position.of([2, 2]),
                  Position.of([2, 0]),
                  Position.of([0, 0]),
                ],
              ],
              [
                [
                  Position.of([0, 0]),
                  Position.of([0, 5]),
                  Position.of([5, 5]),
                  Position.of([5, 5]),
                  Position.of([5, 0]),
                  Position.of([0, 0]),
                ],
              ],
            ],
          );
          var multiPolyBefore = multiPoly.clone();
          cleanCoords(multiPoly);
          Equality eq1 = Equality();

          expect(eq1.compare(multiPolyBefore, multiPoly), true);
        },
      );
    },
  );
}
