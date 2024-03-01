import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/src/centroid.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/transform_rotate.dart';
import 'package:turf/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group(
    'transform_rotate',
    () {
      test('transform_rotate -- mutated input', () {
        Equality eq = Equality();
        final line = Feature<LineString>(
          geometry: LineString.fromJson({
            'coordinates': [
              [10, 10],
              [12, 15],
            ]
          }),
        );
        final lineBefore = line.clone();
        final rotatedMatcher = Feature<LineString>(
          geometry: LineString.fromJson({
            'coordinates': [
              [8.6, 13.9],
              [13.3, 11.1],
            ]
          }),
        );

        transformRotate(line, 100);

        expect(eq.compare(line, lineBefore), true,
            reason: 'input should NOT be mutated');

        transformRotate(line, 100, mutate: true);

        expect(eq.compare(truncate(line, precision: 1), rotatedMatcher), true,
            reason: "input should be mutated");
      });

      Directory inDir = Directory('./test/examples/transform_rotate/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var feature = Feature.fromJson(jsonDecode(inSource));

              final angle = feature.properties?['angle'];
              var pivot = feature.properties?['pivot'];
              pivot =
                  pivot == null ? null : Point.fromJson({'coordinates': pivot});

              final rotated = transformRotate(
                feature,
                angle,
                pivot: pivot,
              );

              final truncated = truncate(
                rotated as Feature<GeometryObject>,
                precision: 6,
                coordinates: 3,
              );

              final result = FeatureCollection()
                ..features = [
                  colorize(truncated),
                  feature,
                  makePivot(pivot, feature),
                ];

              Directory outDir =
                  Directory('./test/examples/transform_rotate/out');
              for (var file2 in outDir.listSync(recursive: true)) {
                if (file2 is File &&
                    file2.uri.pathSegments.last == file.uri.pathSegments.last) {
                  var outSource = file2.readAsStringSync();
                  var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
                  Equality eq = Equality();
                  expect(eq.compare(result, outGeom), true);
                }
              }
            },
          );
        }
      }
    },
  );
}

Feature<GeometryObject> colorize(GeoJSONObject geojson) {
  final feature = geojson as Feature<GeometryObject>;
  if (feature.geometry?.type == GeoJSONObjectType.point ||
      feature.geometry?.type == GeoJSONObjectType.multiPoint) {
    feature.properties?.putIfAbsent("marker-color", () => "#F00");
    feature.properties?.putIfAbsent("marker-symbol", () => "star");
  } else {
    feature.properties?.putIfAbsent("stroke", () => "#F00");
    feature.properties?.putIfAbsent("stroke-width", () => 4);
  }
  return feature;
}

Feature<Point> makePivot(Point? pivot, GeoJSONObject geojson) {
  if (pivot == null) {
    return centroid(geojson, properties: {"marker-symbol": "circle"});
  }
  return Feature<Point>(
      geometry: Point(coordinates: getCoord(pivot)),
      properties: {"marker-symbol": "circle"});
}
