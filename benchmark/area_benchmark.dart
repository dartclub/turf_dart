import 'package:benchmark/benchmark.dart';
import 'package:turf/turf.dart';

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

main() {
  group('area', () {
    benchmark('simple', () {
      area(poly);
    });
  });
}
