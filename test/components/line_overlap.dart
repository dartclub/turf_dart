import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
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
          if (file.path.contains('#901')) {
            test(
              file.path,
              () {
                var inSource = file.readAsStringSync();
                var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource))
                    as FeatureCollection;

                var outPath = './' +
                    file.uri.pathSegments
                        .sublist(0, file.uri.pathSegments.length - 2)
                        .join('/') +
                    '/out/${file.uri.pathSegments.last}';

                var outSource = File(outPath).readAsStringSync();

                var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));

                Equality eq = Equality();
                FeatureCollection shared = colorize(
                    lineOverlap(inGeom.features[0], inGeom.features[1],
                        tolerance: 0.05),
                    color: "#0F0");
                FeatureCollection results = FeatureCollection(features: [
                  ...shared.features,
                  inGeom.features.first,
                  inGeom.features.last
                ]);
                expect(eq.compare(results, outGeom), true);
              },
            );
          }
        }
      }
      // test(
      //   "turf-line-overlap - Geometry Object",
      //   () {
      //     var line1 = LineString(
      //       coordinates: [
      //         Position.of([115, -35]),
      //         Position.of([125, -30]),
      //         Position.of([135, -30]),
      //         Position.of([145, -35]),
      //       ],
      //     );
      //     var line2 = LineString(
      //       coordinates: [
      //         Position.of([135, -30]),
      //         Position.of([145, -35]),
      //       ],
      //     );

      //     expect(lineOverlap(line1, line2).features.isNotEmpty, true);
      //   },
      // );

      // test(
      //   "turf-line-overlap - multiple segments on same line",
      //   () {
      //     var line1 = LineString(
      //       coordinates: [
      //         Position.of([0, 1]),
      //         Position.of([1, 1]),
      //         Position.of([1, 0]),
      //         Position.of([2, 0]),
      //         Position.of([2, 1]),
      //         Position.of([3, 1]),
      //         Position.of([3, 0]),
      //         Position.of([4, 0]),
      //         Position.of([4, 1]),
      //         Position.of([4, 0]),
      //       ],
      //     );
      //     var line2 = LineString(
      //       coordinates: [
      //         Position.of([0, 0]),
      //         Position.of([6, 0]),
      //       ],
      //     );

      //     expect(lineOverlap(line1, line2).features.length == 2, true);
      //     expect(lineOverlap(line2, line1).features.length == 2, true);
      //   },
      // );
    },
  );
}

/**
 * const fs = require("fs");
const test = require("tape");
const path = require("path");
const load = require("load-json-file");
const write = require("write-json-file");
const { featureEach } = require("@turf/meta");
const { featureCollection, lineString } = require("@turf/helpers");
const lineOverlap = require("./index").default;

const directories = {
  in: path.join(__dirname, "test", "in") + path.sep,
  out: path.join(__dirname, "test", "out") + path.sep,
};

let fixtures = fs.readdirSync(directories.in).map((filename) => {
  return {
    filename,
    name: path.parse(filename).name,
    geojson: load.sync(directories.in + filename),
  };
});
// fixtures = fixtures.filter(({name}) => name.includes('#901'));

test("turf-line-overlap", (t) => {
  for (const { filename, name, geojson } of fixtures) {
    const [source, target] = geojson.features;
    const shared = colorize(
      lineOverlap(source, target, geojson.properties),
      "#0F0"
    );
    const results = featureCollection(shared.features.concat([source, target]));

    if (process.env.REGEN) write.sync(directories.out + filename, results);
    t.deepEquals(results, load.sync(directories.out + filename), name);
  }
  t.end();
});

test("turf-line-overlap - Geometry Object", (t) => {
  const line1 = lineString([
    [115, -35],
    [125, -30],
    [135, -30],
    [145, -35],
  ]);
  const line2 = lineString([
    [135, -30],
    [145, -35],
  ]);

  t.true(
    lineOverlap(line1.geometry, line2.geometry).features.length > 0,
    "support geometry object"
  );
  t.end();
});

test("turf-line-overlap - multiple segments on same line", (t) => {
  const line1 = lineString([
    [0, 1],
    [1, 1],
    [1, 0],
    [2, 0],
    [2, 1],
    [3, 1],
    [3, 0],
    [4, 0],
    [4, 1],
    [4, 0],
  ]);
  const line2 = lineString([
    [0, 0],
    [6, 0],
  ]);

  t.true(
    lineOverlap(line1.geometry, line2.geometry).features.length === 2,
    "multiple segments on same line"
  );
  t.true(
    lineOverlap(line2.geometry, line1.geometry).features.length === 2,
    "multiple segments on same line - swapped order"
  );
  t.end();
});

function colorize(features, color = "#F00", width = 25) {
  const results = [];
  featureEach(features, (feature) => {
    feature.properties = {
      stroke: color,
      fill: color,
      "stroke-width": width,
    };
    results.push(feature);
  });
  if (features.type === "Feature") return results[0];
  return featureCollection(results);
}
 */
