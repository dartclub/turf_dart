import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/destination.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/truncate.dart';
import 'package:turf_equality/turf_equality.dart';

void main() {
  group(
    'rhumb_destination',
    () {
      test('rhumb-destintation -- add properties', () {
        final props = {'foo': 'bar'};
        final pt = Feature<Point>(
          geometry: Point(coordinates: Position(12, -54)),
          properties: props,
        );
        final out = rhumbDestination(pt.geometry!, 0, 45, properties: {'foo': 'bar'});

        final isEqual = out.properties != null && out.properties!.keys.every((k) => props[k] == out.properties?[k]);
        expect(isEqual, true);
      });

      test('rhumb-destintation -- allows negative distance', () {
        final matcher = Point(coordinates: Position(10.90974456038191, -54.63591552764877));
        final pt = Point(coordinates: Position(12, -54));

        final out = rhumbDestination(pt, -100, 45);

        expect(out.geometry!, matcher);
      });

      Directory inDir = Directory('./test/examples/rhumb_destination/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var feature = Feature<Point>.fromJson(jsonDecode(inSource));

              final bearing = feature.properties?['bearing'] ?? 180;
              final dist = feature.properties?['dist'] ?? 100;
              final unitName = feature.properties?['units'];
              final unit = unitName == null ? null : Unit.values.byName(unitName);

              final destinationPoint = rhumbDestination(
                feature.geometry!,
                dist,
                bearing,
                unit: unit,
                properties: feature.properties,
              );

              final line = truncate(
                Feature<LineString>(
                    geometry: LineString(coordinates: [getCoord(feature), getCoord(destinationPoint)]),
                    properties: {
                      'stroke': "#F00",
                      "stroke-width": 4,
                    }),
              ) as Feature<LineString>;

              feature.properties ??= const {};
              feature.properties?.putIfAbsent('marker-color', () => "#F00");

              final result = FeatureCollection<GeometryObject>(features: [line, feature, destinationPoint]);

              Directory outDir = Directory('./test/examples/rhumb_destination/out');
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
