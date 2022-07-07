import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/clean_coords.dart';
import 'package:turf/src/truncate.dart';

main() {
  group(
    'cleanCoords',
    () {
      var inDir = Directory('./test/examples/cleanCoords/in');
      for (var file in inDir.listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.geojson')) {
          test(
            file.path,
            () {
              var inSource = file.readAsStringSync();
              var inGeom = GeoJSONObject.fromJson(jsonDecode(inSource));
              var results = cleanCoords(inGeom);
              var outPath = './' +
                  file.uri.pathSegments
                      .sublist(0, file.uri.pathSegments.length - 2)
                      .join('/') +
                  '/out/${file.uri.pathSegments.last}';

              var outSource = File(outPath).readAsStringSync();
              var outGeom = GeoJSONObject.fromJson(jsonDecode(outSource));
              Equality eq = Equality();
              expect(eq.compare(results, outGeom), true);
            },
          );
        }
      }

      test(
        "turf-clean-coords -- extras",
        () {
          expect(
              (cleanCoords(Point(coordinates: Position.of([0, 0]))) as Point)
                  .coordinates
                  .length,
              2);
          expect(
              (cleanCoords(LineString(
                coordinates: [
                  Position.of([0, 0]),
                  Position.of([1, 1]),
                  Position.of([2, 2]),
                ],
              )) as LineString)
                  .coordinates
                  .length,
              2);
          expect(
              (cleanCoords(Polygon(
                coordinates: [
                  [
                    Position.of([0, 0]),
                    Position.of([1, 1]),
                    Position.of([2, 2]),
                    Position.of([0, 2]),
                    Position.of([0, 0]),
                  ],
                ],
              )) as Polygon)
                  .coordinates[0]
                  .length,
              4);
          expect(
            (cleanCoords(MultiPoint(
              coordinates: [
                Position.of([0, 0]),
                Position.of([0, 0]),
                Position.of([2, 2]),
              ],
            )) as MultiPoint)
                .coordinates
                .length,
            2,
          );
        },
      );

      test(
        "turf-clean-coords -- truncate",
        () {
          expect(
            (cleanCoords(truncate(
                    LineString(
                      coordinates: [
                        Position.of([0, 0]),
                        Position.of([1.1, 1.123]),
                        Position.of([2.12, 2.32]),
                        Position.of([3, 3]),
                      ],
                    ),
                    precision: 0)) as LineString)
                .coordinates
                .length,
            2,
          );
        },
      );

      test(
        "turf-clean-coords -- prevent input mutation",
        () {
          var line = LineString(
            coordinates: [
              Position.of([0, 0]),
              Position.of([1, 1]),
              Position.of([2, 2]),
            ],
          );
          var lineBefore = line.clone();
          cleanCoords(line);
          Equality eq = Equality();
          expect(eq.compare(line, lineBefore), true);

          var multiPoly = MultiPolygon(
            coordinates: [
              [
                [
                  Position.of([0, 0]),
                  Position.of([1, 1]),
                  Position.of([2, 2]),
                  Position.of([2, 0]),
                  Position.of([0, 0]),
                ],
              ],
              [
                [
                  Position.of([0, 0]),
                  Position.of([0, 5]),
                  Position.of([5, 5]),
                  Position.of([5, 5]),
                  Position.of([5, 0]),
                  Position.of([0, 0]),
                ],
              ],
            ],
          );
          var multiPolyBefore = multiPoly.clone();
          cleanCoords(multiPoly);
          Equality eq1 = Equality();

          expect(eq1.compare(multiPolyBefore, multiPoly), true);
        },
      );
    },
  );
}

// todo @armantorkzaban, remove after importing geojson_equlity library
typedef EqualityObjectComparator = bool Function(dynamic obj1, dynamic obj2);

class Equality {
  /// Decides the number of digits after . in a double
  final int precision;

  /// Even if the LineStrings are reverse versions of each other but the have similar
  /// [Position]s, they will be considered the same.
  final bool direction;

  /// If true, consider two [Polygon]s with shifted [Position]s as the same.
  final bool shiftedPolygon;
  // final EqualityObjectComparator objectComparator;

  Equality({
    this.precision = 17,
    this.direction = false,
    this.shiftedPolygon = false,

    //  this.objectComparator = _deepEqual,
  });

  bool _compareTypes<T extends GeoJSONObject>(
      GeoJSONObject? g1, GeoJSONObject? g2) {
    return g1 is T && g2 is T;
  }

