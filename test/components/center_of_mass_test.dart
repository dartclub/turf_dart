import 'package:turf/center_of_mass.dart';
import 'package:turf/meta.dart';
import 'package:test/test.dart';
import 'package:turf/src/center_of_mass.dart';

void main () {

  final polygon = Feature<Polygon>(
      geometry: Polygon(
        coordinates: [
          [
            Position(1, 1),
            Position(1, -1),
            Position(-1, -1),
            Position(-1, 1),
            Position(1, 1)
          ],
        ],
      ),
    );

  final expectedOutput = Position(0.0, 0.0);
  test('centerOfMass - simple polygon centered around (0,0):', () {
    expect(centerOfMass(polygon).geometry?.coordinates, equals(expectedOutput));
  }); 

  final polygon2 = Feature<Polygon>(
    geometry: Polygon(
      coordinates: [
        [
          Position(2, 3),
          Position(3, 3),
          Position(3, 2),
          Position(2, 2),
          Position(2, 3)
        ],
      ],
    )
  );

  final expectedOutput2 = Position(2.5, 2.5);

  test('center of mass - simple polygon centered around non-zero coord:', () {
    expect(centerOfMass(polygon2).geometry?.coordinates, equals(expectedOutput2));
  });

  final polygon3 = Feature<Polygon>(
    geometry: Polygon(
      coordinates: [
        [
          Position(43, 21),
          Position(27, 13),
          Position(21, 41),
          Position(43, 21)
        ],
      ],
    )
  );
  final expectedOutput3 = Position(30.333333333333332, 25);

  test('Center of mass - complex polygon', () {
    expect(centerOfMass(polygon3).geometry?.coordinates, equals(expectedOutput3));
  });

  final polygon4 = Feature<Polygon>(
    geometry: Polygon(
      coordinates: [
        [
          Position(40, 20),
          Position(39, 20),
          Position(40, 20)
        ],
      ],
    )
  );
  final expectedOutput4 = Position(39.5, 20);
  test('Center of mass - line polygon', () {
    expect(centerOfMass(polygon4).geometry?.coordinates, equals(expectedOutput4));
  });
}