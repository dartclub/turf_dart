import 'package:test/test.dart';
import 'package:turf/src/geojson.dart';
import 'package:turf/turf.dart';

main() {
  test('test intersects()', () {
    Feature<Polygon> poly = Feature<Polygon>(
      geometry: Polygon(coordinates: [[Position(125, -15), Position(113, -22), Position(154, -27), Position(144, -15), Position(125, -15)]]),
    );

    print(area(poly));
  });
}