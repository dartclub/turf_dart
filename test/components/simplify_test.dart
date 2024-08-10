import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/simplify.dart';

main() {
  group(
    'simplify in == out',
    () {
      var inDir = Directory('./test/examples/simplify/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = Feature<LineString>.fromJson(jsonDecode(inSource));

              var inSimplified = simplify(
                inGeom,
                tolerance: inGeom.properties?['tolerance'] ?? 0.01,
                highestQuality: inGeom.properties?['highQuality'] ?? false,
              );

              // ignore: prefer_interpolation_to_compose_strings
              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();
              var outGeom = Feature<LineString>.fromJson(jsonDecode(outSource));

              final precision = 0.0001;
              expect(inSimplified.id, outGeom.id);
              expect(inSimplified.properties, equals(outGeom.properties));
              expect(inSimplified.geometry, isNotNull);
              expect(
                  _roundCoords(inSimplified.geometry!.coordinates, precision),
                  _roundCoords(outGeom.geometry!.coordinates, precision));
            },
          );
        }
      }
    },
  );
  test(
    'simplify retains id, properties and bbox',
    () {
      const properties = {"foo": "bar"};
      const id = 12345;
      final bbox = BBox(0, 0, 2, 2);
      final poly = Feature<LineString>(
        geometry: LineString(coordinates: [
          Position(0, 0),
          Position(2, 2),
          Position(2, 0),
          Position(0, 0),
        ]),
        properties: properties,
        bbox: bbox,
        id: id,
      );
      final simple = simplify(poly, tolerance: 0.1);

      expect(simple.id, equals(id));
      expect(simple.bbox, equals(bbox));
      expect(simple.properties, equals(properties));
    },
  );
}

List<Position> _roundCoords(List<Position> coords, num precision) {
  return coords
      .map((p) => Position(_round(p.lng, precision), _round(p.lat, precision)))
      .toList();
}

num _round(num value, num precision) {
  return (value / precision).roundToDouble() * precision;
}
