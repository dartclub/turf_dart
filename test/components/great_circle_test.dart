import 'package:turf/great_circle.dart';
import 'package:test/test.dart';
import 'package:turf/helpers.dart';

/* Note: This test function could be worked on further especially when dealing with precision.
Due to the general nature of greatCircle as a visual linestring, this should not be a big issue.
However, having further precision (testing changes from 1 decimal place to 4-6 can make it more useful for when npoints is large OR for shorter distances)
A
*/

Position roundedDegreePosition(Position pos) {
  return Position.of([
    double.parse(radiansToDegrees(pos[0]!).toStringAsFixed(1)),
    double.parse(radiansToDegrees(pos[1]!).toStringAsFixed(1)),
  ]);
}

void main() {
  // First test - simple coordinates
  final start = Position(0, -90);
  final end = Position(0, -80);

  final resultsFirstTest1 = [
    Position.of([-90.0, 0.0]),
    Position.of([-88.0, 0.0]),
    Position.of([-86.0, 0.0]),
    Position.of([-84.0, 0.0]),
    Position.of([-82.0, 0.0]),
    Position.of([-80.0, 0.0]),
  ];

  final resultsFirstTest2 = [
    Position.of([-90.0, 0.0]),
    Position.of([-89.0, 0.0]),
    Position.of([-88.0, 0.0]),
    Position.of([-87.0, 0.0]),
    Position.of([-86.0, 0.0]),
    Position.of([-85.0, 0.0]),
    Position.of([-84.0, 0.0]),
    Position.of([-83.0, 0.0]),
    Position.of([-82.0, 0.0]),
    Position.of([-81.0, 0.0]),
    Position.of([-80.0, 0.0]),
  ];

  test('Great circle simple tests:', () {
    final resultFirst1 = greatCircle(start, end, npoints: 5);
    final convertedResultFirst1 =
        resultFirst1.geometry?.coordinates.map(roundedDegreePosition).toList();

    expect(convertedResultFirst1, resultsFirstTest1);

    final resultFirst2 = greatCircle(start, end, npoints: 10);
    final convertedResultFirst2 =
        resultFirst2.geometry?.coordinates.map(roundedDegreePosition).toList();

    expect(convertedResultFirst2, resultsFirstTest2);
  });

  // Second test - intermediate coordinates (non-straight lines)
  final start2 = Position(48, -122);
  final end2 = Position(39, -77);

  final resultsSecondTest1 = [
    Position.of([-122.0, 48.0]),
    Position.of([-97.7, 45.8]),
    Position.of([-77.0, 39.0]),
  ];

  final resultsSecondTest2 = [
    Position.of([-122.0, 48.0]),
    Position.of([-109.6, 47.5]),
    Position.of([-97.7, 45.8]),
    Position.of([-86.8, 42.8]),
    Position.of([-77.0, 39.0]),
  ];

  test('Great circle intermediate tests:', () {
    final resultSecond1 = greatCircle(start2, end2, npoints: 2);
    final convertedResultSecond1 =
        resultSecond1.geometry?.coordinates.map(roundedDegreePosition).toList();

    expect(convertedResultSecond1, resultsSecondTest1);

    final resultSecond2 = greatCircle(start2, end2, npoints: 4);
    final convertedResultSecond2 =
        resultSecond2.geometry?.coordinates.map(roundedDegreePosition).toList();

    expect(convertedResultSecond2, resultsSecondTest2);
  });

  // Third test - complex coordinates (crossing anti-meridian)
  final start3 = Position(-21, 143);
  final end3 = Position(41, -140);

  final resultsThirdTest1 = [
    Position.of([143.0, -21.0]),
    Position.of([176.7, 12.7]),
    Position.of([-140.0, 41.0]),
  ];

  final resultsThirdTest2 = [
    Position.of([143.0, -21.0]),
    Position.of([160.2, -4.4]),
    Position.of([176.7, 12.7]),
    Position.of([-164.6, 28.5]),
    Position.of([-140.0, 41.0]),
  ];

  test('Great circle complex tests:', () {
    final resultThird1 = greatCircle(start3, end3, npoints: 2);
    final convertedResultThird1 =
        resultThird1.geometry?.coordinates.map(roundedDegreePosition).toList();

    expect(convertedResultThird1, resultsThirdTest1);

    final resultThird2 = greatCircle(start3, end3, npoints: 4);
    final convertedResultThird2 =
        resultThird2.geometry?.coordinates.map(roundedDegreePosition).toList();

    expect(convertedResultThird2, resultsThirdTest2);
  });
}