  bool compare(GeoJSONObject? g1, GeoJSONObject? g2) {
    if (g1 == null && g2 == null) {
      return true;
    } else if (_compareTypes<Point>(g1, g2)) {
      return _compareCoords(
          (g1 as Point).coordinates, (g2 as Point).coordinates);
    } else if (_compareTypes<LineString>(g1, g2)) {
      return _compareLine(g1 as LineString, g2 as LineString);
    } else if (_compareTypes<Polygon>(g1, g2)) {
      return _comparePolygon(g1 as Polygon, g2 as Polygon);
    } else if (_compareTypes<Feature>(g1, g2)) {
      return compare((g1 as Feature).geometry, (g2 as Feature).geometry) &&
          g1.id == g2.id;
    } else if (_compareTypes<FeatureCollection>(g1, g2)) {
      for (var i = 0; i < (g1 as FeatureCollection).features.length; i++) {
        if (!compare(g1.features[i], (g2 as FeatureCollection).features[i])) {
          return false;
        }
      }
      return true;
    } else if (_compareTypes<GeometryCollection>(g1, g2)) {
      return compare(
        FeatureCollection(
          features: (g1 as GeometryCollection)
              .geometries
              .map((e) => Feature(geometry: e))
              .toList(),
        ),
        FeatureCollection(
          features: (g2 as GeometryCollection)
              .geometries
              .map((e) => Feature(geometry: e))
              .toList(),
        ),
      );
    } else if (_compareTypes<MultiPoint>(g1, g2)) {
      return compare(
        FeatureCollection(
          features: (g1 as MultiPoint)
              .coordinates
              .map((e) => Feature(geometry: Point(coordinates: e)))
              .toList(),
        ),
        FeatureCollection(
            features: (g2 as MultiPoint)
                .coordinates
                .map((e) => Feature(geometry: Point(coordinates: e)))
                .toList()),
      );
    } else if (_compareTypes<MultiLineString>(g1, g2)) {
      return compare(
        FeatureCollection(
          features: (g1 as MultiLineString)
              .coordinates
              .map((e) => Feature(geometry: LineString(coordinates: e)))
              .toList(),
        ),
        FeatureCollection(
            features: (g2 as MultiLineString)
                .coordinates
                .map((e) => Feature(geometry: LineString(coordinates: e)))
                .toList()),
      );
    } else if (_compareTypes<MultiPolygon>(g1, g2)) {
      return compare(
        FeatureCollection(
          features: (g1 as MultiPolygon)
              .coordinates
              .map((e) => Feature(geometry: Polygon(coordinates: e)))
              .toList(),
        ),
        FeatureCollection(
            features: (g2 as MultiPolygon)
                .coordinates
                .map(
                  (e) => Feature(geometry: Polygon(coordinates: e)),
                )
                .toList()),
      );
    } else {
      return false;
    }
  }

  bool _compareLine(LineString line1, LineString line2) {
    for (var i = 0; i < line1.coordinates.length; i++) {
      if (!_compareCoords(line1.coordinates[i], line2.coordinates[i])) {
        if (direction) {
          return false;
        } else {
          return _compareLine(
            line1,
            LineString(
              coordinates: line2.coordinates
                  .map((e) => e.clone())
                  .toList()
                  .reversed
                  .toList(),
            ),
          );
        }
      }
    }
    return true;
  }

  bool _compareCoords(Position one, Position two) {
    return one.alt?.toStringAsFixed(precision) ==
            two.alt?.toStringAsFixed(precision) &&
        one.lng.toStringAsFixed(precision) ==
            two.lng.toStringAsFixed(precision) &&
        one.lat.toStringAsFixed(precision) ==
            two.lat.toStringAsFixed(precision);
  }

  bool _comparePolygon(Polygon poly1, Polygon poly2) {
    List<List<Position>> list1 = poly1
        .clone()
        .coordinates
        .map((e) => e.sublist(0, e.length - 1))
        .toList();
    List<List<Position>> list2 = poly2
        .clone()
        .coordinates
        .map((e) => e.sublist(0, e.length - 1))
        .toList();

    for (var i = 0; i < list1.length; i++) {
      if (list1[i].length != list2[i].length) {
        return false;
      }
      for (var positionIndex = 0;
          positionIndex < list1[i].length;
          positionIndex++) {
        if (!shiftedPolygon && !direction) {
          if (!_compareCoords(
              list1[i][positionIndex], list2[i][positionIndex])) {
            return false;
          }
        } else if (shiftedPolygon && !direction) {
          int diff = list2[i].indexOf(list1[i][0]);
          if (!_compareCoords(
              list1[i][positionIndex],
              (list2[i][(list2[i].length + positionIndex + diff) %
                  list2[i].length]))) {
            return false;
          }
        } else if (direction && !shiftedPolygon) {
          List<List<Position>> listReversed = poly2
              .clone()
              .coordinates
              .map((e) => e.sublist(0, e.length - 1))
              .toList()
              .map((e) => e.reversed.toList())
              .toList();
          if (!_compareCoords(
              list1[i][positionIndex], listReversed[i][positionIndex])) {
            return false;
          }
        } else if (direction && shiftedPolygon) {
          List<List<Position>> listReversed = poly2
              .clone()
              .coordinates
              .map((e) => e.sublist(0, e.length - 1))
              .toList()
              .map((e) => e.reversed.toList())
              .toList();
          int diff = listReversed[i].indexOf(list1[i][0]);
          if (!_compareCoords(
              list1[i][positionIndex],
              (listReversed[i][(listReversed[i].length + positionIndex + diff) %
                  listReversed[i].length]))) {
            return false;
          }
        }
      }
    }
    return true;
  }
}
