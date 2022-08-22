import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/polygon_smooth.dart';
import 'package:turf/turf.dart';
import 'package:turf_equality/turf_equality.dart';

main() {
  group("turf-polygon-smooth", () {
    var inDir = Directory('./test/examples/polygonSmooth/in');
    for (var file in inDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.geojson')) {
        test(file.path, () {
          var inSource = file.readAsStringSync();
          var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
          var results = polygonSmooth(inGeom, iterations: 3);
          var outPath = './' +
              file.uri.pathSegments
                  .sublist(0, file.uri.pathSegments.length - 2)
                  .join('/') +
              '/out/${file.uri.pathSegments.last}';

          var outSource = File(outPath).readAsStringSync();
          var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));

          Equality eq = Equality();
          expect(eq.compare(results, outGeom), true);
        });
      }
    }
    test("turf-polygon-smooth -- options are optional", () {
      var poly = Polygon(coordinates: [
        [
          Position(0, 0),
          Position(1, 0),
          Position(1, 1),
          Position(0, 1),
          Position(0, 0),
        ],
      ]);
      Future<void> _compare() async {
        polygonSmooth(poly);
      }

      expect(_compare(), completes);
    });
  });
}
