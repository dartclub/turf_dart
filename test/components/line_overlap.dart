import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/line_overlap.dart';
import 'package:turf/src/meta/feature.dart';
import 'package:turf_equality/turf_equality.dart';

 
main(){
  group('line_overlap function',(){
    // fixtures = fixtures.filter(({name}) => name.includes('#901'));


var inDir = Directory('./test/examples/line_overlaps/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
          
              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();
            
              var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));


                  FeatureCollection<LineString> results = lineOverlap((inGeom as FeatureCollection<LineString>).features.first, inGeom.features.last);
              Equality eq = Equality();
              expect(eq.compare(results, outGeom), true); 

test("turf-line-overlap", () {

     shared = colorize(
      lineOverlap(source, target, tolerance: geojson.properties),
      "#0F0"
    );
    var
     results = FeatureCollection(features: [...shared.features, source, target]);

    t.deepEquals(results, load.sync(directories.out + filename), name);
  }
});

test("turf-line-overlap - Geometry Object", () {
  var line1 = LineString(coordinates:[
    Position.of([115, -35]),
    Position.of([125, -30]),
    Position.of([135, -30]),
    Position.of([145, -35]),
  ]);
  var
   line2 = LineString(coordinates:[
    Position.of([135, -30]),
    Position.of([145, -35]),
  ]);

  t.true(
    lineOverlap(line1.geometry, line2.geometry).features.length > 0,
    "support geometry object"
  );
  t.end();
});

test("turf-line-overlap - multiple segments on same line", () {
  var
   line1 = LineString(coordinates:[
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
  ]);
  var
   line2 = LineString(coordinates:[
    Position.of([0, 0]),
    Position.of([6, 0]),
  ]);

  t.true(
    lineOverlap(line1.geometry, line2.geometry).features.length == 2,
    "multiple segments on same line"
  );
  t.true(
    lineOverlap(line2.geometry, line1.geometry).features.length ==2,
    "multiple segments on same line - swapped order"
  );
  t.end();
});

 colorize(features, {color = "#F00", width = 25}) {
  var
   results = <Feature>[];
  featureEach(features, (  Feature currentFeature,
  int featureIndex) {
    currentFeature.properties = {
      'stroke': color,
      'fill': color,
      "stroke-width": width};
    results.add(currentFeature);
  },);
  if (features is List<Feature>) return results[0];
  return FeatureCollection(features: results);
  }
  },);
}

