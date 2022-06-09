import 'package:test/test.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/intersection.dart';

final l1 = LineString(coordinates: [
  Position(0, 0),
  Position(2, 2),
]);

final l2 = LineString(coordinates: [
  Position(2, 0),
  Position(0, 2),
]);

final l3 = LineString(coordinates: [
  Position(2, 2),
  Position(2, 0),
]);

final l4 = LineString(coordinates: [
  Position(0, 0),
  Position(0, 2),
]);

main() {
  test('test intersects()', () {
    expect(intersects(l1, l2)?.coordinates, Position(1, 1));
    expect(intersects(l1, l3)?.coordinates, Position(2, 2));
    expect(intersects(l3, l4), null);
  });
}
