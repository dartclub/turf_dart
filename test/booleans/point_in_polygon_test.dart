import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/booleans/boolean_point_in_polygon.dart';

void main() {
  group(
    'pip',
    () {
      test(
        "boolean-point-in-polygon -- featureCollection",
        () {
          // test for a simple polygon
          var poly = Polygon(coordinates: [
            [
              Position.of([0, 0]),
              Position.of([0, 100]),
              Position.of([100, 100]),
              Position.of([100, 0]),
              Position.of([0, 0]),
            ],
          ]);
          var ptIn = Point(coordinates: (Position.of([50, 50])));
          var ptOut = Point(coordinates: (Position.of([140, 150])));
          // "point inside simple polygon"
          expect(booleanPointInPolygon(ptIn.coordinates, poly), true);
          // "point outside simple polygon"
          expect(booleanPointInPolygon(ptOut.coordinates, poly), false);

          // test for a concave polygon
          var concavePoly = Polygon(coordinates: [
            [
              Position.of([0, 0]),
              Position.of([50, 50]),
              Position.of([0, 100]),
              Position.of([100, 100]),
              Position.of([100, 0]),
              Position.of([0, 0]),
            ],
          ]);
          var ptConcaveIn = Point(coordinates: (Position.of([75, 75])));
          var ptConcaveOut = Point(coordinates: (Position.of([25, 50])));

          // "point inside concave polygon"
          expect(booleanPointInPolygon(ptConcaveIn.coordinates, concavePoly),
              true);
          //   "point outside concave polygon"
          expect(booleanPointInPolygon(ptConcaveOut.coordinates, concavePoly),
              false);
        },
      );

      test(
        "boolean-point-in-polygon -- poly with hole",
        () {
          var ptInHole = Point(
              coordinates:
                  (Position.of([-86.69208526611328, 36.20373274711739])));
          var ptInPoly = Point(
              coordinates:
                  (Position.of([-86.72229766845702, 36.20258997094334])));
          var ptOutsidePoly = Point(
              coordinates:
                  (Position.of([-86.75079345703125, 36.18527313913089])));

          var inFile = File(
              './test/examples/booleans/point_in_polygon/in/poly-with-hole.geojson');

          var polyHole =
              GeoJSONObject.fromJson(jsonDecode(inFile.readAsStringSync()));

          expect(booleanPointInPolygon(ptInHole.coordinates, polyHole), false);
          expect(booleanPointInPolygon(ptInPoly.coordinates, polyHole), true);
          expect(booleanPointInPolygon(ptOutsidePoly.coordinates, polyHole),
              false);
        },
      );

      test(
        "boolean-point-in-polygon -- multipolygon with hole",
        () {
          var ptInHole = Point(
              coordinates:
                  (Position.of([-86.69208526611328, 36.20373274711739])));
          var ptInPoly = Point(
              coordinates:
                  (Position.of([-86.72229766845702, 36.20258997094334])));
          var ptInPoly2 = Point(
              coordinates:
                  (Position.of([-86.75079345703125, 36.18527313913089])));
          var ptOutsidePoly = Point(
              coordinates:
                  (Position.of([-86.75302505493164, 36.23015046460186])));

          var inFile = File(
              './test/examples/booleans/point_in_polygon/in/multipoly-with-hole.geojson');

          var multiPolyHole =
              GeoJSONObject.fromJson(jsonDecode(inFile.readAsStringSync()));

          expect(booleanPointInPolygon(ptInHole.coordinates, multiPolyHole),
              false);
          expect(
              booleanPointInPolygon(ptInPoly.coordinates, multiPolyHole), true);
          expect(booleanPointInPolygon(ptInPoly2.coordinates, multiPolyHole),
              true);
          expect(
              booleanPointInPolygon(ptInPoly.coordinates, multiPolyHole), true);
          expect(
              booleanPointInPolygon(ptOutsidePoly.coordinates, multiPolyHole),
              false);
        },
      );

      test(
        'boolean-point-in-polygon -- Boundary test',
        () {
          var poly1 = Polygon(
            coordinates: [
              [
                Position.of([10, 10]),
                Position.of([30, 20]),
                Position.of([50, 10]),
                Position.of([30, 0]),
                Position.of([10, 10]),
              ],
            ],
          );
          var poly2 = Polygon(
            coordinates: [
              [
                Position.of([10, 0]),
                Position.of([30, 20]),
                Position.of([50, 0]),
                Position.of([30, 10]),
                Position.of([10, 0]),
              ],
            ],
          );
          var poly3 = Polygon(
            coordinates: [
              [
                Position.of([10, 0]),
                Position.of([30, 20]),
                Position.of([50, 0]),
                Position.of([30, -20]),
                Position.of([10, 0]),
              ],
            ],
          );
          var poly4 = Polygon(
            coordinates: [
              [
                Position.of([0, 0]),
                Position.of([0, 20]),
                Position.of([50, 20]),
                Position.of([50, 0]),
                Position.of([40, 0]),
                Position.of([30, 10]),
                Position.of([30, 0]),
                Position.of([20, 10]),
                Position.of([10, 10]),
                Position.of([10, 0]),
                Position.of([0, 0]),
              ],
            ],
          );
          var poly5 = Polygon(
            coordinates: [
              [
                Position.of([0, 20]),
                Position.of([20, 40]),
                Position.of([40, 20]),
                Position.of([20, 0]),
                Position.of([0, 20]),
              ],
              [
                Position.of([10, 20]),
                Position.of([20, 30]),
                Position.of([30, 20]),
                Position.of([20, 10]),
                Position.of([10, 20]),
              ],
            ],
          );

          void runTest(bool ignoreBoundary) {
            var isBoundaryIncluded = ignoreBoundary == false;
            var tests = [
              [
                poly1,
                Point(coordinates: (Position.of([10, 10]))),
                isBoundaryIncluded
              ], //0
              [
                poly1,
                Point(coordinates: (Position.of([30, 20]))),
                isBoundaryIncluded
              ],
              [
                poly1,
                Point(coordinates: (Position.of([50, 10]))),
                isBoundaryIncluded
              ],
              [
                poly1,
                Point(coordinates: (Position.of([30, 10]))),
                true
              ],
              [
                poly1,
                Point(coordinates: (Position.of([0, 10]))),
                false
              ],
              [
                poly1,
                Point(coordinates: (Position.of([60, 10]))),
                false
              ],
              [
                poly1,
                Point(coordinates: (Position.of([30, -10]))),
                false
              ],
              [
                poly1,
                Point(coordinates: (Position.of([30, 30]))),
                false
              ],
              [
                poly2,
                Point(coordinates: (Position.of([30, 0]))),
                false
              ],
              [
                poly2,
                Point(coordinates: (Position.of([0, 0]))),
                false
              ],
              [
                poly2,
                Point(coordinates: (Position.of([60, 0]))),
                false
              ], //10
              [
                poly3,
                Point(coordinates: (Position.of([30, 0]))),
                true
              ],
              [
                poly3,
                Point(coordinates: (Position.of([0, 0]))),
                false
              ],
              [
                poly3,
                Point(coordinates: (Position.of([60, 0]))),
                false
              ],
              [
                poly4,
                Point(coordinates: (Position.of([0, 20]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([10, 20]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([50, 20]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([0, 10]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([5, 10]))),
                true
              ],
              [
                poly4,
                Point(coordinates: (Position.of([25, 10]))),
                true
              ],
              [
                poly4,
                Point(coordinates: (Position.of([35, 10]))),
                true
              ], //20
              [
                poly4,
                Point(coordinates: (Position.of([0, 0]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([20, 0]))),
                false
              ],
              [
                poly4,
                Point(coordinates: (Position.of([35, 0]))),
                false
              ],
              [
                poly4,
                Point(coordinates: (Position.of([50, 0]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([50, 10]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([5, 0]))),
                isBoundaryIncluded
              ],
              [
                poly4,
                Point(coordinates: (Position.of([10, 0]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([20, 30]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([25, 25]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([30, 20]))),
                isBoundaryIncluded
              ], //30
              [
                poly5,
                Point(coordinates: (Position.of([25, 15]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([20, 10]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([15, 15]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([10, 20]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([15, 25]))),
                isBoundaryIncluded
              ],
              [
                poly5,
                Point(coordinates: (Position.of([20, 20]))),
                false
              ],
            ];

            for (int i = 0; i < tests.length; i++) {
              var item = tests[i];
              expect(
                  booleanPointInPolygon(
                        (item[1] as Point).coordinates,
                        item[0] as Polygon,
                        ignoreBoundary: ignoreBoundary,
                      ) ==
                      item[2],
                  isTrue);
            }
          }

          runTest(false);
          runTest(true);
        },
      );

// https://github.com/Turfjs/turf-inside/issues/15
      test(
        "boolean-point-in-polygon -- issue #15",
        () {
          var pt1 = Point(coordinates: (Position.of([-9.9964077, 53.8040989])));
          var poly = Polygon(
            coordinates: [
              [
                Position.of([5.080336744095521, 67.89398938540765]),
                Position.of([0.35070899909145403, 69.32470003971179]),
                Position.of([-24.453622256504122, 41.146696777884564]),
                Position.of([-21.6445524714804, 40.43225902006474]),
                Position.of([5.080336744095521, 67.89398938540765]),
              ],
            ],
          );

          expect(booleanPointInPolygon(pt1.coordinates, poly), true);
        },
      );
    },
  );
}
