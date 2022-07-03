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
                'initialBearing': initialBearing,
                'finalBearing': finalBearing,
              };

              Directory outDir = Directory('./test/examples/rhumb_bearing/out');
              for (var file in outDir.listSync(recursive: true)) {
                if (file is File && file.path.endsWith('.json')) {
                  var outSource = jsonDecode(file.readAsStringSync());
                  expect(result, outSource);
                }
              }
            },
          );
        }
      }
    },
  );
}

/*
const fs = require("fs");
const path = require("path");
const test = require("tape");
const load = require("load-json-file");
const write = require("write-json-file");
const { point } = require("@turf/helpers");
const rhumbBearing = require("./index").default;

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

test("bearing", (t) => {
  fixtures.forEach((fixture) => {
    const name = fixture.name;
    const geojson = fixture.geojson;

    const start = geojson.features[0];
    const end = geojson.features[1];

    const initialBearing = rhumbBearing(start, end);
    const finalBearing = rhumbBearing(start, end, { final: true });

    const result = {
      initialBearing: initialBearing,
      finalBearing: finalBearing,
    };
    if (process.env.REGEN) write.sync(directories.out + name + ".json", result);
    t.deepEqual(load.sync(directories.out + name + ".json"), result, name);
  });

  t.throws(() => {
    rhumbBearing(point([12, -54]), "point");
  }, "invalid point");
  t.end();
});
*/
