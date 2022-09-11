import 'dart:convert';
import 'dart:io';

import 'package:benchmark/benchmark.dart';
import 'package:turf/polygon_smooth.dart';
import 'package:turf/turf.dart';

void main() {
  group("turf-polygon-smooth", () {
    var inDir = Directory('./test/examples/polygonSmooth/in');
    for (var file in inDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.geojson')) {
        benchmark(file.path, () {
          var inSource = file.readAsStringSync();
          var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
          polygonSmooth(inGeom, iterations: 3);
        });
      }
    }
  });
}
