import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

void main() {
  group(
    'rhumb_distance',
    () {
      test('calculateRhumbDistance -- raw parameters', () {
        final matcher = 40.31;
        final p1 = Position(1.338, 51.127);
        final p2 = Position(1.853, 50.964);

        final distanceInMeters = calculateRhumbDistance(p1, p2);
        final distance = round(
            convertLength(distanceInMeters, Unit.meters, Unit.kilometers), 2);

        expect(distance, matcher);
      });

      test('rhumbDistance -- raw parameters', () {
        final matcher = 40.31;
        final pt1 = Point(coordinates: Position(1.338, 51.127));
        final pt2 = Point(coordinates: Position(1.853, 50.964));

        final distance = round(rhumbDistance(pt1, pt2), 2);

        expect(distance, matcher);
      });

      Directory inDir = Directory('./test/examples/rhumb_distance/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom =
                  FeatureCollection<Point>.fromJson(jsonDecode(inSource));

              final pt1 = inGeom.features[0].geometry!;
              final pt2 = inGeom.features[1].geometry!;

              final distances = {
                'miles': round(rhumbDistance(pt1, pt2, Unit.miles), 6),
                'nauticalmiles':
                    round(rhumbDistance(pt1, pt2, Unit.nauticalmiles), 6),
                'kilometers':
                    round(rhumbDistance(pt1, pt2, Unit.kilometers), 6),
                'greatCircleDistance':
                    round(distance(pt1, pt2, Unit.kilometers), 6),
                'radians': round(rhumbDistance(pt1, pt2, Unit.radians), 6),
                'degrees': round(rhumbDistance(pt1, pt2, Unit.degrees), 6),
              };

              Directory outDir =
                  Directory('./test/examples/rhumb_distance/out');
              for (var file2 in outDir.listSync(recursive: true)) {
                if (file2 is File &&
                    file.path.endsWith('.json') &&
                    file2.uri.pathSegments.last == file.uri.pathSegments.last) {
                  var outSource = jsonDecode(file.readAsStringSync());
                  final isEqual = distances.keys
                      .every((key) => distances[key] == outSource[key]);
                  expect(isEqual, true);
                }
              }
            },
          );
        }
      }
    },
  );
}
