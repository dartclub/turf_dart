import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/truncate.dart';

main() {
  group(
    'truncate',
    () {
      // var inDir = Directory('./test/examples/truncate/in');
      // for (var file in inDir.listSync(recursive: true)) {
      //   if (file is File && file.path.endsWith('.geojson')) {
      //     var inSource = file.readAsStringSync();
      //     var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
      //     Map<String, dynamic> json = jsonDecode(inSource);
      //     var coordinates = json['coordinates'];
      //     var precision = json['precision'];

      //     var outDir = Directory('./test/examples/truncate/out');
      //     for (var file in outDir.listSync(recursive: true)) {
      //       if (file is File && file.path.endsWith('.geojson')) {
      //         test(
      //           file.path,
      //           () {
      //             var outSource = file.readAsStringSync();
      //             var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));

      //             expect(
      //                 truncate(inGeom,
      //                     coordinates: coordinates, precision: precision),
      //                 equals(outGeom));
      //           },
      //         );
      //       }
      //     }
      //   }
      // }

      test(
        "turf-truncate - precision & coordinates",
        () {
          // "precision 3"
          expect(
            (truncate(Point(coordinates: Position.of([50.1234567, 40.1234567])),
                    precision: 3) as Point)
                .coordinates,
            equals(Position.of([50.123, 40.123])),
          );
          // "precision 0"

          expect(
            truncate(Point(coordinates: Position.of([50.1234567, 40.1234567])),
                precision: 0),
            equals(
              Position.of([50, 40]),
            ),
          );
          // "coordinates default to 3"

          expect(
            truncate(Point(coordinates: Position.of([50, 40, 1100])),
                precision: 6),
            equals(Position.of([50, 40, 1100])),
          );
          // "coordinates 2"

          expect(
            truncate(Point(coordinates: Position.of([50, 40, 1100])),
                precision: 6, coordinates: 2),
            [50, 40],
          );
        },
      );

      // test(
      //   "turf-truncate - prevent input mutation",
      //   () {
      //     var pt = Point(coordinates: Position.of([120.123, 40.123, 3000]));
      //     Point ptBefore = pt.clone();

      //     truncate(pt, precision: 0);
      //     // "does not mutate input"
      //     expect(
      //         (ptBefore.coordinates.lat == pt.coordinates.lat &&
      //             ptBefore.coordinates.lng == pt.coordinates.lng &&
      //             ptBefore.coordinates.alt == pt.coordinates.alt),
      //         false);

      //     truncate(pt, precision: 0, coordinates: 2, mutate: true);
      //     //  "does mutate input"
      //     expect(pt.coordinates,
      //         equals(Point(coordinates: Position.of([120, 40])).coordinates));
      //   },
      // );
    },
  );
}
