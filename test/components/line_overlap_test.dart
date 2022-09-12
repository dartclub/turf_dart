import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';
import 'package:turf/src/line_overlap.dart';
import 'package:turf/src/meta/feature.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  FeatureCollection colorize(features, {color = "#F00", width = 25}) {
    var results = <Feature>[];
    featureEach(
      features,
      (Feature currentFeature, int featureIndex) {
        currentFeature.properties = {
          'stroke': color,
          'fill': color,
          "stroke-width": width
        };
        results.add(currentFeature);
      },
    );
    return FeatureCollection(features: results);
  }

  group(
    'line_overlap function',
    () {
      // fixtures = fixtures.filter(({name}) => name.includes('#901'));

      var inDir = Directory('./test/examples/line_overlap/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource))
                  as FeatureCollection;

              String outPath =
                  "./${file.uri.pathSegments.sublist(0, file.uri.pathSegments.length - 2).join('/')}/out/${file.uri.pathSegments.last}";

              var outSource = File(outPath).readAsStringSync();

              var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));

              Equality eq = Equality();
              FeatureCollection shared = colorize(
                  lineOverlap(
                    inGeom.features.first,
                    inGeom.features.last,
                  ),
                  color: "#0F0");
              // print(shared.features);
              // shared.features.forEach(
              //   (element) {
              //     print(element.geometry);
              //     (element.geometry as GeometryType)
              //         .coordinates
              //         .forEach((e) => print("${e.lng}-${e.lat}"));
              //   },
              // );
              FeatureCollection results = FeatureCollection(features: [
                ...shared.features,
                inGeom.features.first,
                inGeom.features.last
              ]);
              // print(results.features.length);
              expect(eq.compare(results, outGeom), isTrue);
            },
          );
        }
      }
      test(
        "turf-line-overlap - Geometry Object",
        () {
          var line1 = LineString(
            coordinates: [
              Position.of([115, -35]),
              Position.of([125, -30]),
              Position.of([135, -30]),
              Position.of([145, -35]),
            ],
          );
          var line2 = LineString(
            coordinates: [
              Position.of([135, -30]),
              Position.of([145, -35]),
            ],
          );

          expect(lineOverlap(line1, line2).features.isNotEmpty, true);
        },
      );

      test(
        "turf-line-overlap - multiple segments on same line",
        () {
          var line1 = LineString(
            coordinates: [
              Position.of([0, 1]),
              Position.of([1, 1]),
              Position.of([1, 0]),
              Position.of([2, 0]),
              Position.of([2, 1]),
              Position.of([3, 1]),
              Position.of([3, 0]),
              Position.of([4, 0]),
              Position.of([4, 1]),
              Position.of([4, 0]),
            ],
          );
          var line2 = LineString(
            coordinates: [
              Position.of([0, 0]),
              Position.of([6, 0]),
            ],
          );
          // multiple segments on same line

          expect(lineOverlap(line1, line2).features.length == 2, true);
          // multiple segments on same line - swapped order
          expect(lineOverlap(line2, line1).features.length == 2, true);
        },
      );
    },
  );
}
