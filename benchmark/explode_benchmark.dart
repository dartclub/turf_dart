import 'package:benchmark/benchmark.dart';
import 'package:turf/src/explode.dart';
import 'package:turf/turf.dart';

var poly = Polygon(coordinates: [
  [
    Position.of([0, 0]),
    Position.of([0, 10]),
    Position.of([10, 10]),
    Position.of([10, 0]),
    Position.of([0, 0]),
  ],
]);

main() {
  group('explode', () {
    benchmark('simple', () {
      explode(poly);
    });
  });
}
