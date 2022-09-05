import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/src/booleans/boolean_valid.dart';
import 'package:turf/turf.dart';

main() {
  group(
    'boolean-valid',
    () {
      /// Assertion error is caught in the fromJSON factory contructor of [GeometryType]s
      Directory dir = Directory('./test/examples/booleans/valid/assertion');
      for (var file in dir.listSync(recursive: true)) {
        test(
          file.path,
          () {
            // Assertion Error Fixtures
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              expect(
                () => booleanValid(
                  GeoJSONObject.fromJson(
                    jsonDecode(inSource),
                  ),
                ),
                throwsA(isA<AssertionError>()),
              );
            }
          },
        );
      }
      Directory dirFale = Directory('./test/examples/booleans/valid/false');
      for (var file in dirFale.listSync(recursive: true)) {
        test(
          file.path,
          () {
            print(file.path);
            // False Fixtures
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              expect(
                  booleanValid(
                    GeoJSONObject.fromJson(
                      jsonDecode(inSource),
                    ),
                  ),
                  isFalse);
            }
          },
        );
      }
      Directory dir1 = Directory('./test/examples/booleans/valid/true');
      for (var file in dir1.listSync(recursive: true)) {
        test(
          file.path,
          () {
            if (file is File && file.path.endsWith('.geojson')) {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              expect(booleanValid(inGeom), isTrue);
            }
          },
        );
      }
    },
  );
}


/**
 * const glob = require("glob");
const path = require("path");
const test = require("tape");
const load = require("load-json-file");
// const shapely = require('boolean-shapely');
const isValid = require("./index").default;

test("turf-boolean-valid", (t) => {
  // True Fixtures
  glob
    .sync(path.join(__dirname, "test", "true", "**", "*.geojson"))
    .forEach((filepath) => {
      const name = path.parse(filepath).name;

      if (name === "multipolygon-touch") return t.skip("multipolygon-touch");

      const geojson = load.sync(filepath);
      const feature1 = geojson.features[0];
      const result = isValid(feature1);

      // if (process.env.SHAPELY) shapely.contains(feature1).then(result => t.true(result, '[true] shapely - ' + name));
      t.true(result, "[true] " + name);
    });
  // False Fixtures
  glob
    .sync(path.join(__dirname, "test", "false", "**", "*.geojson"))
    .forEach((filepath) => {
      const name = path.parse(filepath).name;
      const geojson = load.sync(filepath);
      const feature1 = geojson.features[0];
      const result = isValid(feature1);

      // if (process.env.SHAPELY) shapely.contains(feature1, feature2).then(result => t.false(result, '[false] shapely - ' + name));
      t.false(result, "[false] " + name);
    });
  t.end();
});

test("turf-boolean-valid -- obvious fails", (t) => {
  t.false(isValid({ foo: "bar" }));
  t.end();
});
 */