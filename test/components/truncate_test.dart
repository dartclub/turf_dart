import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/truncate.dart';

_testIt(GeoJSONObject inGeom, int coordinates, int precision, File file1,
    File file2) {
  if (inGeom is FeatureCollection) {
    for (var element in inGeom.features) {
      _testIt(element, coordinates, precision, file1, file2);
    }
  }
  inGeom = inGeom is Feature ? inGeom.geometry! : inGeom;
  test(
    file2.path,
    () {
      var outSource = file2.readAsStringSync();
      var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
      if (outGeom is GeometryCollection) {
        for (var i = 0; i < outGeom.geometries.length; i++) {
          expect(
              ((truncate(inGeom,
                      coordinates: coordinates,
                      precision: precision)) as GeometryCollection)
                  .geometries[i]
                  .coordinates,
              equals((outGeom).geometries[i].coordinates));
        }
      } else if (outGeom is Point) {
        expect(
            ((truncate(inGeom, coordinates: coordinates, precision: precision))
                    as Point)
                .coordinates,
            equals((outGeom).coordinates));
      } else if (outGeom is LineString) {
        for (var i = 0; i < outGeom.coordinates.length; i++) {
          expect(
              ((truncate(inGeom,
                      coordinates: coordinates,
                      precision: precision)) as LineString)
                  .coordinates[i],
              equals((outGeom).coordinates[i]));
        }
      } else if (outGeom is Polygon || outGeom is MultiLineString) {
        for (var i = 0; i < (outGeom as GeometryType).coordinates.length; i++) {
          for (var j = 0; j < outGeom.coordinates.length; j++) {
            expect(
                ((truncate(inGeom,
                        coordinates: coordinates,
                        precision: precision)) as GeometryType)
                    .coordinates[i][j],
                equals((outGeom).coordinates[i][j]));
          }
        }
      } else if (outGeom is MultiPolygon) {
        for (var i = 0; i < outGeom.coordinates.length; i++) {
          for (var j = 0; j < outGeom.coordinates.length; j++) {
            for (var k = 0; k < outGeom.coordinates.length; k++) {
              expect(
                  ((truncate(inGeom,
                          coordinates: coordinates,
                          precision: precision)) as Polygon)
                      .coordinates[i][j][k],
                  equals((outGeom).coordinates[i][j][k]));
            }
          }
        }
      }
    },
  );
}

main() {
  group(
    'truncate',
    () {
      var inDir = Directory('./test/examples/truncate/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          var inSource = file.readAsStringSync();
          var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
          Map<String, dynamic> json = jsonDecode(inSource);
          var coordinates = json['properties']?['coordinates'];
          var precision = json['properties']?['precision'];

          var outDir = Directory('./test/examples/truncate/out');
          for (var file2 in outDir.listSync(recursive: true)) {
            if (file2 is File &&
                file2.path.endsWith('.geojson') &&
                file2.uri.pathSegments.last == file.uri.pathSegments.last) {
              _testIt(inGeom, coordinates ?? 3, precision ?? 6, file, file2);
            }
          }
        }
      }

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
            (truncate(Point(coordinates: Position.of([50.1234567, 40.1234567])),
                    precision: 0) as Point)
                .coordinates,
            equals(
              Position.of([50, 40]),
            ),
          );
          // "coordinates default to 3"
          expect(
            (truncate(Point(coordinates: Position.of([50, 40, 1100])),
                    precision: 6) as Point)
                .coordinates,
            equals(Position.of([50, 40, 1100])),
          );
          // "coordinates 2"
          expect(
            (truncate(Point(coordinates: Position.of([50, 40, 1100])),
                    precision: 6, coordinates: 2) as Point)
                .coordinates,
            Position.of([50, 40]),
          );
        },
      );

      test(
        "turf-truncate - prevent input mutation",
        () {
          var pt = Point(coordinates: Position.of([120.123, 40.123, 3000]));
          Point ptBefore = pt.clone();
          Point afterPoint = truncate(pt, precision: 0) as Point;
          // "does not mutate input"
          expect(
              (ptBefore.coordinates.lat == afterPoint.coordinates.lat &&
                  ptBefore.coordinates.lng == afterPoint.coordinates.lng &&
                  ptBefore.coordinates.alt == afterPoint.coordinates.alt),
              false);

          // "does mutate input"
          truncate(pt, precision: 0, coordinates: 2, mutate: true);
          expect(pt.coordinates,
              equals(Point(coordinates: Position.of([120, 40])).coordinates));
        },
      );
    },
  );
}
