import 'package:turf/great_circle.dart';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';

/* Note: This test function could be worked on further especially when dealing with precision. 
Due to the general nature of greatCircle as a visual linestring, this should not be a big issue.
However, having further precision (testing changes from 1 decimal place to 4-6 can make it more useful for when npoints is large OR for shorter distances)
A
*/
void main() {
  //First test - simple coordinates

  final start = Position(0, -90);
  final end = Position(0, -80);

  List<List<double>> resultsFirstTest1 = [
    [-90.0, 0.0],
    [-88.0, 0.0],
    [-86.0, 0.0],
    [-84.0, 0.0],
    [-82.0, 0.0],
    [-80.0, 0.0]
  ];
  List<List<double>> resultsFirstTest2 = [
    [-90.0, 0.0],
    [-89.0, 0.0],
    [-88.0, 0.0],
    [-87.0, 0.0],
    [-86.0, 0.0],
    [-85.0, 0.0],
    [-84.0, 0.0],
    [-83.0, 0.0],
    [-82.0, 0.0],
    [-81.0, 0.0],
    [-80.0, 0.0]
  ];

  test('Great circle simple tests:', () {
    var resultFirst1 = greatCircle(start, end, npoints: 5);
    var convertedResultFirst1 = resultFirst1.geometry?.coordinates
        .map((pos) => [
              double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)),
              double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))
            ])
        .toList();
    expect(convertedResultFirst1, resultsFirstTest1);

    var resultFirst2 = greatCircle(start, end, npoints: 10);
    var convertedResultFirst2 = resultFirst2.geometry?.coordinates
        .map((pos) => [
              double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)),
              double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))
            ])
        .toList();
    expect(convertedResultFirst2, resultsFirstTest2);
  });

  // Second test - intermediate coordiantes (non-straight lines)
  final start2 = Position(48, -122);
  final end2 = Position(39, -77);

  List<List<double>> resultsSecondTest1 = [
    [-122.0, 48.0],
    [-97.7, 45.8],
    [-77.0, 39.0]
  ];
  List<List<double>> resultsSecondTest2 = [
    [-122.0, 48.0],
    [-109.6, 47.5],
    [-97.7, 45.8],
    [-86.8, 42.8],
    [-77.0, 39.0]
  ];

  test('Great circle intermediate tests:', () {
    var resultSecond1 = greatCircle(start2, end2, npoints: 2);
    var convertedResultSecond1 = resultSecond1.geometry?.coordinates
        .map((pos) => [
              double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)),
              double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))
            ])
        .toList();
    expect(convertedResultSecond1, resultsSecondTest1);

    var resultSecond2 = greatCircle(start2, end2, npoints: 4);
    var convertedResultSecond2 = resultSecond2.geometry?.coordinates
        .map((pos) => [
              double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)),
              double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))
            ])
        .toList();
    expect(convertedResultSecond2, resultsSecondTest2);
  });

  // Third test - complex coordinates (crossing anti-meridian)

  final start3 = Position(-21, 143);
  final end3 = Position(41, -140);

  List<List<double>> resultsThirdTest1 = [
    [143.0, -21.0],
    [176.7, 12.7],
    [-140, 41]
  ];
  List<List<double>> resultsThirdTest2 = [
    [143.0, -21.0],
    [160.2, -4.4],
    [176.7, 12.7],
    [-164.6, 28.5],
    [-140, 41]
  ];
  test('Great circle complex tests:', () {
    var resultThird1 = greatCircle(start3, end3, npoints: 2);
    var convertedResultThird1 = resultThird1.geometry?.coordinates
        .map((pos) => [
              double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)),
              double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))
            ])
        .toList();
    expect(convertedResultThird1, resultsThirdTest1);

    var resultThird2 = greatCircle(start3, end3, npoints: 4);
    var convertedResultThird2 = resultThird2.geometry?.coordinates
        .map((pos) => [
              double.parse(radiansToDegrees(pos[0]).toStringAsFixed(1)),
              double.parse(radiansToDegrees(pos[1]).toStringAsFixed(1))
            ])
        .toList();
    expect(convertedResultThird2, resultsThirdTest2);
  });
}
