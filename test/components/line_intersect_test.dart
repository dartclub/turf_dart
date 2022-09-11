import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/line_intersect.dart';
import 'package:turf/src/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group(
    'line_intersect',
    () {
      Directory dir = Directory('./test/examples/line_intersect/in');
      for (var file in dir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          var inSource = file.readAsStringSync();
          var inGeom =
              GeoJSONObject.fromJson(jsonDecode(inSource)) as FeatureCollection;

          // ignore: prefer_interpolation_to_compose_strings
          var outPath = './' +
              file.uri.pathSegments
                  .sublist(0, file.uri.pathSegments.length - 2)
                  .join('/') +
              '/out/${file.uri.pathSegments.last}';

          var outSource = File(outPath).readAsStringSync();
          var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource))
              as FeatureCollection;

          test(
            "turf-line-intersect",
            () {
              var results = truncate(
                  lineIntersect(inGeom.features.first, inGeom.features.last));
              var coll = FeatureCollection()
                ..features = [...(results as FeatureCollection).features];

              coll.features.add(inGeom.features.first);
              coll.features.add(inGeom.features.last);

              Equality eq = Equality();
              expect(eq.compare(outGeom, coll), isTrue);
            },
          );
        }
      }

      test(
        "turf-line-intersect - prevent input mutation",
        () {
          var line1 = LineString(coordinates: [
            Position.of([7, 50]),
            Position.of([8, 50]),
            Position.of([9, 50]),
          ]);
          var line2 = LineString(coordinates: [
            Position.of([8, 49]),
            Position.of([8, 50]),
            Position.of([8, 51]),
          ]);
          var before1 = line1.toJson();
          var before2 = line2.toJson();

          lineIntersect(line1, line2);
          Equality eq = Equality();
          expect(eq.compare(line1, LineString.fromJson(before1)), true);
          expect(eq.compare(line2, LineString.fromJson(before2)), isTrue);
        },
      );

      test(
        "turf-line-intersect - Geometry Objects",
        () {
          var line1 = LineString(
            coordinates: [
              Position.of([7, 50]),
              Position.of([9, 50]),
            ],
          );
          var line2 = LineString(
            coordinates: [
              Position.of([8, 49]),
              Position.of([8, 51]),
            ],
          );
          //    "support Geometry Objects"
          expect(lineIntersect(line1, line2).features, isNotEmpty);
          //    "support Feature Collection"
          expect(
              lineIntersect(
                  FeatureCollection<LineString>(
                      features: [Feature(geometry: line1)]),
                  FeatureCollection<LineString>(
                      features: [Feature(geometry: line2)])).features,
              isNotEmpty);
          // expect(
          //     lineIntersect(GeometryCollection(geometries: [line1]),
          //         GeometryCollection(geometries: [line2])).features,
          //     isNotEmpty);
        },
      );

      test(
        "turf-line-intersect - same point #688",
        () {
          var line1 = LineString(
            coordinates: [
              Position.of([7, 50]),
              Position.of([8, 50]),
              Position.of([9, 50]),
            ],
          );
          var line2 = LineString(
            coordinates: [
              Position.of([8, 49]),
              Position.of([8, 50]),
              Position.of([8, 51]),
            ],
          );

          var results = lineIntersect(line1, line2);
          expect(results.features.length == 1, true);

          var results2 = lineIntersect(
            line1,
            line2,
            removeDuplicates: false,
          );
          expect(results2.features.length == 3, true);
        },
      );

      test(
        "turf-line-intersect - polygon support #586",
        () {
          var poly1 = Polygon(
            coordinates: [
              [
                Position.of([7, 50]),
                Position.of([8, 50]),
                Position.of([9, 50]),
                Position.of([7, 50]),
              ],
            ],
          );
          var poly2 = Polygon(
            coordinates: [
              [
                Position.of([8, 49]),
                Position.of([8, 50]),
                Position.of([8, 51]),
                Position.of([8, 49]),
              ],
            ],
          );

          var results = lineIntersect(poly1, poly2);
          expect(results.features.length == 1, true);
        },
      );
    },
  );
}
