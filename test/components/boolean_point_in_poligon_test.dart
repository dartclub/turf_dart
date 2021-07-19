import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/boolean_point_in_poligon.dart';
import 'dart:convert' show jsonDecode;
import 'dart:io' show File;

void main() {
  test('boolean-point-in-polygon -- featureCollection', () {
    // test for a simple polygon
    var poly = polygon([
      [
        [0, 0],
        [0, 100],
        [100, 100],
        [100, 0],
        [0, 0],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);

    var ptIn = point(Position(50, 50));
    var ptOut = point(Position(140, 150));

    expect(booleanPointInPolygon(ptIn, poly), true,
        reason: 'point inside simple polygon');

    expect(
      booleanPointInPolygon(ptOut, poly),
      false,
      reason: 'point outside simple polygon',
    );

    // test for a concave polygon
    var concavePoly = polygon([
      [
        [0, 0],
        [50, 50],
        [0, 100],
        [100, 100],
        [100, 0],
        [0, 0],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);
    var ptConcaveIn = point(Position(75, 75));
    var ptConcaveOut = point(Position(25, 50));

    expect(
      booleanPointInPolygon(ptConcaveIn, concavePoly),
      true,
      reason: 'point inside concave polygon',
    );
    expect(
      booleanPointInPolygon(ptConcaveOut, concavePoly),
      false,
      reason: 'point outside concave polygon',
    );
  });

  test('boolean-point-in-polygon -- poly with hole', () async {
    var ptInHole = point(Position(-86.69208526611328, 36.20373274711739));
    var ptInPoly = point(Position(-86.72229766845702, 36.20258997094334));
    var ptOutsidePoly = point(Position(-86.75079345703125, 36.18527313913089));

    Map<String, dynamic> polyHole = jsonDecode(
        await File('test/assets/poly-with-hole.geojson').readAsString());
    final polygon = Feature.fromJson<Polygon>(polyHole);

    expect(booleanPointInPolygon(ptInHole, polygon), false);
    expect(booleanPointInPolygon(ptInPoly, polygon), true);
    expect(booleanPointInPolygon(ptOutsidePoly, polygon), false);
  });

  test('boolean-point-in-polygon -- multipolygon with hole', () async {
    var ptInHole = point(Position(-86.69208526611328, 36.20373274711739));
    var ptInPoly = point(Position(-86.72229766845702, 36.20258997094334));
    var ptInPoly2 = point(Position(-86.75079345703125, 36.18527313913089));
    var ptOutsidePoly = point(Position(-86.75302505493164, 36.23015046460186));

    Map<String, dynamic> multiPolyHole = jsonDecode(
        await File('test/assets/multipoly-with-hole.geojson').readAsString());

    final multiPolygon = Feature.fromJson<MultiPolygon>(multiPolyHole);

    expect(booleanPointInPolygon(ptInHole, multiPolygon), false);
    expect(booleanPointInPolygon(ptInPoly, multiPolygon), true);
    expect(booleanPointInPolygon(ptInPoly2, multiPolygon), true);
    expect(booleanPointInPolygon(ptInPoly, multiPolygon), true);
    expect(booleanPointInPolygon(ptOutsidePoly, multiPolygon), false);
  });

  test('boolean-point-in-polygon -- Boundary test', () {
    var poly1 = polygon([
      [
        [10, 10],
        [30, 20],
        [50, 10],
        [30, 0],
        [10, 10],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);
    var poly2 = polygon([
      [
        [10, 0],
        [30, 20],
        [50, 0],
        [30, 10],
        [10, 0],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);
    var poly3 = polygon([
      [
        [10, 0],
        [30, 20],
        [50, 0],
        [30, -20],
        [10, 0],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);
    var poly4 = polygon([
      [
        [0, 0],
        [0, 20],
        [50, 20],
        [50, 0],
        [40, 0],
        [30, 10],
        [30, 0],
        [20, 10],
        [10, 10],
        [10, 0],
        [0, 0],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);
    var poly5 = polygon([
      [
        [0, 20],
        [20, 40],
        [40, 20],
        [20, 0],
        [0, 20],
      ].map((e) => Position(e[0], e[1])).toList(),
      [
        [10, 20],
        [20, 30],
        [30, 20],
        [20, 10],
        [10, 20],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);
    final runTest = (ignoreBoundary) {
      var isBoundaryIncluded = ignoreBoundary == false;
      var tests = [
        [poly1, point(Position(10, 10)), isBoundaryIncluded], //0
        [poly1, point(Position(30, 20)), isBoundaryIncluded],
        [poly1, point(Position(50, 10)), isBoundaryIncluded],
        [poly1, point(Position(30, 10)), true],
        [poly1, point(Position(0, 10)), false],
        [poly1, point(Position(60, 10)), false],
        [poly1, point(Position(30, -10)), false],
        [poly1, point(Position(30, 30)), false],
        [poly2, point(Position(30, 0)), false],
        [poly2, point(Position(0, 0)), false],
        [poly2, point(Position(60, 0)), false], //10
        [poly3, point(Position(30, 0)), true],
        [poly3, point(Position(0, 0)), false],
        [poly3, point(Position(60, 0)), false],
        [poly4, point(Position(0, 20)), isBoundaryIncluded],
        [poly4, point(Position(10, 20)), isBoundaryIncluded],
        [poly4, point(Position(50, 20)), isBoundaryIncluded],
        [poly4, point(Position(0, 10)), isBoundaryIncluded],
        [poly4, point(Position(5, 10)), true],
        [poly4, point(Position(25, 10)), true],
        [poly4, point(Position(35, 10)), true], //20
        [poly4, point(Position(0, 0)), isBoundaryIncluded],
        [poly4, point(Position(20, 0)), false],
        [poly4, point(Position(35, 0)), false],
        [poly4, point(Position(50, 0)), isBoundaryIncluded],
        [poly4, point(Position(50, 10)), isBoundaryIncluded],
        [poly4, point(Position(5, 0)), isBoundaryIncluded],
        [poly4, point(Position(10, 0)), isBoundaryIncluded],
        [poly5, point(Position(20, 30)), isBoundaryIncluded],
        [poly5, point(Position(25, 25)), isBoundaryIncluded],
        [poly5, point(Position(30, 20)), isBoundaryIncluded], //30
        [poly5, point(Position(25, 15)), isBoundaryIncluded],
        [poly5, point(Position(20, 10)), isBoundaryIncluded],
        [poly5, point(Position(15, 15)), isBoundaryIncluded],
        [poly5, point(Position(10, 20)), isBoundaryIncluded],
        [poly5, point(Position(15, 25)), isBoundaryIncluded],
        [poly5, point(Position(20, 20)), false],
      ];

      var testTitle =
          'Boundary ' + (ignoreBoundary ? 'ignored ' : '') + 'test number ';
      for (var i = 0; i < tests.length; i++) {
        var item = tests[i];
        expect(
            booleanPointInPolygon(
                  item[1],
                  item[0],
                  ignoreBoundary: ignoreBoundary,
                ) ==
                item[2],
            true,
            reason: testTitle + i.toString());
      }
    };

    runTest(false);
    runTest(true);
  });

  test('boolean-point-in-polygon -- issue #15', () {
    var pt1 = point(Position(-9.9964077, 53.8040989));
    var poly = polygon([
      [
        [5.080336744095521, 67.89398938540765],
        [0.35070899909145403, 69.32470003971179],
        [-24.453622256504122, 41.146696777884564],
        [-21.6445524714804, 40.43225902006474],
        [5.080336744095521, 67.89398938540765],
      ].map((e) => Position(e[0], e[1])).toList(),
    ]);

    expect(booleanPointInPolygon(pt1, poly), true);
  });
}
