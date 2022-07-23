import 'package:test/test.dart';
import 'package:turf/src/geojson.dart';
import 'package:turf/turf.dart';

main() {
  test('test area()', () {
    Feature<Polygon> poly = Feature<Polygon>(
      geometry: Polygon(coordinates: [
        [
          Position(125, -15),
          Position(113, -22),
          Position(117, -37),
          Position(130, -33),
          Position(148, -39),
          Position(154, -27),
          Position(144, -15),
          Position(125, -15)
        ]
      ]),
    );

    var areaResult = area(poly);

    expect(areaResult, isNot(equals(null)));
    final roundedResult = round(areaResult!);
    expect(roundedResult, equals(7748891609977));
  });
}
